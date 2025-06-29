import Foundation
import xAIKit

// Get API key from environment variable
guard let apiKey = ProcessInfo.processInfo.environment["XAI_API_KEY"] else {
    print("Error: XAI_API_KEY environment variable not set")
    print("Please run: export XAI_API_KEY='your-api-key'")
    exit(1)
}

// Initialize the xAI client
let client = xAIClient(apiKey: apiKey)

print("✓ xAI client initialized successfully!")