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
        
        print("🤖 xAI Assistant")
        print("================")
        print()
        
        // Get user input
        print("You: ", terminator: "")
        guard let userInput = readLine(), !userInput.isEmpty else {
            print("No input received.")
            return
        }
        
        // Create and send request
        let request = ChatRequest(
            model: .grokBeta,
            messages: [
                Message(role: .user, content: userInput)
            ]
        )
        
        do {
            print("\nAssistant: ", terminator: "")
            let response = try await client.chat.completions(request)
            
            if let content = response.choices.first?.message.content {
                print(content)
            }
            
            // Display token usage
            if let usage = response.usage {
                print("\n[Tokens - Prompt: \(usage.promptTokens), Response: \(usage.completionTokens), Total: \(usage.totalTokens)]")
            }
        } catch {
            print("❌ Error: \(error)")
        }
    }
}