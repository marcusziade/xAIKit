import Foundation

/// API for model information
public final class ModelsAPI {
    private let client: HTTPClientProtocol
    private let configuration: xAIConfiguration
    
    init(client: HTTPClientProtocol, configuration: xAIConfiguration) {
        self.client = client
        self.configuration = configuration
    }
    
    /// List all available models
    /// - Returns: List of models
    public func list() async throws -> [Model] {
        let url = configuration.apiBaseURL.appendingPathComponent("/v1/models")
        
        let httpRequest = HTTPRequest(
            method: .get,
            url: url,
            timeoutInterval: configuration.timeoutInterval
        )
        
        let response: ModelsResponse = try await client.sendRequest(httpRequest)
        return response.data
    }
    
    /// Get information about a specific model
    /// - Parameter modelId: The ID of the model
    /// - Returns: Model information
    public func get(modelId: String) async throws -> Model {
        let url = configuration.apiBaseURL.appendingPathComponent("/v1/models/\(modelId)")
        
        let httpRequest = HTTPRequest(
            method: .get,
            url: url,
            timeoutInterval: configuration.timeoutInterval
        )
        
        return try await client.sendRequest(httpRequest)
    }
    
    /// List all language models with detailed information
    /// - Returns: List of language models
    public func listLanguageModels() async throws -> [LanguageModel] {
        let url = configuration.apiBaseURL.appendingPathComponent("/v1/language-models")
        
        let httpRequest = HTTPRequest(
            method: .get,
            url: url,
            timeoutInterval: configuration.timeoutInterval
        )
        
        let response: LanguageModelsResponse = try await client.sendRequest(httpRequest)
        return response.models
    }
    
    /// Get detailed information about a specific language model
    /// - Parameter modelId: The ID of the model
    /// - Returns: Language model information
    public func getLanguageModel(modelId: String) async throws -> LanguageModel {
        let url = configuration.apiBaseURL.appendingPathComponent("/v1/language-models/\(modelId)")
        
        let httpRequest = HTTPRequest(
            method: .get,
            url: url,
            timeoutInterval: configuration.timeoutInterval
        )
        
        return try await client.sendRequest(httpRequest)
    }
    
    /// List all image generation models with detailed information
    /// - Returns: List of image generation models
    public func listImageGenerationModels() async throws -> [ImageGenerationModel] {
        let url = configuration.apiBaseURL.appendingPathComponent("/v1/image-generation-models")
        
        let httpRequest = HTTPRequest(
            method: .get,
            url: url,
            timeoutInterval: configuration.timeoutInterval
        )
        
        let response: ImageGenerationModelsResponse = try await client.sendRequest(httpRequest)
        return response.models
    }
    
    /// Get detailed information about a specific image generation model
    /// - Parameter modelId: The ID of the model
    /// - Returns: Image generation model information
    public func getImageGenerationModel(modelId: String) async throws -> ImageGenerationModel {
        let url = configuration.apiBaseURL.appendingPathComponent("/v1/image-generation-models/\(modelId)")
        
        let httpRequest = HTTPRequest(
            method: .get,
            url: url,
            timeoutInterval: configuration.timeoutInterval
        )
        
        return try await client.sendRequest(httpRequest)
    }
}