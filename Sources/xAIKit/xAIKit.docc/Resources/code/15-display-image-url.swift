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
        
        print("🎨 xAI Image Generator")
        print("=====================")
        print()
        
        let prompt = "A serene Japanese garden with cherry blossoms, a wooden bridge over a koi pond, and Mount Fuji in the background at sunset"
        
        print("Generating image...")
        
        do {
            let response = try await client.images.generate(
                prompt: prompt,
                model: "grok-2-image"
            )
            
            // Display the results
            if let firstImage = response.data.first {
                print("\n✓ Image generated successfully!")
                
                if let url = firstImage.url {
                    print("\nImage URL:")
                    print(url)
                    print("\nOpen this URL in your browser to view the image.")
                }
                
                if let revisedPrompt = firstImage.revisedPrompt {
                    print("\nRevised prompt used by the model:")
                    print(revisedPrompt)
                }
            }
        } catch {
            print("❌ Error: \(error)")
        }
    }
}