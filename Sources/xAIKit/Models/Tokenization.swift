import Foundation

// MARK: - Tokenization

/// Request for tokenizing text
public struct TokenizeTextRequest: Codable {
    /// Text to tokenize
    public let text: String
    
    /// Which model to use for tokenization
    public let model: String
    
    /// Allowed special tokens
    public let allowedSpecial: [String]?
    
    /// Disallowed special tokens
    public let disallowedSpecial: [String]?
    
    enum CodingKeys: String, CodingKey {
        case text, model
        case allowedSpecial = "allowed_special"
        case disallowedSpecial = "disallowed_special"
    }
    
    public init(
        text: String,
        model: String,
        allowedSpecial: [String]? = nil,
        disallowedSpecial: [String]? = nil
    ) {
        self.text = text
        self.model = model
        self.allowedSpecial = allowedSpecial
        self.disallowedSpecial = disallowedSpecial
    }
}

/// Response from tokenization endpoint
public struct TokenizeTextResponse: Codable {
    /// A list of tokens
    public let tokenIds: [Token]
    
    enum CodingKeys: String, CodingKey {
        case tokenIds = "token_ids"
    }
}

/// Token information
public struct Token: Codable {
    /// The token ID
    public let tokenId: Int
    
    /// The string representation of the token
    public let stringToken: String
    
    /// The byte representation of the token
    public let tokenBytes: [Int]
    
    enum CodingKeys: String, CodingKey {
        case tokenId = "token_id"
        case stringToken = "string_token"
        case tokenBytes = "token_bytes"
    }
}