import Foundation

// MARK: - API Key Information

/// API key information
public struct APIKeyInfo: Codable {
    /// The redacted API key
    public let redactedAPIKey: String
    
    /// User ID the API key belongs to
    public let userId: String
    
    /// The name of the API key specified by user
    public let name: String
    
    /// Creation time of the API key in Unix timestamp
    public let createTime: String
    
    /// Last modification time of the API key in Unix timestamp
    public let modifyTime: String
    
    /// User ID of the user who last modified the API key
    public let modifiedBy: String
    
    /// The team ID of the team that owns the API key
    public let teamId: String
    
    /// A list of ACLs authorized with the API key
    public let acls: [String]
    
    /// ID of the API key
    public let apiKeyId: String
    
    /// Indicates whether the team that owns the API key is blocked
    public let teamBlocked: Bool
    
    /// Indicates whether the API key is blocked
    public let apiKeyBlocked: Bool
    
    /// Indicates whether the API key is disabled
    public let apiKeyDisabled: Bool
    
    enum CodingKeys: String, CodingKey {
        case redactedAPIKey = "redacted_api_key"
        case userId = "user_id"
        case name
        case createTime = "create_time"
        case modifyTime = "modify_time"
        case modifiedBy = "modified_by"
        case teamId = "team_id"
        case acls
        case apiKeyId = "api_key_id"
        case teamBlocked = "team_blocked"
        case apiKeyBlocked = "api_key_blocked"
        case apiKeyDisabled = "api_key_disabled"
    }
}