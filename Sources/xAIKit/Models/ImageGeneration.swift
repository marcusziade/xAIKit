import Foundation

// MARK: - Image Generation Request

/// Request for generating images
public struct ImageGenerationRequest: Codable {
    /// A text description of the desired image(s)
    public let prompt: String
    
    /// The model to use for image generation
    public let model: String
    
    /// The number of images to generate (Note: May not be supported by xAI API)
    public let n: Int?
    
    /// The quality of the image that will be generated (Note: May not be supported by xAI API)
    public let quality: ImageQuality?
    
    /// The format in which the generated images are returned (Note: May not be supported by xAI API)
    public let responseFormat: ImageResponseFormat?
    
    /// The size of the generated images (Note: May not be supported by xAI API)
    public let size: ImageSize?
    
    /// The style of the generated images (Note: May not be supported by xAI API)
    public let style: ImageStyle?
    
    /// A unique identifier representing your end-user (Note: May not be supported by xAI API)
    public let user: String?
    
    enum CodingKeys: String, CodingKey {
        case prompt, model, n, quality
        case responseFormat = "response_format"
        case size, style, user
    }
    
    public init(
        prompt: String,
        model: String,
        n: Int? = nil,
        quality: ImageQuality? = nil,
        responseFormat: ImageResponseFormat? = nil,
        size: ImageSize? = nil,
        style: ImageStyle? = nil,
        user: String? = nil
    ) {
        self.prompt = prompt
        self.model = model
        self.n = n
        self.quality = quality
        self.responseFormat = responseFormat
        self.size = size
        self.style = style
        self.user = user
    }
    
    /// Create a minimal request with only supported xAI parameters
    public static func xai(prompt: String, model: String = "grok-2-image", n: Int? = nil, responseFormat: ImageResponseFormat? = nil) -> ImageGenerationRequest {
        return ImageGenerationRequest(
            prompt: prompt,
            model: model,
            n: n,
            quality: nil,
            responseFormat: responseFormat,
            size: nil,
            style: nil,
            user: nil
        )
    }
}

/// Image quality options
public enum ImageQuality: String, Codable {
    case standard
    case hd
}

/// Image response format options
public enum ImageResponseFormat: String, Codable {
    case url
    case b64Json = "b64_json"
}

/// Image size options
public enum ImageSize: String, Codable {
    case size256x256 = "256x256"
    case size512x512 = "512x512"
    case size1024x1024 = "1024x1024"
    case size1792x1024 = "1792x1024"
    case size1024x1792 = "1024x1792"
}

/// Image style options
public enum ImageStyle: String, Codable {
    case vivid
    case natural
}

// MARK: - Image Generation Response

/// Response from image generation endpoint
public struct ImageGenerationResponse: Codable {
    /// A list of generated image objects
    public let data: [GeneratedImage]
}

/// Generated image data
public struct GeneratedImage: Codable {
    /// The URL of the generated image
    public let url: String?
    
    /// The base64-encoded JSON of the generated image
    public let b64Json: String?
    
    /// The prompt that was used to generate the image
    public let revisedPrompt: String?
    
    enum CodingKeys: String, CodingKey {
        case url
        case b64Json = "b64_json"
        case revisedPrompt = "revised_prompt"
    }
}