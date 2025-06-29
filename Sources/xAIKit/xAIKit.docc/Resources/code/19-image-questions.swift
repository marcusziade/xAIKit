import Foundation
import xAIKit

@main
struct ImageAnalyzer {
    static func main() async throws {
        guard let apiKey = ProcessInfo.processInfo.environment["XAI_API_KEY"] else {
            print("Error: XAI_API_KEY environment variable not set")
            exit(1)
        }
        
        let client = xAIClient(apiKey: apiKey)
        
        print("🔍 Asking Questions About Images")
        print("================================")
        print()
        
        let imageURL = "https://example.com/generated_image.png"
        
        // Different questions to ask about the image
        let questions = [
            "What is the main subject of this image?",
            "What colors dominate the image?",
            "What mood or emotion does this image convey?",
            "Are there any text or symbols visible?",
            "What artistic style is used in this image?"
        ]
        
        for question in questions {
            print("Q: \(question)")
            
            let message = ChatMessage(
                role: .user,
                content: [
                    .image(url: imageURL),
                    .text(question)
                ]
            )
            
            do {
                let response = try await client.chat.completions(
                    messages: [message],
                    model: "grok-2-vision",
                    maxTokens: 150 // Keep answers concise
                )
                
                if let answer = response.choices.first?.message.content {
                    print("A: \(answer)")
                    print()
                }
            } catch {
                print("Error: \(error)")
            }
        }
    }
}