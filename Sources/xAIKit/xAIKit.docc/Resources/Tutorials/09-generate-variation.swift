import xAIKit

struct ImageWorkflow {
    let client: xAIClient
    
    init(apiKey: String) {
        self.client = xAIClient(apiKey: apiKey)
    }
    
    func analyzeAndGenerate(imageURL: String) async throws {
        let analysis = try await analyzeImage(url: imageURL)
        let newImage = try await generateVariation(basedOn: analysis)
        
        print("Original image analyzed")
        print("New image generated: \(newImage)")
    }
    
    private func analyzeImage(url: String) async throws -> String {
        let imageContent = ChatMessage.Content.image(url: url)
        let textContent = ChatMessage.Content.text(
            """
            Analyze this image and provide:
            1. Main subjects and objects
            2. Color palette and lighting
            3. Artistic style or mood
            4. Composition and perspective
            Format as a brief, descriptive paragraph.
            """
        )
        
        let message = ChatMessage(role: .user, content: [imageContent, textContent])
        
        let response = try await client.chat.completions(
            messages: [message],
            model: "grok-2-vision"
        )
        
        guard let analysis = response.choices.first?.message.content else {
            throw xAIError.invalidResponse
        }
        
        return analysis
    }
    
    private func generateVariation(basedOn analysis: String) async throws -> String {
        // Create a concise prompt from the analysis
        let promptRequest = ChatMessage(
            role: .user,
            content: "Based on this image analysis, create a concise prompt (max 80 words) for generating a creative variation: \(analysis)"
        )
        
        let promptResponse = try await client.chat.completions(
            messages: [promptRequest],
            model: "grok-3-mini-fast-latest",
            maxTokens: 100,
            temperature: 0.7
        )
        
        guard let prompt = promptResponse.choices.first?.message.content else {
            throw xAIError.invalidResponse
        }
        
        // Generate the new image
        let imageResponse = try await client.images.generate(
            prompt: prompt,
            model: "grok-2-image"
        )
        
        guard let imageURL = imageResponse.data.first?.url else {
            throw xAIError.invalidResponse
        }
        
        print("Generated prompt: \(prompt)")
        return imageURL
    }
}

// Example usage
let workflow = ImageWorkflow(apiKey: "your-api-key")
try await workflow.analyzeAndGenerate(imageURL: "https://example.com/original.jpg")