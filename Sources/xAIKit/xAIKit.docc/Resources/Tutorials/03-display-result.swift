import xAIKit

let client = xAIClient(apiKey: "your-api-key")
let imagesAPI = client.images

let prompt = "A serene landscape with mountains and a lake at sunset"

do {
    let response = try await imagesAPI.generate(
        prompt: prompt,
        model: "grok-2-image"
    )
    
    // Access the generated image
    if let imageData = response.data.first {
        if let imageURL = imageData.url {
            print("Image URL: \(imageURL)")
            // You can now download or display this image
        } else if let base64Data = imageData.b64Json {
            print("Image data (base64): \(base64Data.prefix(50))...")
            // You can decode and use the base64 data
        }
        
        // Check if the prompt was revised
        if let revisedPrompt = imageData.revisedPrompt {
            print("Revised prompt: \(revisedPrompt)")
        }
    }
} catch {
    print("Error generating image: \(error)")
}