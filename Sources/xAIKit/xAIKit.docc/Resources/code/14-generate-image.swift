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
        
        // Define a creative prompt
        let prompt = "A serene Japanese garden with cherry blossoms, a wooden bridge over a koi pond, and Mount Fuji in the background at sunset"
        
        print("Generating image with prompt:")
        print("\"\(prompt)\"")
        print()
        
        do {
            // Generate the image
            let response = try await client.images.generate(
                prompt: prompt,
                model: "grok-2-image"
            )
            
            print("✓ Image generated successfully!")
        } catch {
            print("❌ Error generating image: \(error)")
        }
    }
}