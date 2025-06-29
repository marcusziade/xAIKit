import Foundation

/// API for image generation
public final class ImagesAPI {
    private let client: HTTPClientProtocol
    private let configuration: xAIConfiguration
    
    init(client: HTTPClientProtocol, configuration: xAIConfiguration) {
        self.client = client
        self.configuration = configuration
    }
    
    /// Generate images
    /// - Parameter request: The image generation request
    /// - Returns: The image generation response
    public func generate(_ request: ImageGenerationRequest) async throws -> ImageGenerationResponse {
        let url = configuration.apiBaseURL.appendingPathComponent("/v1/images/generations")
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let body = try encoder.encode(request)
        
        
        let httpRequest = HTTPRequest(
            method: .post,
            url: url,
            body: body,
            timeoutInterval: configuration.timeoutInterval
        )
        
        return try await client.sendRequest(httpRequest)
    }
    
    /// Convenience method to generate images
    /// - Parameters:
    ///   - prompt: Text description of the desired image(s)
    ///   - model: The model to use for generation (defaults to "grok-2-image")
    ///   - n: Number of images to generate
    ///   - responseFormat: Response format (url or b64_json)
    /// - Returns: The image generation response
    public func generate(
        prompt: String,
        model: String = "grok-2-image",
        n: Int? = nil,
        responseFormat: ImageResponseFormat? = nil
    ) async throws -> ImageGenerationResponse {
        let request = ImageGenerationRequest.xai(prompt: prompt, model: model, n: n, responseFormat: responseFormat)
        return try await generate(request)
    }
    
    /// Generate a single image and return its URL
    /// - Parameters:
    ///   - prompt: Text description of the desired image
    ///   - model: The model to use (defaults to "grok-2-image")
    /// - Returns: The URL of the generated image
    public func generateImageURL(
        prompt: String,
        model: String = "grok-2-image"
    ) async throws -> String {
        let response = try await generate(prompt: prompt, model: model)
        
        guard let firstImage = response.data.first,
              let url = firstImage.url else {
            throw xAIError.invalidResponse
        }
        
        return url
    }
    
    /// Generate a single image and return it as base64
    /// - Parameters:
    ///   - prompt: Text description of the desired image
    ///   - model: The model to use (defaults to "grok-2-image")
    /// - Returns: The base64-encoded image data
    /// - Note: xAI API may not support base64 response format
    public func generateImageBase64(
        prompt: String,
        model: String = "grok-2-image"
    ) async throws -> String {
        // Note: xAI API may only return URLs, not base64
        let response = try await generate(prompt: prompt, model: model)
        
        guard let firstImage = response.data.first else {
            throw xAIError.invalidResponse
        }
        
        if let b64 = firstImage.b64Json {
            return b64
        } else if let url = firstImage.url {
            // xAI API returns URLs, not base64
            throw xAIError.unsupportedOperation("xAI API returns image URLs, not base64. URL: \(url)")
        } else {
            throw xAIError.invalidResponse
        }
    }
}