import Foundation

/// The main client for interacting with the xAI API
public final class xAIClient {
    private let configuration: xAIConfiguration
    private let httpClient: HTTPClientProtocol
    
    /// Chat completions API
    public lazy var chat: ChatAPI = ChatAPI(client: httpClient, configuration: configuration)
    
    /// Messages API (Anthropic compatible)
    public lazy var messages: MessagesAPI = MessagesAPI(client: httpClient, configuration: configuration)
    
    /// Image generation API
    public lazy var images: ImagesAPI = ImagesAPI(client: httpClient, configuration: configuration)
    
    /// Models API
    public lazy var models: ModelsAPI = ModelsAPI(client: httpClient, configuration: configuration)
    
    /// Tokenization API
    public lazy var tokenization: TokenizationAPI = TokenizationAPI(client: httpClient, configuration: configuration)
    
    /// API key information
    public lazy var apiKey: APIKeyAPI = APIKeyAPI(client: httpClient, configuration: configuration)
    
    /// Legacy completions API
    public lazy var completions: CompletionsAPI = CompletionsAPI(client: httpClient, configuration: configuration)
    
    /// Initialize a new xAI client
    /// - Parameter configuration: Client configuration
    public init(configuration: xAIConfiguration) {
        self.configuration = configuration
        self.httpClient = xAIHTTPClient(configuration: configuration)
    }
    
    /// Initialize a new xAI client with an API key
    /// - Parameters:
    ///   - apiKey: Your xAI API key
    ///   - apiBaseURL: Optional custom API base URL
    ///   - managementAPIBaseURL: Optional custom management API base URL
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