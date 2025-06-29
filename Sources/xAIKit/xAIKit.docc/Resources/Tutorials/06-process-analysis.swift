import xAIKit

let client = xAIClient(apiKey: "your-api-key")

let imageURL = "https://example.com/image.jpg"
let imageContent = ChatMessage.Content.image(url: imageURL)
let textContent = ChatMessage.Content.text("Describe the main objects, colors, and mood of this image")
let message = ChatMessage(role: .user, content: [imageContent, textContent])

do {
    let response = try await client.chat.completions(
        messages: [message],
        model: "grok-2-vision"
    )
    
    if let analysis = response.choices.first?.message.content {
        print("Image analysis:")
        print(analysis)
        
        // You can now use this analysis for various purposes:
        // - Generate alt text for accessibility
        // - Extract keywords for search
        // - Create variations of the image
        // - Build a scene description
        
        // Extract key information
        let keywords = extractKeywords(from: analysis)
        print("\nExtracted keywords: \(keywords.joined(separator: ", "))")
    }
} catch {
    print("Error analyzing image: \(error)")
}

func extractKeywords(from text: String) -> [String] {
    // Simple keyword extraction (in production, use NLP)
    let words = text.components(separatedBy: .whitespacesAndNewlines)
    return words.filter { $0.count > 4 }.prefix(5).map { $0 }
}