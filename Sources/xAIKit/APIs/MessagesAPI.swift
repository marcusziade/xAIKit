import Foundation

/// API for messages (Anthropic compatible)
public final class MessagesAPI {
    private let client: HTTPClientProtocol
    private let configuration: xAIConfiguration
    
    init(client: HTTPClientProtocol, configuration: xAIConfiguration) {
        self.client = client
        self.configuration = configuration
    }
    
    /// Create a message
    /// - Parameter request: The messages request
    /// - Returns: The messages response
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
    
    /// Create a message with streaming
    /// - Parameter request: The messages request (with stream: true)
    /// - Returns: An async stream of message events
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
                    for try await event in eventStream {
                        switch event {
                        case .data(let data):
                            let events = SSEParser.parse(data)
                            for event in events {
                                if let messageEvent = SSEParser.parseMessageChunk(event) {
                                    continuation.yield(messageEvent)
                                }
                            }
                        case .done:
                            continuation.finish()
                        }
                    }
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    /// Convenience method to create a simple message
    /// - Parameters:
    ///   - messages: Array of messages
    ///   - model: The model to use
    ///   - maxTokens: Maximum tokens to generate
    ///   - system: System prompt
    ///   - temperature: Sampling temperature
    /// - Returns: The messages response
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
    
    /// Convenience method to create a streaming message
    /// - Parameters:
    ///   - messages: Array of messages
    ///   - model: The model to use
    ///   - maxTokens: Maximum tokens to generate
    ///   - system: System prompt
    ///   - temperature: Sampling temperature
    /// - Returns: An async stream of message events
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