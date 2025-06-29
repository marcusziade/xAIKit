import Foundation
import xAIKit

@MainActor
class RecipeParserViewModel: ObservableObject {
    @Published var inputText = ""
    @Published var parsedRecipe: Recipe?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let client: xAIClient
    
    init() {
        // Initialize with your API key
        self.client = xAIClient(apiKey: ProcessInfo.processInfo.environment["XAI_API_KEY"] ?? "")
    }
    
    func parseRecipe() async {
        guard !inputText.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        parsedRecipe = nil
        
        do {
            // For xAI: Use json_object response format
            // This guarantees JSON output but doesn't enforce schema validation
            let responseFormat = ResponseFormat(type: .jsonObject, jsonSchema: nil)
            
            // For OpenAI-compatible APIs: You can use json_schema with full validation
            // let schema: [String: Any] = [
            //     "type": "object",
            //     "properties": [
            //         "name": ["type": "string"],
            //         "servings": ["type": "integer", "minimum": 1],
            //         "prepTime": ["type": "integer", "minimum": 0],
            //         "cookTime": ["type": "integer", "minimum": 0],
            //         "difficulty": ["type": "string", "enum": ["easy", "medium", "hard"]],
            //         "ingredients": [
            //             "type": "array",
            //             "items": [
            //                 "type": "object",
            //                 "properties": [
            //                     "name": ["type": "string"],
            //                     "amount": ["type": "string"],
            //                     "unit": ["type": "string"]
            //                 ],
            //                 "required": ["name", "amount"]
            //             ]
            //         ],
            //         "instructions": [
            //             "type": "array",
            //             "items": ["type": "string"]
            //         ]
            //     ],
            //     "required": ["name", "servings", "prepTime", "cookTime", "difficulty", "ingredients", "instructions"]
            // ]
            // let jsonSchema = JSONSchema(name: "recipe", strict: true, schema: schema)
            // let responseFormat = ResponseFormat(type: .jsonSchema, jsonSchema: jsonSchema)
            
            let messages = [
                ChatMessage(
                    role: .system,
                    content: """
                    You are a helpful recipe parser. Extract recipe information from the provided text and return it as a JSON object with this EXACT structure:
                    {
                        "name": "Recipe Name",
                        "servings": 4,
                        "prepTime": 15,
                        "cookTime": 30,
                        "difficulty": "easy|medium|hard",
                        "ingredients": [
                            {"name": "ingredient", "amount": "2", "unit": "cups"}
                        ],
                        "instructions": ["Step 1", "Step 2"]
                    }
                    IMPORTANT: Return ONLY valid JSON. All fields are required.
                    """
                ),
                ChatMessage(
                    role: .user,
                    content: "Parse this recipe: \(inputText)"
                )
            ]
            
            let request = ChatCompletionRequest(
                messages: messages,
                model: "grok-3-mini-fast",
                responseFormat: responseFormat
            )
            
            let response = try await client.chat.completions(request)
            
            if let content = response.choices.first?.message.content,
               let data = content.data(using: .utf8) {
                let decoder = JSONDecoder()
                parsedRecipe = try decoder.decode(Recipe.self, from: data)
            }
        } catch {
            errorMessage = "Failed to parse recipe: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}