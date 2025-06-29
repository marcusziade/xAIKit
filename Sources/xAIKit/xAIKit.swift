import Foundation

/// The main entry point for the xAI API Swift SDK.
///
/// xAIKit provides a comprehensive Swift interface to the xAI API, supporting all major endpoints
/// including chat completions, image generation, and model management.
///
/// ## Getting Started
///
/// Initialize the client with your API key:
/// ```swift
/// let client = xAIClient(apiKey: "your-api-key")
/// ```
///
/// ## Making Requests
///
/// The client provides dedicated methods for each API endpoint:
/// ```swift
/// // Chat completion
/// let response = try await client.chat.completions(messages: [...])
///
/// // Image generation
/// let images = try await client.images.generate(prompt: "A sunset over mountains")
/// ```
public struct xAIKit {
    /// The current version of xAIKit
    public static let version = "1.0.0"
    
    /// The default API base URL
    public static let defaultAPIBaseURL = "https://api.x.ai"
    
    /// The default management API base URL
    public static let defaultManagementAPIBaseURL = "https://management-api.x.ai"
}