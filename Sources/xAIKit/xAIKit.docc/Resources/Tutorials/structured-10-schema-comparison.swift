import Foundation
import xAIKit

// MARK: - Structured Output Comparison

/// Example showing different structured output approaches

// 1. Using json_object with xAI (guaranteed JSON, no schema validation)
func parseWithJsonObject(client: xAIClient, text: String) async throws -> Recipe {
    let responseFormat = ResponseFormat(type: .jsonObject, jsonSchema: nil)
    
    let messages = [
        ChatMessage(
            role: .system,
            content: """
            Extract recipe information and return JSON with this EXACT structure:
            {
                "name": "string",
                "servings": number,
                "prepTime": number,
                "cookTime": number,
                "difficulty": "easy|medium|hard",
                "ingredients": [{"name": "string", "amount": "string", "unit": "string"}],
                "instructions": ["string"]
            }
            """
        ),
        ChatMessage(role: .user, content: text)
    ]
    
    let request = ChatCompletionRequest(
        messages: messages,
        model: "grok-3-mini-fast",
        responseFormat: responseFormat
    )
    
    let response = try await client.chat.completions(request)
    
    guard let content = response.choices.first?.message.content,
          let data = content.data(using: .utf8) else {
        throw ParsingError.invalidResponse
    }
    
    return try JSONDecoder().decode(Recipe.self, from: data)
}

// 2. Using json_schema with OpenAI (strict schema validation)
func parseWithJsonSchema(client: xAIClient, text: String) async throws -> Recipe {
    // Define the JSON schema
    let schema: [String: Any] = [
        "type": "object",
        "properties": [
            "name": [
                "type": "string",
                "description": "The name of the recipe"
            ],
            "servings": [
                "type": "integer",
                "minimum": 1,
                "description": "Number of servings"
            ],
            "prepTime": [
                "type": "integer",
                "minimum": 0,
                "description": "Preparation time in minutes"
            ],
            "cookTime": [
                "type": "integer",
                "minimum": 0,
                "description": "Cooking time in minutes"
            ],
            "difficulty": [
                "type": "string",
                "enum": ["easy", "medium", "hard"],
                "description": "Recipe difficulty level"
            ],
            "ingredients": [
                "type": "array",
                "items": [
                    "type": "object",
                    "properties": [
                        "name": ["type": "string"],
                        "amount": ["type": "string"],
                        "unit": ["type": "string", "nullable": true]
                    ],
                    "required": ["name", "amount"],
                    "additionalProperties": false
                ],
                "minItems": 1
            ],
            "instructions": [
                "type": "array",
                "items": ["type": "string"],
                "minItems": 1
            ]
        ],
        "required": ["name", "servings", "prepTime", "cookTime", "difficulty", "ingredients", "instructions"],
        "additionalProperties": false
    ]
    
    let jsonSchema = JSONSchema(
        name: "recipe_schema",
        strict: true,
        schema: schema
    )
    
    let responseFormat = ResponseFormat(
        type: .jsonSchema,
        jsonSchema: jsonSchema
    )
    
    let messages = [
        ChatMessage(
            role: .system,
            content: "You are a helpful recipe parser. Extract recipe information from the provided text."
        ),
        ChatMessage(role: .user, content: text)
    ]
    
    let request = ChatCompletionRequest(
        messages: messages,
        model: "gpt-4o-mini", // OpenAI model that supports json_schema
        responseFormat: responseFormat
    )
    
    let response = try await client.chat.completions(request)
    
    guard let content = response.choices.first?.message.content,
          let data = content.data(using: .utf8) else {
        throw ParsingError.invalidResponse
    }
    
    return try JSONDecoder().decode(Recipe.self, from: data)
}

// 3. Future: xAI Beta Parse API (not yet implemented in Swift SDK)
// This is how xAI's Python SDK works with Pydantic models:
/*
 # Python example:
 from pydantic import BaseModel
 
 class Recipe(BaseModel):
     name: str
     servings: int
     # ... other fields
 
 completion = client.beta.chat.completions.parse(
     model="grok-3",
     messages=[...],
     response_format=Recipe,
 )
 
 recipe = completion.choices[0].message.parsed
 */

enum ParsingError: Error {
    case invalidResponse
}

// MARK: - Key Differences

/*
 1. json_object (xAI compatible):
    - Guarantees JSON output
    - No schema validation
    - Relies on detailed prompting
    - Works with all xAI models
 
 2. json_schema (OpenAI compatible):
    - Strict schema validation
    - Type checking and constraints
    - Less reliance on prompting
    - Not supported by xAI API
 
 3. Beta Parse API (xAI Python SDK):
    - Type-safe parsing
    - Pydantic model support
    - Automatic validation
    - Not yet in Swift SDK
 */