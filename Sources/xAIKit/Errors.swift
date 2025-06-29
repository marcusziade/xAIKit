import Foundation

/// Errors that can occur when using the xAI API
public enum xAIError: LocalizedError {
    /// Invalid API key provided
    case invalidAPIKey
    
    /// Network error occurred
    case networkError(Error)
    
    /// Invalid request parameters
    case invalidRequest(String)
    
    /// API returned an error response
    case apiError(statusCode: Int, message: String)
    
    /// Failed to decode response
    case decodingError(Error)
    
    /// Streaming error
    case streamingError(String)
    
    /// Timeout error
    case timeout
    
    /// Rate limit exceeded
    case rateLimitExceeded(retryAfter: Int?)
    
    /// Invalid response format
    case invalidResponse
    
    /// Missing required parameter
    case missingParameter(String)
    
    /// Unsupported operation
    case unsupportedOperation(String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidAPIKey:
            return "Invalid API key provided"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidRequest(let message):
            return "Invalid request: \(message)"
        case .apiError(let statusCode, let message):
            return "API error (status \(statusCode)): \(message)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .streamingError(let message):
            return "Streaming error: \(message)"
        case .timeout:
            return "Request timed out"
        case .rateLimitExceeded(let retryAfter):
            if let retryAfter = retryAfter {
                return "Rate limit exceeded. Retry after \(retryAfter) seconds"
            }
            return "Rate limit exceeded"
        case .invalidResponse:
            return "Invalid response format"
        case .missingParameter(let parameter):
            return "Missing required parameter: \(parameter)"
        case .unsupportedOperation(let operation):
            return "Unsupported operation: \(operation)"
        }
    }
}

/// Error response from the API
public struct APIErrorResponse: Codable {
    public let error: APIErrorDetail
}

/// Details of an API error
public struct APIErrorDetail: Codable {
    public let message: String
    public let type: String?
    public let code: String?
}