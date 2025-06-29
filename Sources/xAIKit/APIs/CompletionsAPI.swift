import Foundation

/// API for legacy completions endpoints
public final class CompletionsAPI {
    private let client: HTTPClientProtocol
    private let configuration: xAIConfiguration
    
    init(client: HTTPClientProtocol, configuration: xAIConfiguration) {
        self.client = client
        self.configuration = configuration
    }
    
    // MARK: - OpenAI Compatible Completions
    
    /// Create a completion (OpenAI compatible legacy)
    /// - Parameter request: The completions request
    /// - Returns: The completions response
    public func create(_ request: CompletionsRequest) async throws -> CompletionsResponse {
        let url = configuration.apiBaseURL.appendingPathComponent("/v1/completions")
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
    
    /// Convenience method to create a completion
    /// - Parameters:
    ///   - prompt: The prompt to complete
    ///   - model: The model to use
    ///   - maxTokens: Maximum tokens to generate
    ///   - temperature: Sampling temperature
    ///   - stop: Stop sequences
    /// - Returns: The completions response
    public func create(
        prompt: String,
        model: String,
        maxTokens: Int? = nil,
        temperature: Double? = nil,
        stop: [String]? = nil
    ) async throws -> CompletionsResponse {
        let request = CompletionsRequest(
            prompt: .string(prompt),
            model: model,
            maxTokens: maxTokens,
            stop: stop.map { .multiple($0) },
            temperature: temperature
        )
        return try await create(request)
    }
    
    // MARK: - Anthropic Compatible Complete
    
    /// Create a completion (Anthropic compatible legacy)
    /// - Parameter request: The complete request
    /// - Returns: The complete response
    public func complete(_ request: CompleteRequest) async throws -> CompleteResponse {
        let url = configuration.apiBaseURL.appendingPathComponent("/v1/complete")
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
    
    /// Convenience method to create a completion (Anthropic style)
    /// - Parameters:
    ///   - prompt: The prompt to complete
    ///   - model: The model to use
    ///   - maxTokensToSample: Maximum tokens to generate
    ///   - temperature: Sampling temperature
    ///   - stopSequences: Stop sequences
    /// - Returns: The complete response
    public func complete(
        prompt: String,
        model: String,
        maxTokensToSample: Int,
        temperature: Double? = nil,
        stopSequences: [String]? = nil
    ) async throws -> CompleteResponse {
        let request = CompleteRequest(
            model: model,
            prompt: prompt,
            maxTokensToSample: maxTokensToSample,
            stopSequences: stopSequences,
            temperature: temperature
        )
        return try await complete(request)
    }
}