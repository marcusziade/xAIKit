import xAIKit

let client = xAIClient(apiKey: "your-api-key")

// Create a message with image content
let imageURL = "https://example.com/image.jpg"

// Create content blocks for the message
let imageContent = ChatMessage.Content.image(url: imageURL)
let textContent = ChatMessage.Content.text("What's in this image?")

// Combine them into a message
let message = ChatMessage(
    role: .user,
    content: [imageContent, textContent]
)