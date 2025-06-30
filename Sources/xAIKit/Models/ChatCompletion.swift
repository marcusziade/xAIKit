import Foundation

// MARK: - Chat Completion Request

/// Request for creating a chat completion with xAI models.
///
/// `ChatCompletionRequest` encapsulates all parameters needed to generate AI responses
/// through the chat completions API. It supports standard text generation, streaming,
/// function calling, structured outputs, and more.
///
/// ## Basic Usage
/// ```swift
/// let request = ChatCompletionRequest(
///     messages: [
///         ChatMessage(role: .system, content: "You are a helpful assistant."),
///         ChatMessage(role: .user, content: "What is machine learning?")
///     ],
///     model: "grok-beta"
/// )
/// ```
///
/// ## Advanced Features
/// ```swift
/// let advancedRequest = ChatCompletionRequest(
///     messages: messages,
///     model: "grok-beta",
///     temperature: 0.7,
///     maxTokens: 1000,
///     responseFormat: .jsonObject,
///     tools: tools,
///     toolChoice: .auto
/// )
/// ```
public struct ChatCompletionRequest: Codable {
    /// A list of messages comprising the conversation so far.
    ///
    /// Messages should be ordered chronologically, with the system message (if any)
    /// first, followed by alternating user and assistant messages.
    public let messages: [ChatMessage]
    
    /// ID of the model to use.
    ///
    /// Available models include:
    /// - `"grok-beta"`: Latest Grok model with advanced capabilities
    /// - `"grok-2"`: Previous generation Grok model
    /// - Custom model identifiers as provided by xAI
    public let model: String
    
    /// Number between -2.0 and 2.0. Positive values penalize new tokens based on their existing frequency.
    ///
    /// - Positive values (0.0 to 2.0): Reduce repetition by penalizing tokens that appear frequently
    /// - Negative values (-2.0 to 0.0): Increase repetition
    /// - Default: 0.0 (no penalty)
    public let frequencyPenalty: Double?
    
    /// Modify the likelihood of specified tokens appearing in the completion
    public let logitBias: [String: Double]?
    
    /// Whether to return log probabilities of the output tokens or not.
    ///
    /// When `true`, includes token-level probability information in the response,
    /// useful for understanding model confidence and debugging.
    public let logprobs: Bool?
    
    /// Number of most likely tokens to return at each token position
    public let topLogprobs: Int?
    
    /// The maximum number of tokens that can be generated in the completion.
    ///
    /// The token count includes both the prompt and the completion. Different models
    /// have different maximum limits. If not specified, the model's default is used.
    public let maxTokens: Int?
    
    /// How many chat completion choices to generate for each input message.
    ///
    /// Defaults to 1. Note that you will be charged based on the total number of
    /// tokens generated across all choices.
    public let n: Int?
    
    /// Number between -2.0 and 2.0. Positive values penalize new tokens based on whether they appear
    public let presencePenalty: Double?
    
    /// How much reasoning effort to apply when generating a response.
    ///
    /// Controls the computational effort spent on reasoning:
    /// - `.low`: Faster responses with basic reasoning
    /// - `.medium`: Balanced speed and reasoning depth
    /// - `.high`: Slower but more thoughtful responses
    public let reasoningEffort: ReasoningEffort?
    
    /// Response format configuration
    public let responseFormat: ResponseFormat?
    
    /// Seed for deterministic sampling
    public let seed: Int?
    
    /// Up to 4 sequences where the API will stop generating
    public let stop: StopSequence?
    
    /// If set, partial message deltas will be sent as server-sent events.
    ///
    /// When `true`, responses are streamed token-by-token as they're generated,
    /// enabling real-time display of AI responses. Use the streaming API methods
    /// to handle streamed responses.
    public let stream: Bool?
    
    /// What sampling temperature to use, between 0 and 2.
    ///
    /// Higher values (e.g., 1.0) make output more random and creative.
    /// Lower values (e.g., 0.2) make output more focused and deterministic.
    /// - 0.0-0.3: Very focused, almost deterministic
    /// - 0.4-0.7: Balanced creativity and coherence
    /// - 0.8-1.2: More creative and varied
    /// - 1.3-2.0: Very creative, may be less coherent
    public let temperature: Double?
    
    /// An alternative to sampling with temperature, called nucleus sampling.
    ///
    /// The model considers tokens with top_p cumulative probability mass.
    /// So 0.1 means only tokens comprising the top 10% probability mass are considered.
    /// Generally, use either temperature or top_p, not both.
    public let topP: Double?
    
    /// A list of tools the model may call
    public let tools: [ChatTool]?
    
    /// Controls which function is called by the model.
    ///
    /// Options include:
    /// - `.none`: Model will not call functions
    /// - `.auto`: Model decides whether to call functions
    /// - `.required`: Model must call a function
    /// - `.function(name)`: Model must call the specified function
    public let toolChoice: ToolChoice?
    
    /// Whether to enable parallel function calling during a single completion.
    ///
    /// When `true`, the model may generate multiple function calls in a single response,
    /// improving efficiency for tasks requiring multiple tool uses.
    public let parallelToolCalls: Bool?
    
    /// A unique identifier representing your end-user
    public let user: String?
    
    /// If set, returns a deferred request ID instead of blocking for the response.
    ///
    /// Useful for long-running requests. The response can be retrieved later using
    /// the deferred completion endpoint with the returned request ID.
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

/// A message in a chat conversation.
///
/// Messages represent the building blocks of conversations with AI models. Each message
/// has a role (system, user, assistant, or tool) and content that can be text, images,
/// or structured data.
///
/// ## Creating Messages
/// ```swift
/// // Simple text message
/// let userMessage = ChatMessage(role: .user, content: "Hello!")
///
/// // Multi-modal message with text and image
/// let multiModalMessage = ChatMessage(
///     role: .user,
///     content: [
///         .text("What's in this image?"),
///         .imageURL("https://example.com/image.jpg")
///     ]
/// )
/// ```
public struct ChatMessage: Codable {
    /// The role of the message author.
    ///
    /// - `.system`: Instructions that guide the model's behavior
    /// - `.user`: Input from the human user
    /// - `.assistant`: Responses from the AI model
    /// - `.tool`: Results from function/tool calls
    public let role: ChatRole
    
    /// The content of the message.
    ///
    /// Can be:
    /// - Simple text: `ChatMessage(role: .user, content: "Hello")`
    /// - Multi-modal: Array of content parts including text and images
    /// - Tool results: Structured responses from function calls
    public let content: ChatMessageContent
    
    public init(role: ChatRole, content: String) {
        self.role = role
        self.content = .text(content)
    }
    
    public init(role: ChatRole, content: [Content]) {
        self.role = role
        self.content = .parts(content)
    }
    
    /// Convenience getter for extracting string content from the message.
    ///
    /// Returns the text content whether the message contains simple text or
    /// multi-part content. For multi-part messages, concatenates all text parts.
    public var stringContent: String? {
        switch content {
        case .text(let str):
            return str
        case .parts(let parts):
            return parts.compactMap { part in
                if case .text(let str) = part {
                    return str
                }
                return nil
            }.joined(separator: " ")
        }
    }
}

/// Message content that can be either a string or array of content parts.
///
/// This enum provides flexibility in message content representation:
/// - Simple text messages use `.text(String)`
/// - Multi-modal messages (text + images) use `.parts([Content])`
///
/// The type automatically handles encoding/decoding based on the content structure.
public enum ChatMessageContent: Codable {
    case text(String)
    case parts([ChatMessage.Content])
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let text = try? container.decode(String.self) {
            self = .text(text)
        } else if let parts = try? container.decode([ChatMessage.Content].self) {
            self = .parts(parts)
        } else {
            throw DecodingError.typeMismatch(ChatMessageContent.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected String or [Content]"))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .text(let text):
            try container.encode(text)
        case .parts(let parts):
            try container.encode(parts)
        }
    }
}

extension ChatMessage {
    /// Content part that can be text or image.
    ///
    /// Used for multi-modal messages that combine text and images. Each part
    /// represents either a text segment or an image URL.
    ///
    /// ## Example
    /// ```swift
    /// let parts: [ChatMessage.Content] = [
    ///     .text("What do you see in this image?"),
    ///     .image(url: "https://example.com/photo.jpg"),
    ///     .text("Is it a sunset?")
    /// ]
    /// ```
    public enum Content: Codable {
        case text(String)
        case image(url: String)
        
        enum CodingKeys: String, CodingKey {
            case type
            case text
            case image
        }
        
        enum ImageKeys: String, CodingKey {
            case url
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let type = try container.decode(String.self, forKey: .type)
            
            switch type {
            case "text":
                let text = try container.decode(String.self, forKey: .text)
                self = .text(text)
            case "image":
                let imageContainer = try container.nestedContainer(keyedBy: ImageKeys.self, forKey: .image)
                let url = try imageContainer.decode(String.self, forKey: .url)
                self = .image(url: url)
            default:
                throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown content type: \(type)")
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            switch self {
            case .text(let text):
                try container.encode("text", forKey: .type)
                try container.encode(text, forKey: .text)
            case .image(let url):
                try container.encode("image", forKey: .type)
                var imageContainer = container.nestedContainer(keyedBy: ImageKeys.self, forKey: .image)
                try imageContainer.encode(url, forKey: .url)
            }
        }
    }
}

/// Role of a chat message.
///
/// Defines the sender's role in the conversation, which affects how the AI
/// interprets and responds to the message.
public enum ChatRole: String, Codable {
    case system
    case user
    case assistant
}

/// Reasoning effort levels for AI responses.
///
/// Controls the computational resources and time spent on generating responses:
/// - `.low`: Quick responses with basic reasoning, suitable for simple queries
/// - `.medium`: Balanced approach for most use cases
/// - `.high`: Deep reasoning for complex problems, may take longer
public enum ReasoningEffort: String, Codable {
    case low
    case medium
    case high
}

/// Response format configuration for structured outputs.
///
/// Allows you to specify how the AI should format its response, including
/// support for JSON objects and schema-validated JSON.
///
/// ## Example
/// ```swift
/// // Force JSON object response
/// let format = ResponseFormat(type: .jsonObject)
///
/// // Use JSON schema validation
/// let schema: [String: Any] = [
///     "type": "object",
///     "properties": [
///         "name": ["type": "string"],
///         "age": ["type": "integer"]
///     ]
/// ]
/// let schemaFormat = ResponseFormat(
///     type: .jsonSchema,
///     jsonSchema: JSONSchema(name: "person", schema: schema)
/// )
/// ```
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

/// Response format types supported by the API.
///
/// - `.text`: Standard text response (default)
/// - `.jsonObject`: Response will be a valid JSON object
/// - `.jsonSchema`: Response will conform to a provided JSON schema
public enum ResponseFormatType: String, Codable {
    case text
    case jsonObject = "json_object"
    case jsonSchema = "json_schema"
}

/// JSON schema configuration for structured output validation.
///
/// Defines a JSON schema that the model's response must conform to. This ensures
/// predictable, structured outputs that can be reliably parsed by your application.
///
/// ## Usage
/// ```swift
/// let schema = JSONSchema(
///     name: "weather_response",
///     strict: true,
///     schema: [
///         "type": "object",
///         "properties": [
///             "temperature": ["type": "number"],
///             "conditions": ["type": "string"],
///             "humidity": ["type": "integer"]
///         ],
///         "required": ["temperature", "conditions"]
///     ]
/// )
/// ```
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

/// Stop sequence configuration for controlling response termination.
///
/// Specifies one or more sequences that, when generated, will cause the model
/// to stop generating further tokens. Useful for controlling response length
/// or format.
///
/// ## Examples
/// ```swift
/// // Single stop sequence
/// let stop = StopSequence.single("\n\n")
///
/// // Multiple stop sequences
/// let stops = StopSequence.multiple(["END", "STOP", "\n---\n"])
/// ```
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

/// Chat tool definition for function calling.
///
/// Defines a tool or function that the AI model can choose to call during
/// conversation. This enables the AI to interact with external systems or
/// perform specific actions.
///
/// ## Example
/// ```swift
/// let weatherTool = ChatTool(
///     type: "function",
///     function: ChatFunction(
///         name: "get_weather",
///         description: "Get current weather for a location",
///         parameters: [
///             "type": "object",
///             "properties": [
///                 "location": [
///                     "type": "string",
///                     "description": "City name"
///                 ]
///             ],
///             "required": ["location"]
///         ]
///     )
/// )
/// ```
public struct ChatTool: Codable {
    /// The type of the tool.
    ///
    /// Currently only "function" is supported.
    public let type: String
    
    /// Function definition containing the details of what the function does and its parameters.
    public let function: ChatFunction
    
    public init(type: String = "function", function: ChatFunction) {
        self.type = type
        self.function = function
    }
}

/// Chat function definition for AI-callable functions.
///
/// Describes a function that the AI model can choose to invoke, including its
/// name, purpose, and expected parameters. The AI will generate appropriate
/// arguments based on the conversation context.
///
/// ## Parameter Schema
/// Parameters should follow JSON Schema format:
/// ```swift
/// let parameters: [String: Any] = [
///     "type": "object",
///     "properties": [
///         "location": [
///             "type": "string",
///             "description": "The city and state"
///         ],
///         "unit": [
///             "type": "string",
///             "enum": ["celsius", "fahrenheit"],
///             "description": "Temperature unit"
///         ]
///     ],
///     "required": ["location"]
/// ]
/// ```
public struct ChatFunction: Codable {
    /// The name of the function to be called.
    ///
    /// Should be a clear, descriptive identifier like "get_weather" or "search_database".
    public let name: String
    
    /// Description of what the function does.
    ///
    /// This helps the AI understand when and how to use the function. Be specific
    /// about the function's purpose and capabilities.
    public let description: String?
    
    /// Parameters the function accepts, defined as a JSON Schema.
    ///
    /// Describes the expected arguments including types, descriptions, and which
    /// parameters are required. The AI uses this schema to generate valid function calls.
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

/// Tool choice configuration for controlling function calling behavior.
///
/// Determines how the AI model should handle function calling:
/// - `.none`: Disable function calling entirely
/// - `.auto`: Let the model decide whether to call functions
/// - `.required`: Force the model to call at least one function
/// - `.function(name)`: Force the model to call a specific function
///
/// ## Examples
/// ```swift
/// // Let AI decide
/// request.toolChoice = .auto
///
/// // Force weather function
/// request.toolChoice = .function(name: "get_weather")
///
/// // Require some function call
/// request.toolChoice = .required
/// ```
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

/// Response from the chat completion endpoint.
///
/// Contains the AI-generated response along with metadata about the generation
/// process, including token usage, finish reasons, and any tool calls made.
///
/// ## Accessing the Response
/// ```swift
/// let response = try await client.chat.completions(request)
/// 
/// // Get the generated text
/// if let content = response.choices.first?.message.content {
///     print(content)
/// }
/// 
/// // Check token usage
/// if let usage = response.usage {
///     print("Tokens used: \(usage.totalTokens)")
/// }
/// 
/// // Handle tool calls
/// if let toolCalls = response.choices.first?.message.toolCalls {
///     for call in toolCalls {
///         print("Function: \(call.function.name)")
///         print("Arguments: \(call.function.arguments)")
///     }
/// }
/// ```
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

/// Message generated by the AI in response to the conversation.
///
/// Contains the generated content and any additional information like tool calls,
/// reasoning content (when reasoning_effort is used), or refusal messages.
public struct ChatResponseMessage: Codable {
    /// The role of the message author (always `.assistant` for responses).
    public let role: ChatRole
    
    /// The main text content of the response.
    ///
    /// May be `nil` if the response consists only of tool calls.
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