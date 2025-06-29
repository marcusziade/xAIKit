import Foundation
import xAIKit

@main
struct ImageGenerator {
    static func main() async throws {
        guard let apiKey = ProcessInfo.processInfo.environment["XAI_API_KEY"] else {
            print("Error: XAI_API_KEY environment variable not set")
            exit(1)
        }
        
        let client = xAIClient(apiKey: apiKey)
        
        print("🎨 Multiple Image Generation")
        print("===========================")
        print()
        
        let prompt = "A futuristic cityscape with flying cars and neon lights"
        let numberOfImages = 3
        
        print("Generating \(numberOfImages) variations of:")
        print("\"\(prompt)\"")
        print()
        
        do {
            // Request multiple images
            let response = try await client.images.generate(
                prompt: prompt,
                model: "grok-2-image",
                n: numberOfImages
            )
            
            print("✓ Generated \(response.data.count) image(s)!\n")
            
            // Display all image URLs
            for (index, image) in response.data.enumerated() {
                print("Image \(index + 1):")
                if let url = image.url {
                    print("  URL: \(url)")
                }
                if let revisedPrompt = image.revisedPrompt {
                    print("  Revised: \(String(revisedPrompt.prefix(100)))...")
                }
                print()
            }
        } catch {
            print("❌ Error: \(error)")
        }
    }
}