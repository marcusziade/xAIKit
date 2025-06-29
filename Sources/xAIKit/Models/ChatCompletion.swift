import Foundation

// MARK: - Chat Completion Request

/// Request for creating a chat completion
public struct ChatCompletionRequest: Codable {
    /// A list of messages comprising the conversation so far
    public let messages: [ChatMessage]
    
    /// ID of the model to use
    public let model: String
    
    /// Number between -2.0 and 2.0. Positive values penalize new tokens based on their existing frequency
    public let frequencyPenalty: Double?
    
    /// Modify the likelihood of specified tokens appearing in the completion
    public let logitBias: [String: Double]?
    
    /// Whether to return log probabilities of the output tokens or not
    public let logprobs: Bool?
    
    /// Number of most likely tokens to return at each token position
    public let topLogprobs: Int?
    
    /// The maximum number of tokens that can be generated
    public let maxTokens: Int?
    
    /// How many chat completion choices to generate
    public let n: Int?
    
    /// Number between -2.0 and 2.0. Positive values penalize new tokens based on whether they appear
    public let presencePenalty: Double?
    
    /// How much reasoning effort to apply when generating a response
    public let reasoningEffort: ReasoningEffort?
    
    /// Response format configuration
    public let responseFormat: ResponseFormat?
    
    /// Seed for deterministic sampling
    public let seed: Int?
    
    /// Up to 4 sequences where the API will stop generating
    public let stop: StopSequence?
    
    /// If set, partial message deltas will be sent
    public let stream: Bool?
    
    /// What sampling temperature to use, between 0 and 2
    public let temperature: Double?
    
    /// An alternative to sampling with temperature
    public let topP: Double?
    
    /// A list of tools the model may call
    public let tools: [ChatTool]?
    
    /// Controls which function is called by the model
    public let toolChoice: ToolChoice?
    
    /// Whether to enable parallel function calling
    public let parallelToolCalls: Bool?
    
    /// A unique identifier representing your end-user
    public let user: String?
    
    /// If set, returns a deferred request ID instead of blocking
    public let deferred: Bool?
    
    enum CodingKeys: String, CodingKey {
        case messages, model
        case frequencyPenalty = "frequency_penalty"
        case logitBias = "logit_bias"
        case logprobs
        case topLogprobs = "top_logprobs"
        case maxTokens = "max_tokens"
        case n
        case presencePenalty = "presence_penalty"
        case reasoningEffort = "reasoning_effort"
        case responseFormat = "response_format"
        case seed, stop, stream, temperature
        case topP = "top_p"
        case tools
        case toolChoice = "tool_choice"
        case parallelToolCalls = "parallel_tool_calls"
        case user, deferred
    }
    
    public init(
        messages: [ChatMessage],
        model: String,
        frequencyPenalty: Double? = nil,
        logitBias: [String: Double]? = nil,
        logprobs: Bool? = nil,
        topLogprobs: Int? = nil,
        maxTokens: Int? = nil,
        n: Int? = nil,
        presencePenalty: Double? = nil,
        reasoningEffort: ReasoningEffort? = nil,
        responseFormat: ResponseFormat? = nil,
        seed: Int? = nil,
        stop: StopSequence? = nil,
        stream: Bool? = nil,
        temperature: Double? = nil,
        topP: Double? = nil,
        tools: [ChatTool]? = nil,
        toolChoice: ToolChoice? = nil,
        parallelToolCalls: Bool? = nil,
        user: String? = nil,
        deferred: Bool? = nil
    ) {
        self.messages = messages
        self.model = model
        self.frequencyPenalty = frequencyPenalty
        self.logitBias = logitBias
        self.logprobs = logprobs
        self.topLogprobs = topLogprobs
        self.maxTokens = maxTokens
        self.n = n
        self.presencePenalty = presencePenalty
        self.reasoningEffort = reasoningEffort
        self.responseFormat = responseFormat
        self.seed = seed
        self.stop = stop
        self.stream = stream
        self.temperature = temperature
        self.topP = topP
        self.tools = tools
        self.toolChoice = toolChoice
        self.parallelToolCalls = parallelToolCalls
        self.user = user
        self.deferred = deferred
    }
}

/// Chat message
public struct ChatMessage: Codable {
    /// The role of the message author
    public let role: ChatRole
    
    /// The content of the message
    public let content: String
    
    public init(role: ChatRole, content: String) {
        self.role = role
        self.content = content
    }
}

/// Role of a chat message
public enum ChatRole: String, Codable {
    case system
    case user
    case assistant
}

/// Reasoning effort levels
public enum ReasoningEffort: String, Codable {
    case low
    case medium
    case high
}

/// Response format configuration
public struct ResponseFormat: Codable {
    /// The type of response format
    public let type: ResponseFormatType
    
    /// JSON schema configuration
    public let jsonSchema: JSONSchema?
    
    enum CodingKeys: String, CodingKey {
        case type
        case jsonSchema = "json_schema"
    }
    
    public init(type: ResponseFormatType, jsonSchema: JSONSchema? = nil) {
        self.type = type
        self.jsonSchema = jsonSchema
    }
}

/// Response format types
public enum ResponseFormatType: String, Codable {
    case text
    case jsonObject = "json_object"
    case jsonSchema = "json_schema"
}

/// JSON schema configuration
public struct JSONSchema: Codable {
    /// Name of the JSON schema
    public let name: String
    
    /// Whether to enforce strict schema validation
    public let strict: Bool?
    
    /// The JSON schema to use for validation
    public let schema: [String: Any]
    
    enum CodingKeys: String, CodingKey {
        case name, strict, schema
    }
    
    public init(name: String, strict: Bool? = nil, schema: [String: Any]) {
        self.name = name
        self.strict = strict
        self.schema = schema
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        strict = try container.decodeIfPresent(Bool.self, forKey: .strict)
        
        // Decode schema as generic JSON
        if let schemaData = try? container.decode(Data.self, forKey: .schema),
           let schemaDict = try? JSONSerialization.jsonObject(with: schemaData) as? [String: Any] {
            schema = schemaDict
        } else {
            schema = [:]
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(strict, forKey: .strict)
        
        // Encode schema as generic JSON
        if let schemaData = try? JSONSerialization.data(withJSONObject: schema) {
            try container.encode(schemaData, forKey: .schema)
        }
    }
}

/// Stop sequence configuration
public enum StopSequence: Codable {
    case single(String)
    case multiple([String])
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let single = try? container.decode(String.self) {
            self = .single(single)
        } else if let multiple = try? container.decode([String].self) {
            self = .multiple(multiple)
        } else {
            throw DecodingError.typeMismatch(
                StopSequence.self,
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Expected String or [String]"
                )
            )
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .single(let string):
            try container.encode(string)
        case .multiple(let strings):
            try container.encode(strings)
        }
    }
}

/// Chat tool definition
public struct ChatTool: Codable {
    /// The type of the tool
    public let type: String
    
    /// Function definition
    public let function: ChatFunction
    
    public init(type: String = "function", function: ChatFunction) {
        self.type = type
        self.function = function
    }
}

/// Chat function definition
public struct ChatFunction: Codable {
    /// The name of the function
    public let name: String
    
    /// Description of what the function does
    public let description: String?
    
    /// Parameters the function accepts
    public let parameters: [String: Any]?
    
    public init(name: String, description: String? = nil, parameters: [String: Any]? = nil) {
        self.name = name
        self.description = description
        self.parameters = parameters
    }
    
    enum CodingKeys: String, CodingKey {
        case name, description, parameters
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        
        if let paramData = try? container.decode(Data.self, forKey: .parameters),
           let paramDict = try? JSONSerialization.jsonObject(with: paramData) as? [String: Any] {
            parameters = paramDict
        } else {
            parameters = nil
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(description, forKey: .description)
        
        if let parameters = parameters,
           let paramData = try? JSONSerialization.data(withJSONObject: parameters) {
            try container.encode(paramData, forKey: .parameters)
        }
    }
}

/// Tool choice configuration
public enum ToolChoice: Codable {
    case none
    case auto
    case required
    case function(name: String)
    
    private enum CodingKeys: String, CodingKey {
        case type, function
    }
    
    private enum FunctionKeys: String, CodingKey {
        case name
    }
    
    public init(from decoder: Decoder) throws {
        if let container = try? decoder.singleValueContainer(),
           let stringValue = try? container.decode(String.self) {
            switch stringValue {
            case "none": self = .none
            case "auto": self = .auto
            case "required": self = .required
            default:
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Unknown tool choice: \(stringValue)"
                )
            }
        } else {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let type = try container.decode(String.self, forKey: .type)
            if type == "function" {
                let functionContainer = try container.nestedContainer(keyedBy: FunctionKeys.self, forKey: .function)
                let name = try functionContainer.decode(String.self, forKey: .name)
                self = .function(name: name)
            } else {
                throw DecodingError.dataCorruptedError(
                    forKey: .type,
                    in: container,
                    debugDescription: "Unknown tool choice type: \(type)"
                )
            }
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        switch self {
        case .none, .auto, .required:
            var container = encoder.singleValueContainer()
            try container.encode(String(describing: self))
        case .function(let name):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode("function", forKey: .type)
            var functionContainer = container.nestedContainer(keyedBy: FunctionKeys.self, forKey: .function)
            try functionContainer.encode(name, forKey: .name)
        }
    }
}

// MARK: - Chat Completion Response

/// Response from chat completion endpoint
public struct ChatCompletionResponse: Codable {
    /// Unique ID for the chat response
    public let id: String
    
    /// The object type
    public let object: String
    
    /// Creation time in Unix timestamp
    public let created: Int
    
    /// Model ID used to create chat completion
    public let model: String
    
    /// List of response choices from the model
    public let choices: [ChatChoice]
    
    /// Token usage information
    public let usage: ChatUsage?
    
    /// System fingerprint
    public let systemFingerprint: String?
    
    enum CodingKeys: String, CodingKey {
        case id, object, created, model, choices, usage
        case systemFingerprint = "system_fingerprint"
    }
}

/// Chat completion choice
public struct ChatChoice: Codable {
    /// The index of the choice
    public let index: Int
    
    /// The message content
    public let message: ChatResponseMessage
    
    /// The reason the model stopped generating
    public let finishReason: FinishReason?
    
    /// Log probabilities
    public let logprobs: ChatLogprobs?
    
    enum CodingKeys: String, CodingKey {
        case index, message
        case finishReason = "finish_reason"
        case logprobs
    }
}

/// Chat response message
public struct ChatResponseMessage: Codable {
    /// The role of the message author
    public let role: ChatRole
    
    /// The content of the message
    public let content: String?
    
    /// Reasoning content when reasoning_effort is used
    public let reasoningContent: String?
    
    /// Refusal message if the model refuses to answer
    public let refusal: String?
    
    /// Tool calls made by the model
    public let toolCalls: [ChatToolCall]?
    
    enum CodingKeys: String, CodingKey {
        case role, content
        case reasoningContent = "reasoning_content"
        case refusal
        case toolCalls = "tool_calls"
    }
}

/// Tool call made by the model
public struct ChatToolCall: Codable {
    /// ID of the tool call
    public let id: String
    
    /// Type of the tool
    public let type: String
    
    /// Function call details
    public let function: ChatFunctionCall
}

/// Function call details
public struct ChatFunctionCall: Codable {
    /// Name of the function to call
    public let name: String
    
    /// Arguments to call the function with
    public let arguments: String
}

/// Reason the model stopped generating
public enum FinishReason: String, Codable {
    case stop
    case length
    case contentFilter = "content_filter"
    case toolCalls = "tool_calls"
}

/// Token usage information
public struct ChatUsage: Codable {
    /// Number of tokens in the prompt
    public let promptTokens: Int
    
    /// Number of tokens in the completion
    public let completionTokens: Int
    
    /// Total number of tokens used
    public let totalTokens: Int
    
    /// Detailed prompt token information
    public let promptTokensDetails: TokenDetails?
    
    /// Detailed completion token information
    public let completionTokensDetails: CompletionTokenDetails?
    
    enum CodingKeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case totalTokens = "total_tokens"
        case promptTokensDetails = "prompt_tokens_details"
        case completionTokensDetails = "completion_tokens_details"
    }
}

/// Detailed token information
public struct TokenDetails: Codable {
    public let textTokens: Int?
    public let audioTokens: Int?
    public let imageTokens: Int?
    public let cachedTokens: Int?
    
    enum CodingKeys: String, CodingKey {
        case textTokens = "text_tokens"
        case audioTokens = "audio_tokens"
        case imageTokens = "image_tokens"
        case cachedTokens = "cached_tokens"
    }
}

/// Detailed completion token information
public struct CompletionTokenDetails: Codable {
    public let reasoningTokens: Int?
    public let audioTokens: Int?
    public let acceptedPredictionTokens: Int?
    public let rejectedPredictionTokens: Int?
    
    enum CodingKeys: String, CodingKey {
        case reasoningTokens = "reasoning_tokens"
        case audioTokens = "audio_tokens"
        case acceptedPredictionTokens = "accepted_prediction_tokens"
        case rejectedPredictionTokens = "rejected_prediction_tokens"
    }
}

/// Log probabilities
public struct ChatLogprobs: Codable {
    public let content: [ChatLogprobContent]?
}

/// Log probability content
public struct ChatLogprobContent: Codable {
    public let token: String
    public let logprob: Double
    public let bytes: [Int]?
    public let topLogprobs: [ChatTopLogprob]?
    
    enum CodingKeys: String, CodingKey {
        case token, logprob, bytes
        case topLogprobs = "top_logprobs"
    }
}

/// Top log probability
public struct ChatTopLogprob: Codable {
    public let token: String
    public let logprob: Double
    public let bytes: [Int]?
}

// MARK: - Streaming

/// Chat completion chunk for streaming
public struct ChatCompletionChunk: Codable {
    public let id: String
    public let object: String
    public let created: Int
    public let model: String
    public let choices: [ChatChunkChoice]
    public let systemFingerprint: String?
    
    enum CodingKeys: String, CodingKey {
        case id, object, created, model, choices
        case systemFingerprint = "system_fingerprint"
    }
}

/// Chat chunk choice
public struct ChatChunkChoice: Codable {
    public let index: Int
    public let delta: ChatChunkDelta
    public let finishReason: FinishReason?
    public let logprobs: ChatLogprobs?
    
    enum CodingKeys: String, CodingKey {
        case index, delta
        case finishReason = "finish_reason"
        case logprobs
    }
}

/// Chat chunk delta
public struct ChatChunkDelta: Codable {
    public let role: ChatRole?
    public let content: String?
    public let reasoningContent: String?
    public let refusal: String?
    public let toolCalls: [ChatToolCall]?
    
    enum CodingKeys: String, CodingKey {
        case role, content
        case reasoningContent = "reasoning_content"
        case refusal
        case toolCalls = "tool_calls"
    }
}