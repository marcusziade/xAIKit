import xAIKit

let client = xAIClient(apiKey: "your-api-key")

let imageURL = "https://example.com/image.jpg"
let imageContent = ChatMessage.Content.image(url: imageURL)
let textContent = ChatMessage.Content.text("What's in this image?")
let message = ChatMessage(role: .user, content: [imageContent, textContent])

// Use a vision-capable model
do {
    let response = try await client.chat.completions(
        messages: [message],
        model: "grok-2-vision"  // Vision-capable model
    )
    
    if let analysis = response.choices.first?.message.content {
        print("Image analysis: \(analysis)")
    }
} catch {
    print("Error analyzing image: \(error)")
}