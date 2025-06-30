import Foundation

/// Messages API providing Anthropic-compatible message handling.
///
/// `MessagesAPI` offers an alternative interface to xAI's models that follows
/// Anthropic's message format conventions. This API is ideal for applications
/// migrating from Anthropic's Claude or requiring specific message formatting features.
///
/// ## Key Features
///
/// - **Anthropic Compatibility**: Familiar message format for easy migration
/// - **System Prompts**: Dedicated system message support
/// - **Advanced Sampling**: Fine-grained control with topK and topP parameters
/// - **Tool Usage**: Function calling with Anthropic-style tool definitions
/// - **Metadata Support**: Attach custom metadata to requests
/// - **Streaming**: Real-time response streaming
///
/// ## Basic Usage
///
/// ```swift
/// let client = xAIClient(apiKey: "your-api-key")
///
/// // Create a message
/// let request = MessagesRequest(
///     messages: [
///         AnthropicMessage(role: .user, content: "What's the weather like?")
///     ],
///     model: .grokBeta,
///     system: "You are a helpful weather assistant.",
///     maxTokens: 150
/// )
///
/// let response = try await client.messages.create(request)
/// print(response.content.first?.text ?? "")
/// ```
///
/// ## Differences from Chat API
///
/// While both APIs provide similar functionality, key differences include:
/// - **Message Format**: Uses Anthropic's message structure
/// - **System Messages**: Separate `system` parameter instead of system role
/// - **Sampling Parameters**: Additional `topK` parameter
/// - **Response Format**: Different response structure matching Anthropic's format
///
/// Choose this API when:
/// - Migrating from Anthropic's Claude
/// - You need specific Anthropic-compatible features
/// - Your existing code uses Anthropic's message format
public final class MessagesAPI {
    private let client: HTTPClientProtocol
    private let configuration: xAIConfiguration
    
    init(client: HTTPClientProtocol, configuration: xAIConfiguration) {
        self.client = client
        self.configuration = configuration
    }
    
    /// Create a message using Anthropic-compatible formatting.
    ///
    /// This method sends a synchronous request to generate a response based on the
    /// provided messages and configuration. The API follows Anthropic's message
    /// format for compatibility.
    ///
    /// - Parameter request: A ``MessagesRequest`` containing:
    ///   - `messages`: Array of user/assistant messages
    ///   - `model`: The model to use (e.g., `.grokBeta`)
    ///   - `system`: Optional system prompt
    ///   - `maxTokens`: Maximum tokens to generate
    ///   - Advanced parameters like `temperature`, `topK`, `topP`
    ///
    /// - Returns: A ``MessagesResponse`` containing:
    ///   - Generated content blocks
    ///   - Token usage information
    ///   - Stop reason and metadata
    ///
    /// - Throws: ``xAIError`` for various error conditions:
    ///   - `.invalidAPIKey`: Invalid or missing API key
    ///   - `.rateLimitExceeded`: API rate limit reached
    ///   - `.networkError`: Network connectivity issues
    ///
    /// ## Example
    /// ```swift
    /// let request = MessagesRequest(
    ///     messages: [
    ///         AnthropicMessage(
    ///             role: .user,
    ///             content: "Explain quantum entanglement"
    ///         )
    ///     ],
    ///     model: .grokBeta,
    ///     system: "You are a physics professor. Explain concepts clearly.",
    ///     maxTokens: 500,
    ///     temperature: 0.7
    /// )
    ///
    /// do {
    ///     let response = try await client.messages.create(request)
    ///     if let text = response.content.first?.text {
    ///         print(text)
    ///     }
    /// } catch {
    ///     print("Error: \(error)")
    /// }
    /// ```
    public func create(_ request: MessagesRequest) async throws -> MessagesResponse {
        let url = configuration.apiBaseURL.appendingPathComponent("/v1/messages")
        let encoder = JSONEncoder()
        let body = try encoder.encode(request)
        
        let httpRequest = HTTPRequest(
            method: .post,
            url: url,
            body: body,
            timeoutInterval: configuration.timeoutInterval
        )
        
        return try await client.sendRequest(httpRequest)
    }
    
    /// Create a streaming message for real-time responses.
    ///
    /// This method enables token-by-token streaming of responses using Anthropic's
    /// message format. Perfect for creating responsive, interactive experiences.
    ///
    /// - Parameter request: A ``MessagesRequest`` with messages and parameters.
    ///   The `stream` parameter is automatically set to `true`.
    ///
    /// - Returns: An `AsyncThrowingStream` of ``MessageStreamEvent`` objects containing:
    ///   - `.messageStart`: Initial message metadata
    ///   - `.contentBlockStart`: Beginning of a content block
    ///   - `.contentBlockDelta`: Incremental content updates
    ///   - `.contentBlockStop`: End of a content block
    ///   - `.messageDelta`: Message-level updates (usage, etc.)
    ///   - `.messageStop`: Final message event
    ///
    /// - Throws: ``xAIError`` for streaming or network errors
    ///
    /// ## Example
    /// ```swift
    /// let request = MessagesRequest(
    ///     messages: [
    ///         AnthropicMessage(role: .user, content: "Write a poem about AI")
    ///     ],
    ///     model: .grokBeta,
    ///     maxTokens: 200
    /// )
    ///
    /// do {
    ///     for try await event in client.messages.createStream(request) {
    ///         switch event.type {
    ///         case .contentBlockDelta:
    ///             if let delta = event.delta?.text {
    ///                 print(delta, terminator: "")
    ///                 fflush(stdout)
    ///             }
    ///         case .messageStop:
    ///             print("\n\nCompleted!")
    ///         default:
    ///             break
    ///         }
    ///     }
    /// } catch {
    ///     print("Streaming error: \(error)")
    /// }
    /// ```
    ///
    /// - Note: The stream automatically handles SSE parsing and buffering.
    public func createStream(_ request: MessagesRequest) async throws -> AsyncThrowingStream<MessageStreamEvent, Error> {
        var streamRequest = request
        streamRequest = MessagesRequest(
            messages: request.messages,
            model: request.model,
            maxTokens: request.maxTokens,
            metadata: request.metadata,
            stopSequences: request.stopSequences,
            stream: true, // Force streaming
            system: request.system,
            temperature: request.temperature,
            toolChoice: request.toolChoice,
            tools: request.tools,
            topK: request.topK,
            topP: request.topP
        )
        
        let url = configuration.apiBaseURL.appendingPathComponent("/v1/messages")
        let encoder = JSONEncoder()
        let body = try encoder.encode(streamRequest)
        
        let httpRequest = HTTPRequest(
            method: .post,
            url: url,
            body: body,
            timeoutInterval: configuration.timeoutInterval
        )
        
        let eventStream = try await client.sendStreamingRequest(httpRequest)
        
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    var buffer = Data()
                    
                    for try await event in eventStream {
                        switch event {
                        case .data(let data):
                            // Accumulate data in buffer
                            buffer.append(data)
                            
                            // Check for complete events (double newline)
                            while let doubleNewlineRange = buffer.range(of: Data("\n\n".utf8)) {
                                // Extract the complete event
                                let eventData = buffer[..<doubleNewlineRange.upperBound]
                                buffer.removeSubrange(..<doubleNewlineRange.upperBound)
                                
                                // Parse the complete event
                                let events = SSEParser.parse(eventData)
                                for event in events {
                                    if let messageEvent = SSEParser.parseMessageChunk(event) {
                                        continuation.yield(messageEvent)
                                    }
                                }
                            }
                        case .done:
                            // Process any remaining data in buffer
                            if !buffer.isEmpty {
                                let events = SSEParser.parse(buffer)
                                for event in events {
                                    if let messageEvent = SSEParser.parseMessageChunk(event) {
                                        continuation.yield(messageEvent)
                                    }
                                }
                            }
                            continuation.finish()
                        }
                    }
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    /// Convenience method for creating messages with simplified parameters.
    ///
    /// This method provides a streamlined interface for basic message creation
    /// without constructing a full request object.
    ///
    /// - Parameters:
    ///   - messages: An array of ``Message`` objects in the conversation
    ///   - model: The model identifier (e.g., "grok-beta")
    ///   - maxTokens: Maximum tokens to generate (required for Messages API)
    ///   - system: Optional system prompt to guide the model's behavior
    ///   - temperature: Optional sampling temperature (0.0-2.0)
    ///
    /// - Returns: A ``MessagesResponse`` with the generated content
    ///
    /// - Throws: ``xAIError`` for API errors
    ///
    /// ## Example
    /// ```swift
    /// let response = try await client.messages.create(
    ///     messages: [
    ///         Message(role: .user, content: "What's the capital of Japan?")
    ///     ],
    ///     model: "grok-beta",
    ///     maxTokens: 100,
    ///     system: "Answer concisely.",
    ///     temperature: 0.5
    /// )
    /// ```
    public func create(
        messages: [Message],
        model: String,
        maxTokens: Int,
        system: String? = nil,
        temperature: Double? = nil
    ) async throws -> MessagesResponse {
        let request = MessagesRequest(
            messages: messages,
            model: model,
            maxTokens: maxTokens,
            system: system,
            temperature: temperature
        )
        return try await create(request)
    }
    
    /// Convenience method for creating streaming messages.
    ///
    /// Provides a simplified interface for streaming responses without
    /// constructing a full request object.
    ///
    /// - Parameters:
    ///   - messages: An array of ``Message`` objects in the conversation
    ///   - model: The model identifier (e.g., "grok-beta")
    ///   - maxTokens: Maximum tokens to generate (required)
    ///   - system: Optional system prompt
    ///   - temperature: Optional sampling temperature (0.0-2.0)
    ///
    /// - Returns: An `AsyncThrowingStream` of ``MessageStreamEvent`` objects
    ///
    /// - Throws: ``xAIError`` for streaming or API errors
    ///
    /// ## Example
    /// ```swift
    /// for try await event in client.messages.createStream(
    ///     messages: [Message(role: .user, content: "Tell me a story")],
    ///     model: "grok-beta",
    ///     maxTokens: 500,
    ///     system: "You are a creative storyteller."
    /// ) {
    ///     if case .contentBlockDelta = event.type,
    ///        let text = event.delta?.text {
    ///         print(text, terminator: "")
    ///     }
    /// }
    /// ```
    public func createStream(
        messages: [Message],
        model: String,
        maxTokens: Int,
        system: String? = nil,
        temperature: Double? = nil
    ) async throws -> AsyncThrowingStream<MessageStreamEvent, Error> {
        let request = MessagesRequest(
            messages: messages,
            model: model,
            maxTokens: maxTokens,
            stream: true,
            system: system,
            temperature: temperature
        )
        return try await createStream(request)
    }
}