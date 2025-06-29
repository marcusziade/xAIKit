import Foundation
import xAIKit

@main
struct ImageGenerator {
    static func main() async throws {
        // Get API key from environment
        guard let apiKey = ProcessInfo.processInfo.environment["XAI_API_KEY"] else {
            print("Error: XAI_API_KEY environment variable not set")
            exit(1)
        }
        
        // Initialize the xAI client
        let client = xAIClient(apiKey: apiKey)
        
        print("🎨 xAI Image Generator")
        print("=====================")
        print("Ready to create amazing images!")
        print()
    }
}