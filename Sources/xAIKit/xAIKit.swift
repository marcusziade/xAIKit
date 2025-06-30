import Foundation

/// The main entry point for the xAI API Swift SDK.
///
/// xAIKit provides a comprehensive, type-safe Swift interface to xAI's complete API suite,
/// empowering developers to integrate cutting-edge AI capabilities into their applications
/// across all Apple platforms.
///
/// ## Overview
///
/// xAIKit supports:
/// - **Chat Completions**: Conversational AI with Grok models
/// - **Messages API**: Anthropic-compatible message handling
/// - **Image Generation**: Create images from text descriptions
/// - **Structured Outputs**: JSON schema validation for reliable responses
/// - **Function Calling**: Enable AI to interact with your code
/// - **Streaming**: Real-time response streaming
/// - **Multi-modal Input**: Combine text and images
///
/// ## Getting Started
///
/// Initialize the client with your API key:
/// ```swift
/// import xAIKit
///
/// // Basic initialization
/// let client = xAIClient(apiKey: "your-api-key")
///
/// // Advanced configuration
/// let config = xAIConfiguration(
///     apiKey: "your-api-key",
///     defaultModel: .grokBeta,
///     timeoutInterval: 60.0
/// )
/// let client = xAIClient(configuration: config)
/// ```
///
/// ## Making Requests
///
/// The client provides intuitive methods for each API endpoint:
/// ```swift
/// // Chat completion
/// let chatRequest = ChatRequest(
///     model: .grokBeta,
///     messages: [
///         Message(role: .system, content: "You are a helpful assistant."),
///         Message(role: .user, content: "Explain quantum computing")
///     ]
/// )
/// let response = try await client.chat.completions(chatRequest)
///
/// // Streaming responses
/// for try await chunk in client.chat.stream(chatRequest) {
///     print(chunk.choices.first?.delta?.content ?? "", terminator: "")
/// }
///
/// // Image generation
/// let images = try await client.images.generate(
///     prompt: "A futuristic city at sunset",
///     model: .grok2Image
/// )
/// ```
///
/// ## Error Handling
///
/// xAIKit provides comprehensive error handling:
/// ```swift
/// do {
///     let response = try await client.chat.completions(request)
/// } catch let error as xAIError {
///     switch error {
///     case .invalidAPIKey:
///         print("Invalid API key")
///     case .rateLimitExceeded(let retryAfter):
///         print("Rate limited. Retry after \(retryAfter ?? 0) seconds")
///     case .networkError(let underlying):
///         print("Network error: \(underlying)")
///     default:
///         print("Error: \(error)")
///     }
/// }
/// ```
///
/// ## Platform Support
///
/// xAIKit runs on:
/// - iOS 16.0+
/// - macOS 13.0+
/// - watchOS 9.0+
/// - tvOS 16.0+
/// - visionOS 1.0+
///
/// ## Topics
///
/// ### Essential Components
/// - ``xAIClient``
/// - ``xAIConfiguration``
/// - ``xAIError``
///
/// ### API References
/// - ``ChatAPI``
/// - ``MessagesAPI``
/// - ``ImagesAPI``
/// - ``ModelsAPI``
/// - ``TokenizationAPI``
public struct xAIKit {
    /// The current version of xAIKit.
    ///
    /// This follows semantic versioning (SemVer) conventions:
    /// - MAJOR version for incompatible API changes
    /// - MINOR version for backwards-compatible functionality additions
    /// - PATCH version for backwards-compatible bug fixes
    public static let version = "1.0.0"
    
    /// The default API base URL for xAI's main API endpoints.
    ///
    /// This URL is used for:
    /// - Chat completions
    /// - Messages API
    /// - Image generation
    /// - Model listings
    ///
    /// You can override this in ``xAIConfiguration`` if needed.
    public static let defaultAPIBaseURL = "https://api.x.ai"
    
    /// The default management API base URL for administrative operations.
    ///
    /// This URL is used for:
    /// - API key validation
    /// - Permission checks
    /// - Usage monitoring
    ///
    /// You can override this in ``xAIConfiguration`` if needed.
    public static let defaultManagementAPIBaseURL = "https://management-api.x.ai"
    
    /// Environment variable name for the API key.
    ///
    /// Set this in your environment to avoid hardcoding API keys:
    /// ```bash
    /// export XAI_API_KEY="your-api-key-here"
    /// ```
    ///
    /// Then use it in your code:
    /// ```swift
    /// let apiKey = ProcessInfo.processInfo.environment[xAIKit.apiKeyEnvironmentVariable]
    /// ```
    public static let apiKeyEnvironmentVariable = "XAI_API_KEY"
    
    /// User agent string sent with all API requests.
    ///
    /// This helps xAI track SDK usage and provide better support.
    public static let userAgent = "xAIKit/\(version) Swift"
}