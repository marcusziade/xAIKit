import Foundation

/// Image generation API for creating AI-generated images from text descriptions.
///
/// `ImagesAPI` provides access to xAI's powerful image generation capabilities,
/// allowing you to create high-quality images from text prompts using the Grok-2
/// image model.
///
/// ## Features
///
/// - **Text-to-Image Generation**: Create images from natural language descriptions
/// - **Multiple Images**: Generate up to multiple images in a single request
/// - **URL-Based Delivery**: Images are returned as URLs for easy integration
/// - **Grok-2 Image Model**: Access to xAI's advanced image generation model
///
/// ## Basic Usage
///
/// ```swift
/// let client = xAIClient(apiKey: "your-api-key")
///
/// // Generate a single image
/// let imageURL = try await client.images.generateImageURL(
///     prompt: "A futuristic city with flying cars at sunset"
/// )
///
/// // Generate multiple images
/// let response = try await client.images.generate(
///     prompt: "A serene mountain landscape",
///     n: 3
/// )
/// for image in response.data {
///     print("Image URL: \(image.url ?? "")")
/// }
/// ```
///
/// ## Image Quality Tips
///
/// For best results:
/// - Be specific and descriptive in your prompts
/// - Include style references (e.g., "oil painting", "photorealistic")
/// - Specify lighting, mood, and composition
/// - Use clear, grammatically correct descriptions
///
/// ## Limitations
///
/// - Images are returned as URLs, not base64 data
/// - URLs may have limited lifetime - download promptly
/// - Content policies apply to generated images
public final class ImagesAPI {
    private let client: HTTPClientProtocol
    private let configuration: xAIConfiguration
    
    init(client: HTTPClientProtocol, configuration: xAIConfiguration) {
        self.client = client
        self.configuration = configuration
    }
    
    /// Generate images from text descriptions.
    ///
    /// This method sends a request to generate one or more images based on the
    /// provided text prompt and parameters.
    ///
    /// - Parameter request: An ``ImageGenerationRequest`` containing:
    ///   - `prompt`: Text description of the desired image(s)
    ///   - `model`: The model to use (e.g., "grok-2-image")
    ///   - `n`: Number of images to generate (optional)
    ///   - `responseFormat`: Format for the response (currently only URL supported)
    ///
    /// - Returns: An ``ImageGenerationResponse`` containing:
    ///   - Array of generated images with URLs
    ///   - Creation timestamp
    ///
    /// - Throws: ``xAIError`` for various error conditions:
    ///   - `.invalidAPIKey`: Invalid or missing API key
    ///   - `.rateLimitExceeded`: API rate limit reached
    ///   - `.contentPolicyViolation`: Prompt violates content policy
    ///   - `.networkError`: Network connectivity issues
    ///
    /// ## Example
    /// ```swift
    /// let request = ImageGenerationRequest(
    ///     prompt: "A cyberpunk street scene with neon lights",
    ///     model: "grok-2-image",
    ///     n: 2
    /// )
    ///
    /// do {
    ///     let response = try await client.images.generate(request)
    ///     for (index, image) in response.data.enumerated() {
    ///         print("Image \(index + 1): \(image.url ?? "")")
    ///     }
    /// } catch {
    ///     print("Generation failed: \(error)")
    /// }
    /// ```
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
    
    /// Convenience method for generating images with simplified parameters.
    ///
    /// This method provides a streamlined interface for image generation without
    /// needing to construct a full request object.
    ///
    /// - Parameters:
    ///   - prompt: Text description of the desired image(s). Be specific and descriptive.
    ///   - model: The model to use for generation (defaults to "grok-2-image")
    ///   - n: Number of images to generate (1-4, defaults to 1)
    ///   - responseFormat: Response format - currently only `.url` is supported
    ///
    /// - Returns: An ``ImageGenerationResponse`` with generated images
    ///
    /// - Throws: ``xAIError`` for API errors
    ///
    /// ## Example
    /// ```swift
    /// // Generate a single image
    /// let response = try await client.images.generate(
    ///     prompt: "A peaceful zen garden with cherry blossoms"
    /// )
    ///
    /// // Generate multiple variations
    /// let variations = try await client.images.generate(
    ///     prompt: "Abstract art representing artificial intelligence",
    ///     n: 3
    /// )
    /// ```
    ///
    /// ## Prompt Engineering Tips
    /// - **Style**: "in the style of [artist/movement]"
    /// - **Medium**: "oil painting", "digital art", "photograph"
    /// - **Lighting**: "golden hour", "dramatic lighting", "soft diffused light"
    /// - **Composition**: "wide angle", "close-up", "aerial view"
    public func generate(
        prompt: String,
        model: String = "grok-2-image",
        n: Int? = nil,
        responseFormat: ImageResponseFormat? = nil
    ) async throws -> ImageGenerationResponse {
        let request = ImageGenerationRequest.xai(prompt: prompt, model: model, n: n, responseFormat: responseFormat)
        return try await generate(request)
    }
    
    /// Generate a single image and return its URL directly.
    ///
    /// This is the simplest method for generating an image when you only need
    /// one image and want the URL directly.
    ///
    /// - Parameters:
    ///   - prompt: Text description of the desired image
    ///   - model: The model to use (defaults to "grok-2-image")
    ///
    /// - Returns: A `String` containing the URL of the generated image
    ///
    /// - Throws:
    ///   - ``xAIError.invalidResponse``: If no image was generated
    ///   - Other ``xAIError`` types for API errors
    ///
    /// ## Example
    /// ```swift
    /// do {
    ///     let imageURL = try await client.images.generateImageURL(
    ///         prompt: "A majestic eagle soaring over mountains"
    ///     )
    ///     print("Generated image: \(imageURL)")
    ///     
    ///     // Download and display the image in your app
    ///     if let url = URL(string: imageURL) {
    ///         let (data, _) = try await URLSession.shared.data(from: url)
    ///         let image = UIImage(data: data)
    ///         // Use the image in your UI
    ///     }
    /// } catch {
    ///     print("Failed to generate image: \(error)")
    /// }
    /// ```
    ///
    /// - Important: Image URLs may expire. Download images promptly after generation.
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
    
    /// Attempt to generate an image and return it as base64 data.
    ///
    /// - Parameters:
    ///   - prompt: Text description of the desired image
    ///   - model: The model to use (defaults to "grok-2-image")
    ///
    /// - Returns: The base64-encoded image data (if supported)
    ///
    /// - Throws:
    ///   - ``xAIError.unsupportedOperation``: xAI API returns URLs, not base64
    ///   - ``xAIError.invalidResponse``: If no image was generated
    ///   - Other ``xAIError`` types for API errors
    ///
    /// - Warning: xAI's image API currently returns URLs rather than base64 data.
    ///   This method will throw an error indicating the URL that was returned.
    ///   To get image data, download from the returned URL instead.
    ///
    /// ## Alternative Approach
    /// ```swift
    /// // Since xAI returns URLs, download the image data instead:
    /// let imageURL = try await client.images.generateImageURL(prompt: prompt)
    /// if let url = URL(string: imageURL) {
    ///     let (data, _) = try await URLSession.shared.data(from: url)
    ///     let base64String = data.base64EncodedString()
    ///     // Use base64String as needed
    /// }
    /// ```
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