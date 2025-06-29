import Foundation

/// Configuration for the xAI API client.
public struct xAIConfiguration {
    /// The API key used for authentication
    public let apiKey: String
    
    /// The base URL for the API
    public let apiBaseURL: URL
    
    /// The base URL for the management API
    public let managementAPIBaseURL: URL
    
    /// Timeout interval for requests (in seconds)
    public let timeoutInterval: TimeInterval
    
    /// Whether to use streaming for supported endpoints
    public let useStreaming: Bool
    
    /// Custom headers to include with all requests
    public let customHeaders: [String: String]
    
    /// Initialize a new configuration
    /// - Parameters:
    ///   - apiKey: Your xAI API key
    ///   - apiBaseURL: The base URL for the API (defaults to https://api.x.ai)
    ///   - managementAPIBaseURL: The base URL for the management API (defaults to https://management-api.x.ai)
    ///   - timeoutInterval: Request timeout in seconds (defaults to 60)
    ///   - useStreaming: Whether to use streaming for supported endpoints (defaults to false)
    ///   - customHeaders: Additional headers to include with all requests
    public init(
        apiKey: String,
        apiBaseURL: URL = URL(string: xAIKit.defaultAPIBaseURL)!,
        managementAPIBaseURL: URL = URL(string: xAIKit.defaultManagementAPIBaseURL)!,
        timeoutInterval: TimeInterval = 60,
        useStreaming: Bool = false,
        customHeaders: [String: String] = [:]
    ) {
        self.apiKey = apiKey
        self.apiBaseURL = apiBaseURL
        self.managementAPIBaseURL = managementAPIBaseURL
        self.timeoutInterval = timeoutInterval
        self.useStreaming = useStreaming
        self.customHeaders = customHeaders
    }
}