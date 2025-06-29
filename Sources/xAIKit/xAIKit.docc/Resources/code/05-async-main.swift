import Foundation
import xAIKit

@main
struct xAIAssistant {
    static func main() async throws {
        // Get API key from environment variable
        guard let apiKey = ProcessInfo.processInfo.environment["XAI_API_KEY"] else {
            print("Error: XAI_API_KEY environment variable not set")
            print("Please run: export XAI_API_KEY='your-api-key'")
            exit(1)
        }
        
        // Initialize the xAI client
        let client = xAIClient(apiKey: apiKey)
        
        print("✓ xAI Assistant is ready!")
        print("Type 'quit' to exit")
        print()
        
        // Main application logic will go here
    }
}