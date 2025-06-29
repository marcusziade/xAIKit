import Foundation

/// API for chat completions
public final class ChatAPI {
    private let client: HTTPClientProtocol
    private let configuration: xAIConfiguration
    
    init(client: HTTPClientProtocol, configuration: xAIConfiguration) {
        self.client = client
        self.configuration = configuration
    }
    
    /// Create a chat completion
    /// - Parameter request: The chat completion request
    /// - Returns: The chat completion response
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
    
    /// Create a chat completion with streaming
    /// - Parameter request: The chat completion request (with stream: true)
    /// - Returns: An async stream of chat completion chunks
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
                    for try await event in eventStream {
                        switch event {
                        case .data(let data):
                            let events = SSEParser.parse(data)
                            for event in events {
                                if let chunk = SSEParser.parseChatCompletionChunk(event) {
                                    continuation.yield(chunk)
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
    
    /// Get a deferred chat completion result
    /// - Parameter requestId: The deferred request ID
    /// - Returns: The chat completion response, or nil if still processing
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
    
    /// Convenience method to create a simple chat completion
    /// - Parameters:
    ///   - messages: Array of chat messages
    ///   - model: The model to use
    ///   - maxTokens: Maximum tokens to generate
    ///   - temperature: Sampling temperature
    /// - Returns: The chat completion response
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
    
    /// Convenience method to create a streaming chat completion
    /// - Parameters:
    ///   - messages: Array of chat messages
    ///   - model: The model to use
    ///   - maxTokens: Maximum tokens to generate
    ///   - temperature: Sampling temperature
    /// - Returns: An async stream of chat completion chunks
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