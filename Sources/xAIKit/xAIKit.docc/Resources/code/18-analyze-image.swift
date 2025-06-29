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
        
        print("🔍 Image Analysis with Vision")
        print("============================")
        print()
        
        // URL of an image to analyze (could be from previous generation)
        let imageURL = "https://example.com/generated_image.png"
        
        // Create a message with image content
        let message = ChatMessage(
            role: .user,
            content: [
                .image(url: imageURL),
                .text("Describe this image in detail. What do you see?")
            ]
        )
        
        print("Analyzing image...")
        print()
        
        do {
            let response = try await client.chat.completions(
                messages: [message],
                model: "grok-2-vision" // Use a vision-capable model
            )
            
            if let analysis = response.choices.first?.message.content {
                print("Image Analysis:")
                print("===============")
                print(analysis)
            }
        } catch {
            print("❌ Error analyzing image: \(error)")
        }
    }
}