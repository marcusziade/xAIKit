import Foundation
import xAIKit

@main
struct ImageEditingAssistant {
    static func main() async throws {
        guard let apiKey = ProcessInfo.processInfo.environment["XAI_API_KEY"] else {
            print("Error: XAI_API_KEY environment variable not set")
            exit(1)
        }
        
        let client = xAIClient(apiKey: apiKey)
        
        print("🎨 AI Image Editing Assistant")
        print("============================")
        print("Commands: 'generate', 'edit', 'analyze', 'quit'")
        print()
        
        var currentImageURL: String?
        
        while true {
            print("Command: ", terminator: "")
            guard let command = readLine()?.lowercased() else { continue }
            
            switch command {
            case "generate":
                print("Enter prompt: ", terminator: "")
                guard let prompt = readLine(), !prompt.isEmpty else { continue }
                
                print("\nGenerating image...")
                do {
                    let response = try await client.images.generate(
                        prompt: prompt,
                        model: "grok-2-image"
                    )
                    
                    if let url = response.data.first?.url {
                        currentImageURL = url
                        print("✓ Image generated: \(url)\n")
                    }
                } catch {
                    print("❌ Error: \(error)\n")
                }
                
            case "edit":
                guard let imageURL = currentImageURL else {
                    print("No image loaded. Generate one first!\n")
                    continue
                }
                
                print("Current image: \(imageURL)")
                print("Describe your edit: ", terminator: "")
                guard let editRequest = readLine(), !editRequest.isEmpty else { continue }
                
                print("\nAnalyzing and planning edit...")
                
                do {
                    // Get edit suggestions
                    let analysisMessage = ChatMessage(
                        role: .user,
                        content: [
                            .image(url: imageURL),
                            .text("""
                            Create a detailed image generation prompt that would result in this image but with the following modification: \(editRequest)
                            
                            Be specific about all visual elements, style, composition, and the requested changes.
                            """)
                        ]
                    )
                    
                    let analysis = try await client.chat.completions(
                        messages: [analysisMessage],
                        model: "grok-2-vision"
                    )
                    
                    if let newPrompt = analysis.choices.first?.message.content {
                        print("\nGenerating edited image...")
                        
                        let imageResponse = try await client.images.generate(
                            prompt: newPrompt,
                            model: "grok-2-image"
                        )
                        
                        if let newURL = imageResponse.data.first?.url {
                            currentImageURL = newURL
                            print("✓ Edited image: \(newURL)\n")
                        }
                    }
                } catch {
                    print("❌ Error: \(error)\n")
                }
                
            case "analyze":
                guard let imageURL = currentImageURL else {
                    print("No image loaded. Generate one first!\n")
                    continue
                }
                
                print("Analyzing image...")
                
                do {
                    let message = ChatMessage(
                        role: .user,
                        content: [
                            .image(url: imageURL),
                            .text("Provide a detailed analysis of this image including composition, colors, style, mood, and any notable elements.")
                        ]
                    )
                    
                    let response = try await client.chat.completions(
                        messages: [message],
                        model: "grok-2-vision"
                    )
                    
                    if let analysis = response.choices.first?.message.content {
                        print("\nAnalysis:")
                        print(analysis)
                        print()
                    }
                } catch {
                    print("❌ Error: \(error)\n")
                }
                
            case "quit":
                print("Goodbye! 👋")
                return
                
            default:
                print("Unknown command. Use: generate, edit, analyze, or quit\n")
            }
        }
    }
}