import Foundation
import xAIKit

@main
struct xAIAssistant {
    static func main() async throws {
        guard let apiKey = ProcessInfo.processInfo.environment["XAI_API_KEY"] else {
            print("Error: XAI_API_KEY environment variable not set")
            print("Please run: export XAI_API_KEY='your-api-key'")
            exit(1)
        }
        
        let client = xAIClient(apiKey: apiKey)
        var messages: [Message] = []
        
        print("🤖 xAI Assistant (with streaming)")
        print("=================================")
        print("Type 'quit' to exit, 'clear' to start a new conversation")
        print()
        
        while true {
            print("You: ", terminator: "")
            guard let userInput = readLine(), !userInput.isEmpty else {
                continue
            }
            
            if userInput.lowercased() == "quit" {
                print("Goodbye!")
                break
            } else if userInput.lowercased() == "clear" {
                messages.removeAll()
                print("✓ Conversation cleared\n")
                continue
            }
            
            messages.append(Message(role: .user, content: userInput))
            
            let request = ChatRequest(
                model: .grokBeta,
                messages: messages,
                stream: true
            )
            
            do {
                print("\nAssistant: ", terminator: "")
                
                var fullResponse = ""
                var tokenCount = 0
                
                for try await chunk in client.chat.stream(request) {
                    // Process each chunk
                    if let delta = chunk.choices.first?.delta {
                        if let content = delta.content {
                            print(content, terminator: "")
                            fflush(stdout)
                            fullResponse += content
                            tokenCount += 1
                        }
                        
                        // Check for finish reason
                        if let finishReason = chunk.choices.first?.finishReason {
                            switch finishReason {
                            case .stop:
                                // Normal completion
                                break
                            case .length:
                                print("\n[Response truncated due to length limit]")
                            case .contentFilter:
                                print("\n[Response filtered]")
                            default:
                                break
                            }
                        }
                    }
                }
                
                messages.append(Message(role: .assistant, content: fullResponse))
                print("\n[Streamed \(tokenCount) chunks]\n")
            } catch {
                print("❌ Error: \(error)\n")
            }
        }
    }
}