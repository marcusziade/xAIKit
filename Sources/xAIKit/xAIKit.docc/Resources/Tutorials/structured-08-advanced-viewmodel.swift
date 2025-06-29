import Foundation
import xAIKit

@MainActor
class AdvancedRecipeParserViewModel: ObservableObject {
    @Published var inputText = ""
    @Published var parsedRecipe: AdvancedRecipe?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let client: xAIClient
    
    init() {
        self.client = xAIClient(apiKey: ProcessInfo.processInfo.environment["XAI_API_KEY"] ?? "")
    }
    
    func parseRecipe() async {
        guard !inputText.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        parsedRecipe = nil
        
        do {
            let responseFormat = ResponseFormat(type: .jsonObject, jsonSchema: nil)
            
            let systemPrompt = """
            You are an expert recipe parser and nutritionist. Extract detailed recipe information and return JSON with this structure:
            {
                "name": "Recipe Name",
                "description": "Brief description",
                "servings": 4,
                "prepTime": 15,
                "cookTime": 30,
                "difficulty": "easy|medium|hard",
                "cuisine": "Italian|Mexican|etc",
                "mealType": ["breakfast", "lunch", "dinner", "snack"],
                "ingredients": [
                    {
                        "name": "ingredient",
                        "amount": 2.5,
                        "unit": "cups",
                        "preparation": "diced",
                        "category": "vegetable"
                    }
                ],
                "instructions": [
                    {
                        "step": 1,
                        "description": "Step description",
                        "duration": 5,
                        "temperature": {"value": 350, "unit": "F"}
                    }
                ],
                "dietaryInfo": {
                    "vegetarian": true,
                    "vegan": false,
                    "glutenFree": false,
                    "dairyFree": false,
                    "nutFree": true
                },
                "nutrition": {
                    "calories": 350,
                    "protein": 25.5,
                    "carbohydrates": 40.0,
                    "fat": 15.0,
                    "fiber": 5.0,
                    "sugar": 8.0,
                    "sodium": 600.0
                }
            }
            
            Estimate nutritional information if not provided. Analyze dietary restrictions based on ingredients.
            """
            
            let messages = [
                ChatMessage(role: .system, content: systemPrompt),
                ChatMessage(role: .user, content: "Parse this recipe with full details: \(inputText)")
            ]
            
            let request = ChatCompletionRequest(
                messages: messages,
                model: "grok-3-fast",  // Using a more capable model for complex parsing
                responseFormat: responseFormat,
                temperature: 0.3  // Lower temperature for more consistent structured output
            )
            
            let response = try await client.chat.completions(request)
            
            if let content = response.choices.first?.message.content,
               let data = content.data(using: .utf8) {
                let decoder = JSONDecoder()
                parsedRecipe = try decoder.decode(AdvancedRecipe.self, from: data)
            }
        } catch {
            errorMessage = "Failed to parse recipe: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // Helper function to validate and fix common parsing issues
    func validateRecipe(_ recipe: AdvancedRecipe) -> AdvancedRecipe {
        // Add any validation or correction logic here
        return recipe
    }
}