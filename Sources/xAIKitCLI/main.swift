import ArgumentParser
import Foundation
import xAIKit

@main
struct xAICLI: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "xai-cli",
        abstract: "A command-line interface for testing the xAI API",
        version: xAIKit.version,
        subcommands: [
            Chat.self,
            Messages.self,
            Images.self,
            Models.self,
            Tokenize.self,
            APIKey.self,
            Complete.self
        ]
    )
}

// MARK: - Base Command Protocol

protocol xAICommand: AsyncParsableCommand {
    var apiKey: String? { get }
    var apiURL: String? { get }
}

extension xAICommand {
    func createClient() throws -> xAIClient {
        guard let apiKey = apiKey ?? ProcessInfo.processInfo.environment["XAI_API_KEY"] else {
            throw ValidationError("API key required. Set XAI_API_KEY environment variable or use --api-key")
        }
        
        var apiBaseURL: URL?
        if let apiURL = apiURL {
            apiBaseURL = URL(string: apiURL)
        }
        
        return xAIClient(apiKey: apiKey, apiBaseURL: apiBaseURL)
    }
}

// MARK: - Chat Command

struct Chat: xAICommand {
    static let configuration = CommandConfiguration(
        abstract: "Chat completion commands",
        subcommands: [ChatComplete.self, ChatStream.self]
    )
    
    @Option(help: "API key (defaults to XAI_API_KEY environment variable)")
    var apiKey: String?
    
    @Option(help: "API base URL")
    var apiURL: String?
}

struct ChatComplete: xAICommand {
    static let configuration = CommandConfiguration(
        commandName: "complete",
        abstract: "Create a chat completion"
    )
    
    @Option(help: "API key")
    var apiKey: String?
    
    @Option(help: "API base URL")
    var apiURL: String?
    
    @Argument(help: "The message to send")
    var message: String
    
    @Option(help: "The model to use")
    var model: String = "grok-3-mini-fast-latest"
    
    @Option(help: "System prompt")
    var system: String?
    
    @Option(help: "Maximum tokens to generate")
    var maxTokens: Int?
    
    @Option(help: "Temperature (0-2)")
    var temperature: Double?
    
    @Flag(help: "Output raw JSON response")
    var json = false
    
    func run() async throws {
        let client = try createClient()
        
        var messages = [ChatMessage]()
        if let system = system {
            messages.append(ChatMessage(role: .system, content: system))
        }
        messages.append(ChatMessage(role: .user, content: message))
        
        let response = try await client.chat.completions(
            messages: messages,
            model: model,
            maxTokens: maxTokens,
            temperature: temperature
        )
        
        if json {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(response)
            print(String(data: data, encoding: .utf8)!)
        } else {
            if let content = response.choices.first?.message.content {
                print(content)
            }
            print("\n---")
            print("Model: \(response.model)")
            if let usage = response.usage {
                print("Tokens: \(usage.promptTokens) prompt + \(usage.completionTokens) completion = \(usage.totalTokens) total")
            }
        }
    }
}

struct ChatStream: xAICommand {
    static let configuration = CommandConfiguration(
        commandName: "stream",
        abstract: "Create a streaming chat completion"
    )
    
    @Option(help: "API key")
    var apiKey: String?
    
    @Option(help: "API base URL")
    var apiURL: String?
    
    @Argument(help: "The message to send")
    var message: String
    
    @Option(help: "The model to use")
    var model: String = "grok-3-mini-fast-latest"
    
    @Option(help: "System prompt")
    var system: String?
    
    @Option(help: "Maximum tokens to generate")
    var maxTokens: Int?
    
    @Option(help: "Temperature (0-2)")
    var temperature: Double?
    
    func run() async throws {
        let client = try createClient()
        
        var messages = [ChatMessage]()
        if let system = system {
            messages.append(ChatMessage(role: .system, content: system))
        }
        messages.append(ChatMessage(role: .user, content: message))
        
        let stream = try await client.chat.completionsStream(
            messages: messages,
            model: model,
            maxTokens: maxTokens,
            temperature: temperature
        )
        
        for try await chunk in stream {
            if let content = chunk.choices.first?.delta.content {
                print(content, terminator: "")
                fflush(stdout)
            }
        }
        print()
    }
}

// MARK: - Messages Command (Anthropic Compatible)

struct Messages: xAICommand {
    static let configuration = CommandConfiguration(
        abstract: "Messages API commands (Anthropic compatible)",
        subcommands: [MessagesCreate.self, MessagesStream.self]
    )
    
    @Option(help: "API key")
    var apiKey: String?
    
    @Option(help: "API base URL")
    var apiURL: String?
}

struct MessagesCreate: xAICommand {
    static let configuration = CommandConfiguration(
        commandName: "create",
        abstract: "Create a message"
    )
    
    @Option(help: "API key")
    var apiKey: String?
    
    @Option(help: "API base URL")
    var apiURL: String?
    
    @Argument(help: "The message to send")
    var message: String
    
    @Option(help: "The model to use")
    var model: String = "grok-3-fast-latest"
    
    @Option(help: "System prompt")
    var system: String?
    
    @Option(help: "Maximum tokens to generate")
    var maxTokens: Int = 1024
    
    @Option(help: "Temperature (0-1)")
    var temperature: Double?
    
    @Flag(help: "Output raw JSON response")
    var json = false
    
    func run() async throws {
        let client = try createClient()
        
        let messages = [Message(role: .user, content: .text(message))]
        
        let response = try await client.messages.create(
            messages: messages,
            model: model,
            maxTokens: maxTokens,
            system: system,
            temperature: temperature
        )
        
        if json {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(response)
            print(String(data: data, encoding: .utf8)!)
        } else {
            for content in response.content {
                print(content.text)
            }
            print("\n---")
            print("Model: \(response.model)")
            print("Stop reason: \(response.stopReason?.rawValue ?? "none")")
            print("Tokens: \(response.usage.inputTokens) input + \(response.usage.outputTokens) output")
        }
    }
}

struct MessagesStream: xAICommand {
    static let configuration = CommandConfiguration(
        commandName: "stream",
        abstract: "Create a streaming message"
    )
    
    @Option(help: "API key")
    var apiKey: String?
    
    @Option(help: "API base URL")
    var apiURL: String?
    
    @Argument(help: "The message to send")
    var message: String
    
    @Option(help: "The model to use")
    var model: String = "grok-3-fast-latest"
    
    @Option(help: "System prompt")
    var system: String?
    
    @Option(help: "Maximum tokens to generate")
    var maxTokens: Int = 1024
    
    @Option(help: "Temperature (0-1)")
    var temperature: Double?
    
    func run() async throws {
        let client = try createClient()
        
        let messages = [Message(role: .user, content: .text(message))]
        
        let stream = try await client.messages.createStream(
            messages: messages,
            model: model,
            maxTokens: maxTokens,
            system: system,
            temperature: temperature
        )
        
        for try await event in stream {
            switch event.type {
            case .contentBlockDelta:
                if let text = event.delta?.text {
                    print(text, terminator: "")
                    fflush(stdout)
                }
            case .messageStop:
                print()
            default:
                break
            }
        }
    }
}

// MARK: - Images Command

struct Images: xAICommand {
    static let configuration = CommandConfiguration(
        abstract: "Image generation commands",
        subcommands: [ImagesGenerate.self]
    )
    
    @Option(help: "API key")
    var apiKey: String?
    
    @Option(help: "API base URL")
    var apiURL: String?
}

struct ImagesGenerate: xAICommand {
    static let configuration = CommandConfiguration(
        commandName: "generate",
        abstract: "Generate images"
    )
    
    @Option(help: "API key")
    var apiKey: String?
    
    @Option(help: "API base URL")
    var apiURL: String?
    
    @Argument(help: "The prompt for image generation")
    var prompt: String
    
    @Option(help: "The model to use")
    var model: String = "grok-2-image"
    
    @Option(help: "Number of images to generate")
    var n: Int = 1
    
    @Option(help: "Image size")
    var size: String = "1024x1024"
    
    @Option(help: "Image quality (standard/hd) - Note: May not be supported by xAI")
    var quality: String?
    
    @Option(help: "Image style (vivid/natural) - Note: May not be supported by xAI")
    var style: String?
    
    @Flag(help: "Output base64 instead of URL")
    var base64 = false
    
    func run() async throws {
        let client = try createClient()
        
        // xAI API currently only supports prompt and model
        let request = ImageGenerationRequest.xai(prompt: prompt, model: model)
        
        let response = try await client.images.generate(request)
        
        print("Generated \(response.data.count) image(s):")
        for (index, image) in response.data.enumerated() {
            print("\nImage \(index + 1):")
            if let url = image.url {
                print("URL: \(url)")
            } else if let b64 = image.b64Json {
                print("Base64: \(String(b64.prefix(100)))...")
            }
            if let revisedPrompt = image.revisedPrompt {
                print("\nRevised prompt: \(revisedPrompt)")
            }
        }
        
        if quality != nil || style != nil || size != "1024x1024" || n != 1 {
            print("\nNote: xAI API currently only supports 'prompt' and 'model' parameters. Other parameters were ignored.")
        }
    }
}

// MARK: - Models Command

struct Models: xAICommand {
    static let configuration = CommandConfiguration(
        abstract: "Model information commands",
        subcommands: [ModelsList.self, ModelsGet.self, ModelsLanguage.self, ModelsImage.self]
    )
    
    @Option(help: "API key")
    var apiKey: String?
    
    @Option(help: "API base URL")
    var apiURL: String?
}

struct ModelsList: xAICommand {
    static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List all available models"
    )
    
    @Option(help: "API key")
    var apiKey: String?
    
    @Option(help: "API base URL")
    var apiURL: String?
    
    func run() async throws {
        let client = try createClient()
        let models = try await client.models.list()
        
        print("Available models:")
        for model in models {
            print("- \(model.id) (owned by: \(model.ownedBy))")
        }
    }
}

struct ModelsGet: xAICommand {
    static let configuration = CommandConfiguration(
        commandName: "get",
        abstract: "Get information about a specific model"
    )
    
    @Option(help: "API key")
    var apiKey: String?
    
    @Option(help: "API base URL")
    var apiURL: String?
    
    @Argument(help: "Model ID")
    var modelId: String
    
    func run() async throws {
        let client = try createClient()
        let model = try await client.models.get(modelId: modelId)
        
        print("Model: \(model.id)")
        print("Created: \(Date(timeIntervalSince1970: TimeInterval(model.created)))")
        print("Owned by: \(model.ownedBy)")
    }
}

struct ModelsLanguage: xAICommand {
    static let configuration = CommandConfiguration(
        commandName: "language",
        abstract: "List language models with detailed information"
    )
    
    @Option(help: "API key")
    var apiKey: String?
    
    @Option(help: "API base URL")
    var apiURL: String?
    
    func run() async throws {
        let client = try createClient()
        let models = try await client.models.listLanguageModels()
        
        print("Language models:")
        for model in models {
            print("\n\(model.id)")
            print("  Version: \(model.version ?? "N/A")")
            print("  Input modalities: \(model.inputModalities?.joined(separator: ", ") ?? "N/A")")
            print("  Output modalities: \(model.outputModalities?.joined(separator: ", ") ?? "N/A")")
            if let promptPrice = model.promptTextTokenPrice {
                print("  Prompt price: $\(Double(promptPrice) / 100_000_000) per token")
            }
            if let completionPrice = model.completionTextTokenPrice {
                print("  Completion price: $\(Double(completionPrice) / 100_000_000) per token")
            }
            if let aliases = model.aliases, !aliases.isEmpty {
                print("  Aliases: \(aliases.joined(separator: ", "))")
            }
        }
    }
}

struct ModelsImage: xAICommand {
    static let configuration = CommandConfiguration(
        commandName: "image",
        abstract: "List image generation models with detailed information"
    )
    
    @Option(help: "API key")
    var apiKey: String?
    
    @Option(help: "API base URL")
    var apiURL: String?
    
    func run() async throws {
        let client = try createClient()
        let models = try await client.models.listImageGenerationModels()
        
        print("Image generation models:")
        for model in models {
            print("\n\(model.id)")
            print("  Version: \(model.version ?? "N/A")")
            if let maxPromptLength = model.maxPromptLength {
                print("  Max prompt length: \(maxPromptLength)")
            }
            if let imagePrice = model.imagePrice {
                print("  Image price: $\(Double(imagePrice) / 100) per image")
            }
            if let aliases = model.aliases, !aliases.isEmpty {
                print("  Aliases: \(aliases.joined(separator: ", "))")
            }
        }
    }
}

// MARK: - Tokenize Command

struct Tokenize: xAICommand {
    static let configuration = CommandConfiguration(
        abstract: "Tokenize text"
    )
    
    @Option(help: "API key")
    var apiKey: String?
    
    @Option(help: "API base URL")
    var apiURL: String?
    
    @Argument(help: "Text to tokenize")
    var text: String
    
    @Option(help: "Model to use for tokenization")
    var model: String = "grok-3-fast-latest"
    
    @Flag(help: "Show token details")
    var details = false
    
    func run() async throws {
        let client = try createClient()
        let response = try await client.tokenization.tokenize(text: text, model: model)
        
        print("Token count: \(response.tokenIds.count)")
        
        if details {
            print("\nTokens:")
            for token in response.tokenIds {
                print("  ID: \(token.tokenId), String: '\(token.stringToken)'")
            }
        } else {
            let ids = response.tokenIds.map { String($0.tokenId) }.joined(separator: ", ")
            print("Token IDs: [\(ids)]")
        }
    }
}

// MARK: - API Key Command

struct APIKey: xAICommand {
    static let configuration = CommandConfiguration(
        abstract: "Get API key information"
    )
    
    @Option(help: "API key")
    var apiKey: String?
    
    @Option(help: "API base URL")
    var apiURL: String?
    
    func run() async throws {
        let client = try createClient()
        let info = try await client.apiKey.getInfo()
        
        print("API Key Information:")
        print("  Key: \(info.redactedAPIKey)")
        print("  Name: \(info.name)")
        print("  User ID: \(info.userId)")
        print("  Team ID: \(info.teamId)")
        print("  Created: \(info.createTime)")
        print("  Modified: \(info.modifyTime)")
        print("  Status:")
        print("    Disabled: \(info.apiKeyDisabled ? "Yes" : "No")")
        print("    Blocked: \(info.apiKeyBlocked ? "Yes" : "No")")
        print("    Team blocked: \(info.teamBlocked ? "Yes" : "No")")
        print("  Permissions: \(info.acls.joined(separator: ", "))")
    }
}

// MARK: - Complete Command (Legacy)

struct Complete: xAICommand {
    static let configuration = CommandConfiguration(
        abstract: "Legacy completion commands",
        subcommands: [CompleteOpenAI.self, CompleteAnthropic.self]
    )
    
    @Option(help: "API key")
    var apiKey: String?
    
    @Option(help: "API base URL")
    var apiURL: String?
}

struct CompleteOpenAI: xAICommand {
    static let configuration = CommandConfiguration(
        commandName: "openai",
        abstract: "Create a completion (OpenAI legacy format)"
    )
    
    @Option(help: "API key")
    var apiKey: String?
    
    @Option(help: "API base URL")
    var apiURL: String?
    
    @Argument(help: "The prompt to complete")
    var prompt: String
    
    @Option(help: "The model to use")
    var model: String = "grok-3-fast-latest"
    
    @Option(help: "Maximum tokens to generate")
    var maxTokens: Int = 100
    
    @Option(help: "Temperature (0-2)")
    var temperature: Double?
    
    func run() async throws {
        let client = try createClient()
        
        let response = try await client.completions.create(
            prompt: prompt,
            model: model,
            maxTokens: maxTokens,
            temperature: temperature
        )
        
        if let text = response.choices.first?.text {
            print(text)
        }
        
        print("\n---")
        print("Model: \(response.model)")
        let usage = response.usage
        print("Tokens: \(usage.promptTokens) prompt + \(usage.completionTokens) completion = \(usage.totalTokens) total")
    }
}

struct CompleteAnthropic: xAICommand {
    static let configuration = CommandConfiguration(
        commandName: "anthropic",
        abstract: "Create a completion (Anthropic legacy format)"
    )
    
    @Option(help: "API key")
    var apiKey: String?
    
    @Option(help: "API base URL")
    var apiURL: String?
    
    @Argument(help: "The prompt to complete")
    var prompt: String
    
    @Option(help: "The model to use")
    var model: String = "grok-3-fast-beta"
    
    @Option(help: "Maximum tokens to generate")
    var maxTokens: Int = 100
    
    @Option(help: "Temperature (0-1)")
    var temperature: Double?
    
    func run() async throws {
        let client = try createClient()
        
        let response = try await client.completions.complete(
            prompt: prompt,
            model: model,
            maxTokensToSample: maxTokens,
            temperature: temperature
        )
        
        print(response.completion)
        print("\n---")
        print("Model: \(response.model)")
        if let stopReason = response.stopReason {
            print("Stop reason: \(stopReason.rawValue)")
        }
    }
}