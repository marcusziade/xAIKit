import Foundation

// MARK: - Completions (Legacy)

/// Request for creating completions (OpenAI compatible legacy)
public struct CompletionsRequest: Codable {
    /// The prompt(s) to generate completions for
    public let prompt: CompletionPrompt
    
    /// ID of the model to use
    public let model: String
    
    /// Generates best_of completions server-side and returns the best
    public let bestOf: Int?
    
    /// Echo back the prompt in addition to the completion
    public let echo: Bool?
    
    /// Frequency penalty
    public let frequencyPenalty: Double?
    
    /// Modify the likelihood of specified tokens
    public let logitBias: [String: Double]?
    
    /// Include the log probabilities
    public let logprobs: Int?
    
    /// Maximum number of tokens to generate
    public let maxTokens: Int?
    
    /// How many completions to generate
    public let n: Int?
    
    /// Presence penalty
    public let presencePenalty: Double?
    
    /// Seed for deterministic generation
    public let seed: Int?
    
    /// Stop sequences
    public let stop: StopSequence?
    
    /// The suffix that comes after a completion
    public let suffix: String?
    
    /// Sampling temperature
    public let temperature: Double?
    
    /// Top-p sampling
    public let topP: Double?
    
    /// User identifier
    public let user: String?
    
    enum CodingKeys: String, CodingKey {
        case prompt, model
        case bestOf = "best_of"
        case echo
        case frequencyPenalty = "frequency_penalty"
        case logitBias = "logit_bias"
        case logprobs
        case maxTokens = "max_tokens"
        case n
        case presencePenalty = "presence_penalty"
        case seed, stop, suffix, temperature
        case topP = "top_p"
        case user
    }
    
    public init(
        prompt: CompletionPrompt,
        model: String,
        bestOf: Int? = nil,
        echo: Bool? = nil,
        frequencyPenalty: Double? = nil,
        logitBias: [String: Double]? = nil,
        logprobs: Int? = nil,
        maxTokens: Int? = nil,
        n: Int? = nil,
        presencePenalty: Double? = nil,
        seed: Int? = nil,
        stop: StopSequence? = nil,
        suffix: String? = nil,
        temperature: Double? = nil,
        topP: Double? = nil,
        user: String? = nil
    ) {
        self.prompt = prompt
        self.model = model
        self.bestOf = bestOf
        self.echo = echo
        self.frequencyPenalty = frequencyPenalty
        self.logitBias = logitBias
        self.logprobs = logprobs
        self.maxTokens = maxTokens
        self.n = n
        self.presencePenalty = presencePenalty
        self.seed = seed
        self.stop = stop
        self.suffix = suffix
        self.temperature = temperature
        self.topP = topP
        self.user = user
    }
}

/// Completion prompt types
public enum CompletionPrompt: Codable {
    case string(String)
    case stringArray([String])
    case tokenArray([Int])
    case tokenArrayArray([[Int]])
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let string = try? container.decode(String.self) {
            self = .string(string)
        } else if let stringArray = try? container.decode([String].self) {
            self = .stringArray(stringArray)
        } else if let tokenArray = try? container.decode([Int].self) {
            self = .tokenArray(tokenArray)
        } else if let tokenArrayArray = try? container.decode([[Int]].self) {
            self = .tokenArrayArray(tokenArrayArray)
        } else {
            throw DecodingError.typeMismatch(
                CompletionPrompt.self,
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Expected String, [String], [Int], or [[Int]]"
                )
            )
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let string):
            try container.encode(string)
        case .stringArray(let array):
            try container.encode(array)
        case .tokenArray(let array):
            try container.encode(array)
        case .tokenArrayArray(let array):
            try container.encode(array)
        }
    }
}

/// Response from completions endpoint
public struct CompletionsResponse: Codable {
    /// ID of the request
    public let id: String
    
    /// Object type of the response
    public let object: String
    
    /// Creation time in Unix timestamp
    public let created: Int
    
    /// Model used
    public let model: String
    
    /// List of completion choices
    public let choices: [CompletionChoice]
    
    /// Token usage information
    public let usage: ChatUsage
    
    /// System fingerprint
    public let systemFingerprint: String?
    
    enum CodingKeys: String, CodingKey {
        case id, object, created, model, choices, usage
        case systemFingerprint = "system_fingerprint"
    }
}

/// Completion choice
public struct CompletionChoice: Codable {
    /// The index of the choice
    public let index: Int
    
    /// The generated text
    public let text: String
    
    /// The reason the model stopped generating
    public let finishReason: CompletionFinishReason?
    
    /// Log probabilities
    public let logprobs: CompletionLogprobs?
    
    enum CodingKeys: String, CodingKey {
        case index, text
        case finishReason = "finish_reason"
        case logprobs
    }
}

/// Finish reasons for completions
public enum CompletionFinishReason: String, Codable {
    case stop
    case length
    case contentFilter = "content_filter"
}

/// Log probabilities for completions
public struct CompletionLogprobs: Codable {
    public let tokens: [String]
    public let tokenLogprobs: [Double]
    public let topLogprobs: [[String: Double]]?
    public let textOffset: [Int]
    
    enum CodingKeys: String, CodingKey {
        case tokens
        case tokenLogprobs = "token_logprobs"
        case topLogprobs = "top_logprobs"
        case textOffset = "text_offset"
    }
}

// MARK: - Complete (Anthropic compatible legacy)

/// Request for complete endpoint (Anthropic compatible)
public struct CompleteRequest: Codable {
    /// The model that will complete your prompt
    public let model: String
    
    /// The prompt that you want to complete
    public let prompt: String
    
    /// The maximum number of tokens to generate
    public let maxTokensToSample: Int
    
    /// Sequences that will cause the model to stop generating
    public let stopSequences: [String]?
    
    /// Amount of randomness injected into the response
    public let temperature: Double?
    
    /// Use nucleus sampling
    public let topP: Double?
    
    /// Only sample from the top K options
    public let topK: Int?
    
    /// An object describing metadata about the request
    public let metadata: [String: Any]?
    
    /// Whether to incrementally stream the response
    public let stream: Bool?
    
    enum CodingKeys: String, CodingKey {
        case model, prompt
        case maxTokensToSample = "max_tokens_to_sample"
        case stopSequences = "stop_sequences"
        case temperature
        case topP = "top_p"
        case topK = "top_k"
        case metadata, stream
    }
    
    public init(
        model: String,
        prompt: String,
        maxTokensToSample: Int,
        stopSequences: [String]? = nil,
        temperature: Double? = nil,
        topP: Double? = nil,
        topK: Int? = nil,
        metadata: [String: Any]? = nil,
        stream: Bool? = nil
    ) {
        self.model = model
        self.prompt = prompt
        self.maxTokensToSample = maxTokensToSample
        self.stopSequences = stopSequences
        self.temperature = temperature
        self.topP = topP
        self.topK = topK
        self.metadata = metadata
        self.stream = stream
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        model = try container.decode(String.self, forKey: .model)
        prompt = try container.decode(String.self, forKey: .prompt)
        maxTokensToSample = try container.decode(Int.self, forKey: .maxTokensToSample)
        stopSequences = try container.decodeIfPresent([String].self, forKey: .stopSequences)
        temperature = try container.decodeIfPresent(Double.self, forKey: .temperature)
        topP = try container.decodeIfPresent(Double.self, forKey: .topP)
        topK = try container.decodeIfPresent(Int.self, forKey: .topK)
        stream = try container.decodeIfPresent(Bool.self, forKey: .stream)
        
        // Decode metadata as generic JSON
        if let metadataData = try? container.decode(Data.self, forKey: .metadata),
           let metadataDict = try? JSONSerialization.jsonObject(with: metadataData) as? [String: Any] {
            metadata = metadataDict
        } else {
            metadata = nil
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(model, forKey: .model)
        try container.encode(prompt, forKey: .prompt)
        try container.encode(maxTokensToSample, forKey: .maxTokensToSample)
        try container.encodeIfPresent(stopSequences, forKey: .stopSequences)
        try container.encodeIfPresent(temperature, forKey: .temperature)
        try container.encodeIfPresent(topP, forKey: .topP)
        try container.encodeIfPresent(topK, forKey: .topK)
        try container.encodeIfPresent(stream, forKey: .stream)
        
        // Encode metadata as generic JSON
        if let metadata = metadata,
           let metadataData = try? JSONSerialization.data(withJSONObject: metadata) {
            try container.encode(metadataData, forKey: .metadata)
        }
    }
}

/// Response from complete endpoint
public struct CompleteResponse: Codable {
    /// Completion response object type
    public let type: String
    
    /// ID of the completion response
    public let id: String
    
    /// The completion content
    public let completion: String
    
    /// The reason the model stopped generating
    public let stopReason: CompleteStopReason?
    
    /// The model that handled the request
    public let model: String
    
    enum CodingKeys: String, CodingKey {
        case type, id, completion
        case stopReason = "stop_reason"
        case model
    }
}

/// Stop reasons for complete endpoint
public enum CompleteStopReason: String, Codable {
    case stopSequence = "stop_sequence"
    case maxTokens = "max_tokens"
}