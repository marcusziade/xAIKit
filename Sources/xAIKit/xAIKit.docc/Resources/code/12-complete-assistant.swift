import Foundation
import xAIKit

@main
struct xAIAssistant {
    static func main() async throws {
        guard let apiKey = ProcessInfo.processInfo.environment["XAI_API_KEY"] else {
            print("❌ Error: XAI_API_KEY environment variable not set")
            print("💡 Please run: export XAI_API_KEY='your-api-key'")
            exit(1)
        }
        
        let client = xAIClient(apiKey: apiKey)
        
        let systemMessage = Message(
            role: .system,
            content: """
            You are a helpful, friendly, and knowledgeable AI assistant powered by xAI.
            You excel at:
            - Answering questions clearly and concisely
            - Breaking down complex topics into understandable explanations
            - Providing creative solutions to problems
            - Writing code and technical documentation
            - Engaging in thoughtful conversations
            
            Use emojis occasionally to make conversations more engaging.
            Always be respectful, honest, and aim to be genuinely helpful.
            """
        )
        
        var messages: [Message] = [systemMessage]
        
        printWelcome()
        
        while true {
            print("You: ", terminator: "")
            guard let userInput = readLine()?.trimmingCharacters(in: .whitespaces),
                  !userInput.isEmpty else {
                continue
            }
            
            // Handle commands
            switch userInput.lowercased() {
            case "quit", "exit", "bye":
                printGoodbye()
                return
            case "clear", "reset":
                messages = [systemMessage]
                print("✨ Conversation cleared! Let's start fresh.\n")
                continue
            case "help", "?":
                printHelp()
                continue
            case "model":
                print("🤖 Using model: Grok Beta\n")
                continue
            default:
                break
            }
            
            messages.append(Message(role: .user, content: userInput))
            
            let request = ChatRequest(
                model: .grokBeta,
                messages: messages,
                stream: true,
                temperature: 0.7,
                maxTokens: 2000
            )
            
            do {
                print("\n🤖 Assistant: ", terminator: "")
                
                var fullResponse = ""
                let startTime = Date()
                
                for try await chunk in client.chat.stream(request) {
                    if let content = chunk.choices.first?.delta?.content {
                        print(content, terminator: "")
                        fflush(stdout)
                        fullResponse += content
                    }
                }
                
                let responseTime = Date().timeIntervalSince(startTime)
                messages.append(Message(role: .assistant, content: fullResponse))
                
                print("\n\(String(format: "⚡ Response time: %.2fs", responseTime))\n")
            } catch {
                handleError(error)
            }
        }
    }
    
    static func printWelcome() {
        print("""
        ╔═══════════════════════════════════════╗
        ║       🤖 xAI Assistant v2.0 🤖        ║
        ║     Powered by Grok Technology        ║
        ╚═══════════════════════════════════════╝
        
        Welcome! I'm your AI assistant powered by xAI.
        
        📝 Commands:
        • quit/exit - End conversation
        • clear/reset - Start a new conversation
        • help/? - Show this help
        • model - Show current model
        
        Let's chat! What can I help you with today?
        
        """)
    }
    
    static func printHelp() {
        print("""
        
        📚 Available Commands:
        • quit, exit, bye - End the conversation
        • clear, reset - Clear conversation history
        • help, ? - Show this help message
        • model - Display the current AI model
        
        💡 Tips:
        • I maintain context throughout our conversation
        • Feel free to ask follow-up questions
        • I can help with coding, writing, analysis, and more!
        
        """)
    }
    
    static func printGoodbye() {
        print("""
        
        👋 Thanks for chatting!
        Have a great day!
        
        """)
    }
    
    static func handleError(_ error: Error) {
        print("\n\n❌ Oops! Something went wrong:")
        
        if let xaiError = error as? xAIError {
            switch xaiError {
            case .invalidAPIKey:
                print("Invalid API key. Please check your XAI_API_KEY.")
            case .rateLimitExceeded:
                print("Rate limit exceeded. Please wait a moment.")
            case .networkError(let underlying):
                print("Network error: \(underlying.localizedDescription)")
            case .decodingError:
                print("Failed to process the response.")
            case .apiError(let code, let message):
                print("API error (\(code)): \(message)")
            default:
                print("Error: \(xaiError)")
            }
        } else {
            print("Unexpected error: \(error)")
        }
        
        print("\nLet's try again!\n")
    }
}