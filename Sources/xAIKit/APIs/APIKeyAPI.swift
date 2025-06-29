import Foundation

/// API for API key information
public final class APIKeyAPI {
    private let client: HTTPClientProtocol
    private let configuration: xAIConfiguration
    
    init(client: HTTPClientProtocol, configuration: xAIConfiguration) {
        self.client = client
        self.configuration = configuration
    }
    
    /// Get information about the current API key
    /// - Returns: API key information
    public func getInfo() async throws -> APIKeyInfo {
        let url = configuration.apiBaseURL.appendingPathComponent("/v1/api-key")
        
        let httpRequest = HTTPRequest(
            method: .get,
            url: url,
            timeoutInterval: configuration.timeoutInterval
        )
        
        return try await client.sendRequest(httpRequest)
    }
    
    /// Check if the API key is valid
    /// - Returns: True if the API key is valid and active
    public func isValid() async -> Bool {
        do {
            let info = try await getInfo()
            return !info.apiKeyBlocked && !info.apiKeyDisabled && !info.teamBlocked
        } catch {
            return false
        }
    }
    
    /// Get the permissions (ACLs) for the current API key
    /// - Returns: Array of permission strings
    public func getPermissions() async throws -> [String] {
        let info = try await getInfo()
        return info.acls
    }
}