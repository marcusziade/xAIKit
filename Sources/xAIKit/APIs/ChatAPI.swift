import Foundation

/// Chat completions API for conversational AI interactions with xAI models.
///
/// `ChatAPI` provides comprehensive access to xAI's chat completion endpoints, supporting
/// standard completions, real-time streaming, deferred processing, and advanced features
/// like function calling and structured outputs.
///
/// ## Features
///
/// - **Standard Completions**: Synchronous request-response conversations
/// - **Streaming**: Real-time token-by-token response streaming
/// - **Deferred Completions**: Non-blocking requests for long-running tasks
/// - **Function Calling**: Enable AI to interact with your application's functions
/// - **Structured Outputs**: JSON schema validation for reliable responses
/// - **Multi-modal Support**: Process text and image inputs together
/// - **Reasoning Control**: Adjust AI reasoning effort (low/medium/high)
///
/// ## Basic Usage
///
/// ```swift
/// let client = xAIClient(apiKey: "your-api-key")
///
/// // Simple completion
/// let response = try await client.chat.completions(
///     messages: [
///         ChatMessage(role: .user, content: "Explain quantum computing")
///     ],
///     model: .grokBeta
/// )
///
/// // Streaming completion
/// for try await chunk in client.chat.stream(
///     messages: [ChatMessage(role: .user, content: "Write a story")],
///     model: .grokBeta
/// ) {
///     print(chunk.choices.first?.delta?.content ?? "", terminator: "")
/// }
/// ```
///
/// ## Advanced Features
///
/// ### Function Calling
/// ```swift
/// let tools = [
///     ChatTool(
///         type: .function,
///         function: ChatFunction(
///             name: "get_weather",
///             description: "Get current weather",
///             parameters: [
///                 "type": "object",
///                 "properties": [
///                     "location": ["type": "string"]
///                 ]
///             ]
///         )
///     )
/// ]
///
/// let response = try await client.chat.completions(
///     ChatCompletionRequest(
///         messages: messages,
///         model: .grokBeta,
///         tools: tools,
///         toolChoice: .auto
///     )
/// )
/// ```
///
/// ### Structured Outputs
/// ```swift
/// let schema = JSONSchema(
///     type: .object,
///     properties: [
///         "name": JSONSchema(type: .string),
///         "age": JSONSchema(type: .integer)
///     ]
/// )
///
/// let response = try await client.chat.completions(
///     ChatCompletionRequest(
///         messages: messages,
///         model: .grokBeta,
///         responseFormat: .jsonSchema(
///             JSONSchemaFormat(name: "person", schema: schema)
///         )
///     )
/// )
/// ```
public final class ChatAPI {
    private let client: HTTPClientProtocol
    private let configuration: xAIConfiguration
    
    init(client: HTTPClientProtocol, configuration: xAIConfiguration) {
        self.client = client
        self.configuration = configuration
    }
    
    /// Create a chat completion with xAI models.
    ///
    /// This method sends a synchronous request to generate a chat completion based on
    /// the provided messages and parameters.
    ///
    /// - Parameter request: A ``ChatCompletionRequest`` containing messages, model selection,
    ///   and optional parameters like temperature, max tokens, and response format.
    ///
    /// - Returns: A ``ChatCompletionResponse`` containing the generated message, token usage,
    ///   and metadata.
    ///
    /// - Throws: ``xAIError`` for various error conditions:
    ///   - `.invalidAPIKey`: Invalid or missing API key
    ///   - `.rateLimitExceeded`: API rate limit reached
    ///   - `.networkError`: Network connectivity issues
    ///   - `.decodingError`: Invalid response format
    ///
    /// ## Example
    /// ```swift
    /// let request = ChatCompletionRequest(
    ///     messages: [
    ///         ChatMessage(role: .system, content: "You are a helpful assistant"),
    ///         ChatMessage(role: .user, content: "What is the capital of France?")
    ///     ],
    ///     model: .grokBeta,
    ///     temperature: 0.7,
    ///     maxTokens: 150
    /// )
    ///
    /// do {
    ///     let response = try await client.chat.completions(request)
    ///     print(response.choices.first?.message.content ?? "")
    /// } catch {
    ///     print("Error: \(error)")
    /// }
    /// ```
    public func completions(_ request: ChatCompletionRequest) async throws -> ChatCompletionResponse {
        let url = configuration.apiBaseURL.appendingPathComponent("/v1/chat/completions")
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
    
    /// Create a streaming chat completion for real-time responses.
    ///
    /// This method enables token-by-token streaming of the AI's response, perfect for
    /// creating responsive, interactive experiences. The response is delivered as an
    /// async stream of chunks.
    ///
    /// - Parameter request: A ``ChatCompletionRequest`` with messages and parameters.
    ///   The `stream` parameter is automatically set to `true`.
    ///
    /// - Returns: An `AsyncThrowingStream` of ``ChatCompletionChunk`` objects, each
    ///   containing a token or partial response.
    ///
    /// - Throws: ``xAIError`` for various error conditions:
    ///   - `.streamingError`: Issues with the streaming connection
    ///   - `.networkError`: Network connectivity problems
    ///   - `.decodingError`: Malformed streaming data
    ///
    /// ## Example
    /// ```swift
    /// let request = ChatCompletionRequest(
    ///     messages: [ChatMessage(role: .user, content: "Write a haiku")],
    ///     model: .grokBeta
    /// )
    ///
    /// do {
    ///     for try await chunk in client.chat.completionsStream(request) {
    ///         if let content = chunk.choices.first?.delta?.content {
    ///             print(content, terminator: "")
    ///             fflush(stdout) // Ensure immediate output
    ///         }
    ///     }
    /// } catch {
    ///     print("\nStreaming error: \(error)")
    /// }
    /// ```
    ///
    /// - Note: The stream automatically handles Server-Sent Events (SSE) parsing and
    ///   buffering for optimal performance.
    public func completionsStream(_ request: ChatCompletionRequest) async throws -> AsyncThrowingStream<ChatCompletionChunk, Error> {
        var streamRequest = request
        streamRequest = ChatCompletionRequest(
            messages: request.messages,
            model: request.model,
            frequencyPenalty: request.frequencyPenalty,
            logitBias: request.logitBias,
            logprobs: request.logprobs,
            topLogprobs: request.topLogprobs,
            maxTokens: request.maxTokens,
            n: request.n,
            presencePenalty: request.presencePenalty,
            reasoningEffort: request.reasoningEffort,
            responseFormat: request.responseFormat,
            seed: request.seed,
            stop: request.stop,
            stream: true, // Force streaming
            temperature: request.temperature,
            topP: request.topP,
            tools: request.tools,
            toolChoice: request.toolChoice,
            parallelToolCalls: request.parallelToolCalls,
            user: request.user,
            deferred: request.deferred
        )
        
        let url = configuration.apiBaseURL.appendingPathComponent("/v1/chat/completions")
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
                                    if let chunk = SSEParser.parseChatCompletionChunk(event) {
                                        continuation.yield(chunk)
                                    }
                                }
                            }
                        case .done:
                            // Process any remaining data in buffer
                            if !buffer.isEmpty {
                                let events = SSEParser.parse(buffer)
                                for event in events {
                                    if let chunk = SSEParser.parseChatCompletionChunk(event) {
                                        continuation.yield(chunk)
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
    
    /// Retrieve the result of a deferred chat completion request.
    ///
    /// Deferred completions allow you to submit a request and retrieve the result later,
    /// useful for long-running tasks or when you don't need an immediate response.
    ///
    /// - Parameter requestId: The unique identifier returned when creating a deferred request.
    ///
    /// - Returns: A ``ChatCompletionResponse`` if the request is complete, or `nil` if
    ///   still processing.
    ///
    /// - Throws: ``xAIError`` for various error conditions:
    ///   - `.invalidRequestId`: The request ID doesn't exist
    ///   - `.networkError`: Network connectivity issues
    ///
    /// ## Example
    /// ```swift
    /// // First, create a deferred request
    /// let request = ChatCompletionRequest(
    ///     messages: messages,
    ///     model: .grokBeta,
    ///     deferred: true
    /// )
    /// let deferredResponse = try await client.chat.completions(request)
    /// let requestId = deferredResponse.id
    ///
    /// // Later, check if the result is ready
    /// if let result = try await client.chat.getDeferredCompletion(requestId: requestId) {
    ///     print("Completed: \(result.choices.first?.message.content ?? "")")
    /// } else {
    ///     print("Still processing...")
    /// }
    /// ```
    ///
    /// - Important: Deferred requests have a limited lifetime. Check the API documentation
    ///   for retention policies.
    public func getDeferredCompletion(requestId: String) async throws -> ChatCompletionResponse? {
        let url = configuration.apiBaseURL.appendingPathComponent("/v1/chat/deferred-completion/\(requestId)")
        
        let httpRequest = HTTPRequest(
            method: .get,
            url: url,
            timeoutInterval: configuration.timeoutInterval
        )
        
        do {
            let response: ChatCompletionResponse = try await client.sendRequest(httpRequest)
            return response
        } catch let error as xAIError {
            if case .apiError(let statusCode, _) = error, statusCode == 202 {
                // Request is still pending
                return nil
            }
            throw error
        }
    }
    
    /// Convenience method for creating simple chat completions.
    ///
    /// This method provides a streamlined interface for basic chat completions without
    /// needing to construct a full request object.
    ///
    /// - Parameters:
    ///   - messages: An array of ``ChatMessage`` objects representing the conversation
    ///   - model: The ``Model`` to use for generation (defaults to configuration default)
    ///   - maxTokens: Maximum number of tokens to generate (defaults to model's default)
    ///   - temperature: Sampling temperature from 0.0 to 2.0 (defaults to 1.0)
    ///     - Lower values (0.0-0.7): More focused and deterministic
    ///     - Higher values (0.7-2.0): More creative and varied
    ///
    /// - Returns: A ``ChatCompletionResponse`` with the generated content
    ///
    /// - Throws: ``xAIError`` for API errors
    ///
    /// ## Example
    /// ```swift
    /// let response = try await client.chat.completions(
    ///     messages: [
    ///         ChatMessage(role: .user, content: "Tell me a joke")
    ///     ],
    ///     model: .grokBeta,
    ///     temperature: 1.2 // More creative responses
    /// )
    /// ```
    public func completions(
        messages: [ChatMessage],
        model: String,
        maxTokens: Int? = nil,
        temperature: Double? = nil
    ) async throws -> ChatCompletionResponse {
        let request = ChatCompletionRequest(
            messages: messages,
            model: model,
            maxTokens: maxTokens,
            temperature: temperature
        )
        return try await completions(request)
    }
    
    /// Convenience method for creating streaming chat completions.\n    ///\n    /// Provides a simplified interface for streaming responses without constructing\n    /// a full request object. Perfect for interactive applications.\n    ///\n    /// - Parameters:\n    ///   - messages: An array of ``ChatMessage`` objects representing the conversation\n    ///   - model: The ``Model`` to use for generation\n    ///   - maxTokens: Maximum tokens to generate (optional)\n    ///   - temperature: Sampling temperature from 0.0 to 2.0 (optional)\n    ///\n    /// - Returns: An `AsyncThrowingStream` of ``ChatCompletionChunk`` objects\n    ///\n    /// - Throws: ``xAIError`` for streaming or API errors\n    ///\n    /// ## Example\n    /// ```swift\n    /// for try await chunk in client.chat.completionsStream(\n    ///     messages: [ChatMessage(role: .user, content: \"Write a story\")],\n    ///     model: .grokBeta,\n    ///     temperature: 1.0\n    /// ) {\n    ///     if let content = chunk.choices.first?.delta?.content {\n    ///         print(content, terminator: \"\")\n    ///     }\n    /// }\n    /// ```
    public func completionsStream(
        messages: [ChatMessage],
        model: String,
        maxTokens: Int? = nil,
        temperature: Double? = nil
    ) async throws -> AsyncThrowingStream<ChatCompletionChunk, Error> {
        let request = ChatCompletionRequest(
            messages: messages,
            model: model,
            maxTokens: maxTokens,
            stream: true,
            temperature: temperature
        )
        return try await completionsStream(request)
    }
}