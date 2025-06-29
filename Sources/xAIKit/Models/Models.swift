import Foundation

// MARK: - Model Information

/// Basic model information
public struct Model: Codable {
    /// Model ID
    public let id: String
    
    /// Model creation time in Unix timestamp
    public let created: Int
    
    /// The object type
    public let object: String
    
    /// Owner of the model
    public let ownedBy: String
    
    enum CodingKeys: String, CodingKey {
        case id, created, object
        case ownedBy = "owned_by"
    }
}

/// List of models response
public struct ModelsResponse: Codable {
    /// The object type of data field
    public let object: String
    
    /// A list of models with minimalized information
    public let data: [Model]
}

// MARK: - Language Model Information

/// Detailed language model information
public struct LanguageModel: Codable {
    /// Model ID
    public let id: String
    
    /// Fingerprint of the xAI system configuration
    public let fingerprint: String?
    
    /// Creation time of the model in Unix timestamp
    public let created: Int
    
    /// The object type
    public let object: String
    
    /// Owner of the model
    public let ownedBy: String
    
    /// Version of the model
    public let version: String?
    
    /// The input modalities supported by the model
    public let inputModalities: [String]?
    
    /// The output modalities supported by the model
    public let outputModalities: [String]?
    
    /// Price of the prompt text token in USD cents per 100 million tokens
    public let promptTextTokenPrice: Int?
    
    /// Price of cached prompt text token
    public let cachedPromptTextTokenPrice: Int?
    
    /// Price of the prompt image token
    public let promptImageTokenPrice: Int?
    
    /// Price of the completion text token
    public let completionTextTokenPrice: Int?
    
    /// Price of the search
    public let searchPrice: Int?
    
    /// Alias ID(s) of the model
    public let aliases: [String]?
    
    enum CodingKeys: String, CodingKey {
        case id, fingerprint, created, object
        case ownedBy = "owned_by"
        case version
        case inputModalities = "input_modalities"
        case outputModalities = "output_modalities"
        case promptTextTokenPrice = "prompt_text_token_price"
        case cachedPromptTextTokenPrice = "cached_prompt_text_token_price"
        case promptImageTokenPrice = "prompt_image_token_price"
        case completionTextTokenPrice = "completion_text_token_price"
        case searchPrice = "search_price"
        case aliases
    }
}

/// Language models response
public struct LanguageModelsResponse: Codable {
    /// Array of available language models
    public let models: [LanguageModel]
}

// MARK: - Image Generation Model Information

/// Detailed image generation model information
public struct ImageGenerationModel: Codable {
    /// Model ID
    public let id: String
    
    /// Fingerprint of the xAI system configuration
    public let fingerprint: String?
    
    /// Maximum prompt length
    public let maxPromptLength: Int?
    
    /// Model creation time in Unix timestamp
    public let created: Int
    
    /// The object type
    public let object: String
    
    /// Owner of the model
    public let ownedBy: String
    
    /// Version of the model
    public let version: String?
    
    /// Price of the prompt text token
    public let promptTextTokenPrice: Int?
    
    /// Price of the prompt image token
    public let promptImageTokenPrice: Int?
    
    /// Price of the generated image token
    public let generatedImageTokenPrice: Int?
    
    /// Price of a single image in USD cents
    public let imagePrice: Int?
    
    /// Alias ID(s) of the model
    public let aliases: [String]?
    
    enum CodingKeys: String, CodingKey {
        case id, fingerprint
        case maxPromptLength = "max_prompt_length"
        case created, object
        case ownedBy = "owned_by"
        case version
        case promptTextTokenPrice = "prompt_text_token_price"
        case promptImageTokenPrice = "prompt_image_token_price"
        case generatedImageTokenPrice = "generated_image_token_price"
        case imagePrice = "image_price"
        case aliases
    }
}

/// Image generation models response
public struct ImageGenerationModelsResponse: Codable {
    /// Array of available image generation models
    public let models: [ImageGenerationModel]
}