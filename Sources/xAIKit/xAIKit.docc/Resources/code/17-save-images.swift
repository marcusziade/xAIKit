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
        
        print("🎨 Saving Generated Images")
        print("=========================")
        print()
        
        let prompt = "A majestic dragon soaring through clouds"
        
        do {
            let response = try await client.images.generate(
                prompt: prompt,
                model: "grok-2-image"
            )
            
            for (index, image) in response.data.enumerated() {
                guard let urlString = image.url,
                      let url = URL(string: urlString) else {
                    continue
                }
                
                print("Downloading image \(index + 1)...")
                
                // Download the image
                let (data, _) = try await URLSession.shared.data(from: url)
                
                // Save to file
                let filename = "generated_image_\(index + 1).png"
                let fileURL = URL(fileURLWithPath: filename)
                
                try data.write(to: fileURL)
                print("✓ Saved as: \(filename)")
                
                // Store the local path for further processing
                print("  Local path: \(fileURL.path)")
                print("  Size: \(ByteCountFormatter.string(fromByteCount: Int64(data.count), countStyle: .file))")
                print()
            }
        } catch {
            print("❌ Error: \(error)")
        }
    }
}