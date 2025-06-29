import Foundation
import xAIKit

// MARK: - JSON Schema Structured Output Example (OpenAI-compatible)

@MainActor
class SchemaBasedRecipeParserViewModel: ObservableObject {
    @Published var inputText = ""
    @Published var parsedRecipe: Recipe?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let client: xAIClient
    
    init() {
        // Initialize with OpenAI API key for json_schema support
        self.client = xAIClient(
            apiKey: ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? "",
            apiBaseURL: URL(string: "https://api.openai.com/v1")!
        )
    }
    
    func parseRecipeWithSchema() async {
        guard !inputText.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        parsedRecipe = nil
        
        do {
            // Define a comprehensive JSON schema for recipe validation
            let schema = createRecipeSchema()
            
            // Create JSONSchema object with strict validation
            let jsonSchema = JSONSchema(
                name: "recipe_schema",
                strict: true,
                schema: schema
            )
            
            // Use json_schema response format for strict validation
            let responseFormat = ResponseFormat(
                type: .jsonSchema,
                jsonSchema: jsonSchema
            )
            
            // Simple system prompt - the schema handles the structure
            let messages = [
                ChatMessage(
                    role: .system,
                    content: "Extract recipe information from the provided text."
                ),
                ChatMessage(
                    role: .user,
                    content: inputText
                )
            ]
            
            let request = ChatCompletionRequest(
                messages: messages,
                model: "gpt-4o-mini",
                responseFormat: responseFormat,
                temperature: 0.3 // Lower temperature for consistent structured output
            )
            
            let response = try await client.chat.completions(request)
            
            // The response is guaranteed to match our schema
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
    
    private func createRecipeSchema() -> [String: Any] {
        return [
            "type": "object",
            "title": "Recipe",
            "description": "A structured recipe with ingredients and instructions",
            "properties": [
                "name": [
                    "type": "string",
                    "description": "The name of the recipe",
                    "minLength": 1,
                    "maxLength": 100
                ],
                "servings": [
                    "type": "integer",
                    "description": "Number of servings",
                    "minimum": 1,
                    "maximum": 100
                ],
                "prepTime": [
                    "type": "integer",
                    "description": "Preparation time in minutes",
                    "minimum": 0,
                    "maximum": 1440 // 24 hours max
                ],
                "cookTime": [
                    "type": "integer",
                    "description": "Cooking time in minutes",
                    "minimum": 0,
                    "maximum": 1440
                ],
                "difficulty": [
                    "type": "string",
                    "description": "Recipe difficulty level",
                    "enum": ["easy", "medium", "hard"]
                ],
                "ingredients": [
                    "type": "array",
                    "description": "List of ingredients",
                    "items": [
                        "type": "object",
                        "properties": [
                            "name": [
                                "type": "string",
                                "description": "Ingredient name",
                                "minLength": 1
                            ],
                            "amount": [
                                "type": "string",
                                "description": "Amount of ingredient",
                                "minLength": 1
                            ],
                            "unit": [
                                "type": "string",
                                "description": "Unit of measurement",
                                "nullable": true
                            ]
                        ],
                        "required": ["name", "amount"],
                        "additionalProperties": false
                    ],
                    "minItems": 1,
                    "maxItems": 50
                ],
                "instructions": [
                    "type": "array",
                    "description": "Step-by-step cooking instructions",
                    "items": [
                        "type": "string",
                        "minLength": 1,
                        "maxLength": 500
                    ],
                    "minItems": 1,
                    "maxItems": 30
                ]
            ],
            "required": ["name", "servings", "prepTime", "cookTime", "difficulty", "ingredients", "instructions"],
            "additionalProperties": false
        ]
    }
}

// MARK: - Benefits of JSON Schema

/*
 JSON Schema provides several advantages:
 
 1. **Type Safety**: Ensures all fields have correct types
 2. **Validation**: Enforces constraints like min/max values, string lengths
 3. **Required Fields**: Guarantees all necessary fields are present
 4. **No Additional Properties**: Prevents unexpected fields
 5. **Enums**: Restricts values to specific options (e.g., difficulty levels)
 6. **Arrays**: Validates array items and enforces min/max counts
 7. **Documentation**: Schema serves as API documentation
 
 The AI model MUST return data that exactly matches this schema,
 eliminating the need for extensive error handling or validation.
 */