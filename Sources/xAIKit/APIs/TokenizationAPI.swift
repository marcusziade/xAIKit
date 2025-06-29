import Foundation

/// API for text tokenization
public final class TokenizationAPI {
    private let client: HTTPClientProtocol
    private let configuration: xAIConfiguration
    
    init(client: HTTPClientProtocol, configuration: xAIConfiguration) {
        self.client = client
        self.configuration = configuration
    }
    
    /// Tokenize text
    /// - Parameter request: The tokenization request
    /// - Returns: The tokenization response
    public func tokenize(_ request: TokenizeTextRequest) async throws -> TokenizeTextResponse {
        let url = configuration.apiBaseURL.appendingPathComponent("/v1/tokenize-text")
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
    
    /// Convenience method to tokenize text
    /// - Parameters:
    ///   - text: Text to tokenize
    ///   - model: Model to use for tokenization
    ///   - allowedSpecial: Allowed special tokens
    ///   - disallowedSpecial: Disallowed special tokens
    /// - Returns: The tokenization response
    public func tokenize(
        text: String,
        model: String,
        allowedSpecial: [String]? = nil,
        disallowedSpecial: [String]? = nil
    ) async throws -> TokenizeTextResponse {
        let request = TokenizeTextRequest(
            text: text,
            model: model,
            allowedSpecial: allowedSpecial,
            disallowedSpecial: disallowedSpecial
        )
        return try await tokenize(request)
    }
    
    /// Get just the token IDs for text
    /// - Parameters:
    ///   - text: Text to tokenize
    ///   - model: Model to use for tokenization
    /// - Returns: Array of token IDs
    public func getTokenIds(
        text: String,
        model: String
    ) async throws -> [Int] {
        let response = try await tokenize(text: text, model: model)
        return response.tokenIds.map { $0.tokenId }
    }
    
    /// Count tokens in text
    /// - Parameters:
    ///   - text: Text to tokenize
    ///   - model: Model to use for tokenization
    /// - Returns: Number of tokens
    public func countTokens(
        text: String,
        model: String
    ) async throws -> Int {
        let response = try await tokenize(text: text, model: model)
        return response.tokenIds.count
    }
}