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
        
        print("🤖 xAI Assistant")
        print("================")
        print("Type 'quit' to exit, 'clear' to start a new conversation")
        print()
        
        while true {
            print("You: ", terminator: "")
            guard let userInput = readLine(), !userInput.isEmpty else {
                continue
            }
            
            // Handle commands
            if userInput.lowercased() == "quit" {
                print("Goodbye!")
                break
            } else if userInput.lowercased() == "clear" {
                messages.removeAll()
                print("✓ Conversation cleared\n")
                continue
            }
            
            // Add user message to history
            messages.append(Message(role: .user, content: userInput))
            
            // Create request with conversation history
            let request = ChatRequest(
                model: .grokBeta,
                messages: messages
            )
            
            do {
                print("\nAssistant: ", terminator: "")
                let response = try await client.chat.completions(request)
                
                if let assistantMessage = response.choices.first?.message {
                    print(assistantMessage.content ?? "")
                    messages.append(assistantMessage)
                }
                
                print()
            } catch {
                print("❌ Error: \(error)\n")
            }
        }
    }
}