import xAIKit

let client = xAIClient(apiKey: "your-api-key")
let imagesAPI = client.images

// Generate an image from a text prompt
let prompt = "A serene landscape with mountains and a lake at sunset"

do {
    let response = try await imagesAPI.generate(
        prompt: prompt,
        model: "grok-2-image"
    )
    
    // The response contains the generated image data
    print("Generated \(response.data.count) image(s)")
} catch {
    print("Error generating image: \(error)")
}