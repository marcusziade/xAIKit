import Foundation
import xAIKit

@main
struct ImageEditor {
    static func main() async throws {
        guard let apiKey = ProcessInfo.processInfo.environment["XAI_API_KEY"] else {
            print("Error: XAI_API_KEY environment variable not set")
            exit(1)
        }
        
        let client = xAIClient(apiKey: apiKey)
        
        print("🎨 Applying Image Edits")
        print("======================")
        print()
        
        // Step 1: Analyze the original image
        let originalImageURL = "https://example.com/summer_landscape.png"
        let editRequest = "Transform this into a magical winter wonderland"
        
        print("Analyzing original image...")
        
        let analysisMessage = ChatMessage(
            role: .user,
            content: [
                .image(url: originalImageURL),
                .text("Analyze this image and create a detailed prompt to transform it into: \(editRequest)")
            ]
        )
        
        do {
            let analysisResponse = try await client.chat.completions(
                messages: [analysisMessage],
                model: "grok-2-vision"
            )
            
            guard let newPrompt = analysisResponse.choices.first?.message.content else {
                print("Failed to get edit suggestions")
                return
            }
            
            print("\nGenerated prompt for edited image:")
            print(newPrompt)
            print("\nGenerating new image...")
            
            // Step 2: Generate the edited image
            let imageResponse = try await client.images.generate(
                prompt: newPrompt,
                model: "grok-2-image"
            )
            
            if let editedImageURL = imageResponse.data.first?.url {
                print("\n✓ Edited image generated!")
                print("Original: \(originalImageURL)")
                print("Edited: \(editedImageURL)")
            }
        } catch {
            print("❌ Error: \(error)")
        }
    }
}