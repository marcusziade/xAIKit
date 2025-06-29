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
        
        print("✏️ Image Edit Suggestions")
        print("========================")
        print()
        
        // Function to analyze image and suggest edits
        func suggestEdits(
            imageURL: String,
            editRequest: String
        ) async throws -> String {
            let message = ChatMessage(
                role: .user,
                content: [
                    .image(url: imageURL),
                    .text("""
                    I want to edit this image. My request: "\(editRequest)"
                    
                    Please analyze the current image and provide:
                    1. A description of what changes would be needed
                    2. A detailed prompt for generating a new image with these edits
                    3. Any specific style or technique recommendations
                    """)
                ]
            )
            
            let response = try await client.chat.completions(
                messages: [message],
                model: "grok-2-vision"
            )
            
            return response.choices.first?.message.content ?? ""
        }
        
        // Example usage
        let imageURL = "https://example.com/landscape.png"
        let editRequest = "Make it a winter scene with snow"
        
        print("Original image: \(imageURL)")
        print("Edit request: \(editRequest)")
        print("\nAnalyzing and generating suggestions...")
        
        do {
            let suggestions = try await suggestEdits(
                imageURL: imageURL,
                editRequest: editRequest
            )
            
            print("\nEdit Suggestions:")
            print("================")
            print(suggestions)
        } catch {
            print("❌ Error: \(error)")
        }
    }
}