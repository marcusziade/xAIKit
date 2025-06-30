import Foundation

/// The primary client for interacting with xAI's comprehensive API suite.
///
/// `xAIClient` serves as your gateway to all xAI API functionality, providing type-safe
/// access to chat completions, image generation, model management, and more.
///
/// ## Initialization
///
/// Create a client with your API key:
/// ```swift
/// // Simple initialization
/// let client = xAIClient(apiKey: "your-api-key")
///
/// // Advanced configuration
/// let config = xAIConfiguration(
///     apiKey: "your-api-key",
///     defaultModel: .grokBeta,
///     timeoutInterval: 60.0,
///     headers: ["X-Custom-Header": "value"]
/// )
/// let client = xAIClient(configuration: config)
/// ```
///
/// ## Available APIs
///
/// The client provides access to all xAI endpoints through dedicated API objects:
///
/// - ``chat``: Chat completions for conversational AI
/// - ``messages``: Anthropic-compatible message handling
/// - ``images``: AI-powered image generation
/// - ``models``: Model information and management
/// - ``tokenization``: Text tokenization utilities
/// - ``apiKey``: API key validation and permissions
/// - ``completions``: Legacy completions endpoint
///
/// ## Example Usage
///
/// ```swift
/// // Chat completion
/// let chatResponse = try await client.chat.completions(
///     ChatRequest(
///         model: .grokBeta,
///         messages: [Message(role: .user, content: "Hello!")]
///     )
/// )
///
/// // Image generation
/// let imageResponse = try await client.images.generate(
///     prompt: "A beautiful sunset",
///     model: .grok2Image
/// )
///
/// // List available models
/// let models = try await client.models.list()
/// ```
///
/// ## Thread Safety
///
/// `xAIClient` is thread-safe and can be shared across multiple concurrent operations.
/// The client uses `lazy` initialization for its API endpoints to optimize memory usage.
///
/// ## Best Practices
///
/// - Create a single client instance and reuse it throughout your application
/// - Store API keys securely using Keychain or environment variables
/// - Handle errors appropriately using xAIKit's comprehensive error types
/// - Monitor rate limits and implement retry logic when needed
public final class xAIClient {
    private let configuration: xAIConfiguration
    private let httpClient: HTTPClientProtocol
    
    /// Chat completions API for conversational AI interactions.
    ///
    /// Provides access to:
    /// - Standard chat completions
    /// - Streaming responses
    /// - Function calling
    /// - Structured outputs
    /// - Multi-modal conversations (text + images)
    public lazy var chat: ChatAPI = ChatAPI(client: httpClient, configuration: configuration)
    
    /// Messages API with Anthropic-compatible formatting.
    ///
    /// Offers:
    /// - Message-based conversations
    /// - System prompts
    /// - Advanced sampling parameters
    /// - Tool usage
    /// - Streaming support
    public lazy var messages: MessagesAPI = MessagesAPI(client: httpClient, configuration: configuration)
    
    /// Image generation API for creating images from text descriptions.
    ///
    /// Features:
    /// - Text-to-image generation
    /// - Multiple image generation
    /// - Grok-2 image model support
    /// - URL-based image delivery
    public lazy var images: ImagesAPI = ImagesAPI(client: httpClient, configuration: configuration)
    
    /// Models API for discovering and managing available AI models.
    ///
    /// Capabilities:
    /// - List all available models
    /// - Get detailed model information
    /// - Check model capabilities and pricing
    /// - Identify supported modalities
    public lazy var models: ModelsAPI = ModelsAPI(client: httpClient, configuration: configuration)
    
    /// Tokenization API for text analysis and token counting.
    ///
    /// Provides:
    /// - Text tokenization
    /// - Token counting
    /// - Token ID retrieval
    /// - Model-specific tokenization
    public lazy var tokenization: TokenizationAPI = TokenizationAPI(client: httpClient, configuration: configuration)
    
    /// API key management for validation and permission checking.
    ///
    /// Enables:
    /// - API key validation
    /// - Permission verification
    /// - Usage monitoring
    /// - Access control list (ACL) checking
    public lazy var apiKey: APIKeyAPI = APIKeyAPI(client: httpClient, configuration: configuration)
    
    /// Legacy completions API for backward compatibility.
    ///
    /// Supports:
    /// - OpenAI-style completions
    /// - Anthropic-style complete endpoint
    /// - Text completion without conversation context
    ///
    /// Note: Prefer using the modern ``chat`` API for new implementations.
    public lazy var completions: CompletionsAPI = CompletionsAPI(client: httpClient, configuration: configuration)
    
    /// Initialize a new xAI client with a custom configuration.
    ///
    /// Use this initializer when you need fine-grained control over client behavior.
    ///
    /// - Parameter configuration: A ``xAIConfiguration`` object containing all client settings
    ///
    /// - Note: The client retains the configuration and creates API endpoints lazily to optimize memory usage.
    public init(configuration: xAIConfiguration) {
        self.configuration = configuration
        self.httpClient = xAIHTTPClient(configuration: configuration)
    }
    
    /// Initialize a new xAI client with an API key and optional custom endpoints.
    ///
    /// This is the most common initialization method for quick setup.
    ///
    /// - Parameters:
    ///   - apiKey: Your xAI API key. Get one at https://x.ai/api
    ///   - apiBaseURL: Optional custom API base URL. Defaults to xAI's production endpoint
    ///   - managementAPIBaseURL: Optional custom management API base URL. Defaults to xAI's management endpoint
    ///
    /// - Important: Store API keys securely. Never commit them to source control.
    ///
    /// ## Example
    /// ```swift
    /// // Using environment variable (recommended)
    /// let apiKey = ProcessInfo.processInfo.environment["XAI_API_KEY"]!
    /// let client = xAIClient(apiKey: apiKey)
    ///
    /// // Custom endpoint (for enterprise or testing)
    /// let client = xAIClient(
    ///     apiKey: apiKey,
    ///     apiBaseURL: URL(string: "https://custom.api.endpoint")
    /// )
    /// ```
    public convenience init(
        apiKey: String,
        apiBaseURL: URL? = nil,
        managementAPIBaseURL: URL? = nil
    ) {
        let config = xAIConfiguration(
            apiKey: apiKey,
            apiBaseURL: apiBaseURL ?? URL(string: xAIKit.defaultAPIBaseURL)!,
            managementAPIBaseURL: managementAPIBaseURL ?? URL(string: xAIKit.defaultManagementAPIBaseURL)!
        )
        self.init(configuration: config)
    }
}