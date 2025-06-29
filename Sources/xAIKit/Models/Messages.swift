import Foundation

// MARK: - Messages Request

/// Request for creating messages (Anthropic compatible)
public struct MessagesRequest: Codable {
    /// Input messages
    public let messages: [Message]
    
    /// The model that will complete your prompt
    public let model: String
    
    /// The maximum number of tokens to generate
    public let maxTokens: Int
    
    /// An object describing metadata about the request
    public let metadata: [String: Any]?
    
    /// Custom text sequences that will cause the model to stop generating
    public let stopSequences: [String]?
    
    /// Whether to incrementally stream the response
    public let stream: Bool?
    
    /// System prompt
    public let system: String?
    
    /// Amount of randomness injected into the response
    public let temperature: Double?
    
    /// How the model should use the provided tools
    public let toolChoice: MessageToolChoice?
    
    /// Definitions of tools that the model may use
    public let tools: [MessageTool]?
    
    /// Only sample from the top K options
    public let topK: Int?
    
    /// Use nucleus sampling
    public let topP: Double?
    
    enum CodingKeys: String, CodingKey {
        case messages, model
        case maxTokens = "max_tokens"
        case metadata
        case stopSequences = "stop_sequences"
        case stream, system, temperature
        case toolChoice = "tool_choice"
        case tools
        case topK = "top_k"
        case topP = "top_p"
    }
    
    public init(
        messages: [Message],
        model: String,
        maxTokens: Int,
        metadata: [String: Any]? = nil,
        stopSequences: [String]? = nil,
        stream: Bool? = nil,
        system: String? = nil,
        temperature: Double? = nil,
        toolChoice: MessageToolChoice? = nil,
        tools: [MessageTool]? = nil,
        topK: Int? = nil,
        topP: Double? = nil
    ) {
        self.messages = messages
        self.model = model
        self.maxTokens = maxTokens
        self.metadata = metadata
        self.stopSequences = stopSequences
        self.stream = stream
        self.system = system
        self.temperature = temperature
        self.toolChoice = toolChoice
        self.tools = tools
        self.topK = topK
        self.topP = topP
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        messages = try container.decode([Message].self, forKey: .messages)
        model = try container.decode(String.self, forKey: .model)
        maxTokens = try container.decode(Int.self, forKey: .maxTokens)
        stopSequences = try container.decodeIfPresent([String].self, forKey: .stopSequences)
        stream = try container.decodeIfPresent(Bool.self, forKey: .stream)
        system = try container.decodeIfPresent(String.self, forKey: .system)
        temperature = try container.decodeIfPresent(Double.self, forKey: .temperature)
        toolChoice = try container.decodeIfPresent(MessageToolChoice.self, forKey: .toolChoice)
        tools = try container.decodeIfPresent([MessageTool].self, forKey: .tools)
        topK = try container.decodeIfPresent(Int.self, forKey: .topK)
        topP = try container.decodeIfPresent(Double.self, forKey: .topP)
        
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
        try container.encode(messages, forKey: .messages)
        try container.encode(model, forKey: .model)
        try container.encode(maxTokens, forKey: .maxTokens)
        try container.encodeIfPresent(stopSequences, forKey: .stopSequences)
        try container.encodeIfPresent(stream, forKey: .stream)
        try container.encodeIfPresent(system, forKey: .system)
        try container.encodeIfPresent(temperature, forKey: .temperature)
        try container.encodeIfPresent(toolChoice, forKey: .toolChoice)
        try container.encodeIfPresent(tools, forKey: .tools)
        try container.encodeIfPresent(topK, forKey: .topK)
        try container.encodeIfPresent(topP, forKey: .topP)
        
        // Encode metadata as generic JSON
        if let metadata = metadata,
           let metadataData = try? JSONSerialization.data(withJSONObject: metadata) {
            try container.encode(metadataData, forKey: .metadata)
        }
    }
}

/// Message in a conversation
public struct Message: Codable {
    /// The role of the message author
    public let role: MessageRole
    
    /// The content of the message
    public let content: MessageContent
    
    public init(role: MessageRole, content: MessageContent) {
        self.role = role
        self.content = content
    }
}

/// Role of a message
public enum MessageRole: String, Codable {
    case user
    case assistant
}

/// Message content
public enum MessageContent: Codable {
    case text(String)
    case multipart([MessageContentPart])
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let text = try? container.decode(String.self) {
            self = .text(text)
        } else if let parts = try? container.decode([MessageContentPart].self) {
            self = .multipart(parts)
        } else {
            throw DecodingError.typeMismatch(
                MessageContent.self,
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Expected String or [MessageContentPart]"
                )
            )
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .text(let text):
            try container.encode(text)
        case .multipart(let parts):
            try container.encode(parts)
        }
    }
}

/// Part of a multipart message
public struct MessageContentPart: Codable {
    /// The type of content part
    public let type: MessageContentType
    
    /// Text content (when type is text)
    public let text: String?
    
    /// Image content (when type is image)
    public let image: MessageImage?
    
    public init(text: String) {
        self.type = .text
        self.text = text
        self.image = nil
    }
    
    public init(imageURL: String) {
        self.type = .image
        self.text = nil
        self.image = MessageImage(url: imageURL)
    }
}

/// Type of message content
public enum MessageContentType: String, Codable {
    case text
    case image
}

/// Image in a message
public struct MessageImage: Codable {
    /// The URL of the image
    public let url: String
}

/// Tool choice for messages
public struct MessageToolChoice: Codable {
    // Implementation depends on API specifics
}

/// Tool definition for messages
public struct MessageTool: Codable {
    // Implementation depends on API specifics
}

// MARK: - Messages Response

/// Response from messages endpoint
public struct MessagesResponse: Codable {
    /// Unique object identifier
    public let id: String
    
    /// Object type
    public let type: String
    
    /// Role of the generated message
    public let role: MessageRole
    
    /// Response message content
    public let content: [MessageResponseContent]
    
    /// Model name that handled the request
    public let model: String
    
    /// The reason the model stopped generating
    public let stopReason: MessageStopReason?
    
    /// The stop sequence that caused the model to stop
    public let stopSequence: String?
    
    /// Token usage information
    public let usage: MessageUsage
    
    enum CodingKeys: String, CodingKey {
        case id, type, role, content, model
        case stopReason = "stop_reason"
        case stopSequence = "stop_sequence"
        case usage
    }
}

/// Content in a message response
public struct MessageResponseContent: Codable {
    /// The type of content
    public let type: String
    
    /// The text content
    public let text: String
}

/// Reason the model stopped generating
public enum MessageStopReason: String, Codable {
    case endTurn = "end_turn"
    case maxTokens = "max_tokens"
    case stopSequence = "stop_sequence"
    case toolUse = "tool_use"
}

/// Token usage for messages
public struct MessageUsage: Codable {
    /// Number of input tokens
    public let inputTokens: Int
    
    /// Number of cache creation input tokens
    public let cacheCreationInputTokens: Int?
    
    /// Number of cache read input tokens
    public let cacheReadInputTokens: Int?
    
    /// Number of output tokens
    public let outputTokens: Int
    
    enum CodingKeys: String, CodingKey {
        case inputTokens = "input_tokens"
        case cacheCreationInputTokens = "cache_creation_input_tokens"
        case cacheReadInputTokens = "cache_read_input_tokens"
        case outputTokens = "output_tokens"
    }
}

// MARK: - Streaming

/// Event types for message streaming
public enum MessageStreamEventType: String, Codable {
    case messageStart = "message_start"
    case contentBlockStart = "content_block_start"
    case contentBlockDelta = "content_block_delta"
    case contentBlockStop = "content_block_stop"
    case messageDelta = "message_delta"
    case messageStop = "message_stop"
    case ping
    case error
}

/// Message stream event
public struct MessageStreamEvent: Codable {
    /// The type of event
    public let type: MessageStreamEventType
    
    /// Message data (for message_start)
    public let message: MessagesResponse?
    
    /// Content block index
    public let index: Int?
    
    /// Content block data
    public let contentBlock: MessageResponseContent?
    
    /// Delta data
    public let delta: MessageStreamDelta?
    
    /// Usage data (for message_delta)
    public let usage: MessageUsage?
    
    enum CodingKeys: String, CodingKey {
        case type, message, index
        case contentBlock = "content_block"
        case delta, usage
    }
}

/// Delta in a message stream
public struct MessageStreamDelta: Codable {
    /// Text delta
    public let text: String?
    
    /// Stop reason
    public let stopReason: MessageStopReason?
    
    /// Stop sequence
    public let stopSequence: String?
    
    enum CodingKeys: String, CodingKey {
        case text
        case stopReason = "stop_reason"
        case stopSequence = "stop_sequence"
    }
}