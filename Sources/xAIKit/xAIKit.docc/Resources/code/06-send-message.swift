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
        
        print("✓ xAI Assistant is ready!")
        print()
        
        // Create a chat request
        let request = ChatRequest(
            model: .grokBeta,
            messages: [
                Message(role: .user, content: "Hello! What can you help me with today?")
            ]
        )
        
        // Send the request and get response
        do {
            let response = try await client.chat.completions(request)
            if let content = response.choices.first?.message.content {
                print("Assistant: \(content)")
            }
        } catch {
            print("Error: \(error)")
        }
    }
}