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
        
        // Define system instructions for the assistant
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
            
            Always be respectful, honest, and aim to be genuinely helpful.
            If you're not sure about something, say so.
            """
        )
        
        var messages: [Message] = [systemMessage]
        
        print("🤖 xAI Assistant (v2.0)")
        print("======================")
        print("Your helpful AI assistant is ready!")
        print("Commands: 'quit' to exit, 'clear' to start fresh")
        print()
        
        while true {
            print("You: ", terminator: "")
            guard let userInput = readLine(), !userInput.isEmpty else {
                continue
            }
            
            if userInput.lowercased() == "quit" {
                print("Thanks for chatting! Goodbye! 👋")
                break
            } else if userInput.lowercased() == "clear" {
                messages = [systemMessage] // Keep system message
                print("✓ Conversation cleared (keeping personality)\n")
                continue
            }
            
            messages.append(Message(role: .user, content: userInput))
            
            let request = ChatRequest(
                model: .grokBeta,
                messages: messages,
                stream: true,
                temperature: 0.7  // Add some creativity
            )
            
            do {
                print("\nAssistant: ", terminator: "")
                
                var fullResponse = ""
                for try await chunk in client.chat.stream(request) {
                    if let content = chunk.choices.first?.delta?.content {
                        print(content, terminator: "")
                        fflush(stdout)
                        fullResponse += content
                    }
                }
                
                messages.append(Message(role: .assistant, content: fullResponse))
                print("\n")
            } catch {
                print("❌ Error: \(error)\n")
            }
        }
    }
}