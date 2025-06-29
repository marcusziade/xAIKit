import SwiftUI
import xAIKit

// MARK: - Mode Switcher View
// Demonstrates switching between json_object (xAI) and json_schema (OpenAI) modes

struct StructuredOutputDemoView: View {
    @StateObject private var viewModel = UniversalRecipeParserViewModel()
    @State private var selectedMode = OutputMode.jsonObject
    
    enum OutputMode: String, CaseIterable {
        case jsonObject = "JSON Object (xAI)"
        case jsonSchema = "JSON Schema (OpenAI)"
        
        var description: String {
            switch self {
            case .jsonObject:
                return "Uses prompting to enforce structure. Works with xAI models."
            case .jsonSchema:
                return "Uses strict schema validation. More robust but requires OpenAI."
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Mode selector
                VStack(alignment: .leading, spacing: 8) {
                    Text("Output Mode")
                        .font(.headline)
                    
                    Picker("Mode", selection: $selectedMode) {
                        ForEach(OutputMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    Text(selectedMode.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Input section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Recipe Text")
                        .font(.headline)
                    
                    TextEditor(text: $viewModel.inputText)
                        .frame(minHeight: 150)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .padding(4)
                }
                
                // Parse button
                Button(action: {
                    Task {
                        await viewModel.parseRecipe(mode: selectedMode)
                    }
                }) {
                    HStack {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .scaleEffect(0.8)
                        }
                        Text(viewModel.isLoading ? "Parsing..." : "Parse Recipe")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedMode == .jsonObject ? Color.blue : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(viewModel.inputText.isEmpty || viewModel.isLoading)
                
                // Status indicator
                if let status = viewModel.parsingStatus {
                    HStack {
                        Image(systemName: status.icon)
                            .foregroundColor(status.color)
                        Text(status.message)
                            .font(.caption)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(status.color.opacity(0.1))
                    .cornerRadius(8)
                }
                
                // Error message
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal)
                }
                
                // Results
                if let recipe = viewModel.parsedRecipe {
                    RecipeResultCard(recipe: recipe, mode: selectedMode)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Structured Output Demo")
        }
    }
}

// MARK: - Universal ViewModel

@MainActor
class UniversalRecipeParserViewModel: ObservableObject {
    @Published var inputText = ""
    @Published var parsedRecipe: Recipe?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var parsingStatus: ParsingStatus?
    
    struct ParsingStatus {
        let message: String
        let icon: String
        let color: Color
    }
    
    private var xAIClient: xAIClient?
    private var openAIClient: xAIClient?
    
    init() {
        // Initialize both clients if API keys are available
        if let xaiKey = ProcessInfo.processInfo.environment["XAI_API_KEY"] {
            self.xAIClient = xAIClient(apiKey: xaiKey)
        }
        
        if let openaiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] {
            self.openAIClient = xAIClient(
                apiKey: openaiKey,
                apiBaseURL: URL(string: "https://api.openai.com/v1")!
            )
        }
    }
    
    func parseRecipe(mode: StructuredOutputDemoView.OutputMode) async {
        guard !inputText.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        parsedRecipe = nil
        parsingStatus = nil
        
        do {
            switch mode {
            case .jsonObject:
                guard let client = xAIClient else {
                    throw ValidationError("XAI_API_KEY not set")
                }
                parsingStatus = ParsingStatus(
                    message: "Using json_object format with Grok",
                    icon: "sparkles",
                    color: .blue
                )
                parsedRecipe = try await parseWithJsonObject(client: client)
                
            case .jsonSchema:
                guard let client = openAIClient else {
                    throw ValidationError("OPENAI_API_KEY not set")
                }
                parsingStatus = ParsingStatus(
                    message: "Using json_schema validation with GPT",
                    icon: "checkmark.shield",
                    color: .green
                )
                parsedRecipe = try await parseWithJsonSchema(client: client)
            }
            
            parsingStatus = ParsingStatus(
                message: "Successfully parsed recipe!",
                icon: "checkmark.circle.fill",
                color: .green
            )
        } catch {
            errorMessage = error.localizedDescription
            parsingStatus = ParsingStatus(
                message: "Parsing failed",
                icon: "xmark.circle.fill",
                color: .red
            )
        }
        
        isLoading = false
    }
    
    private func parseWithJsonObject(client: xAIClient) async throws -> Recipe {
        // Implementation using json_object (xAI compatible)
        let responseFormat = ResponseFormat(type: .jsonObject, jsonSchema: nil)
        
        let messages = [
            ChatMessage(
                role: .system,
                content: """
                Extract recipe information and return as JSON:
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
            ChatMessage(role: .user, content: inputText)
        ]
        
        let request = ChatCompletionRequest(
            messages: messages,
            model: "grok-3-mini-fast",
            responseFormat: responseFormat
        )
        
        let response = try await client.chat.completions(request)
        
        guard let content = response.choices.first?.message.content,
              let data = content.data(using: .utf8) else {
            throw ValidationError("Invalid response")
        }
        
        return try JSONDecoder().decode(Recipe.self, from: data)
    }
    
    private func parseWithJsonSchema(client: xAIClient) async throws -> Recipe {
        // Implementation using json_schema (OpenAI compatible)
        let schema: [String: Any] = [
            "type": "object",
            "properties": [
                "name": ["type": "string"],
                "servings": ["type": "integer", "minimum": 1],
                "prepTime": ["type": "integer", "minimum": 0],
                "cookTime": ["type": "integer", "minimum": 0],
                "difficulty": ["type": "string", "enum": ["easy", "medium", "hard"]],
                "ingredients": [
                    "type": "array",
                    "items": [
                        "type": "object",
                        "properties": [
                            "name": ["type": "string"],
                            "amount": ["type": "string"],
                            "unit": ["type": "string"]
                        ],
                        "required": ["name", "amount"]
                    ]
                ],
                "instructions": ["type": "array", "items": ["type": "string"]]
            ],
            "required": ["name", "servings", "prepTime", "cookTime", "difficulty", "ingredients", "instructions"]
        ]
        
        let jsonSchema = JSONSchema(name: "recipe", strict: true, schema: schema)
        let responseFormat = ResponseFormat(type: .jsonSchema, jsonSchema: jsonSchema)
        
        let messages = [
            ChatMessage(role: .system, content: "Extract recipe information."),
            ChatMessage(role: .user, content: inputText)
        ]
        
        let request = ChatCompletionRequest(
            messages: messages,
            model: "gpt-4o-mini",
            responseFormat: responseFormat
        )
        
        let response = try await client.chat.completions(request)
        
        guard let content = response.choices.first?.message.content,
              let data = content.data(using: .utf8) else {
            throw ValidationError("Invalid response")
        }
        
        return try JSONDecoder().decode(Recipe.self, from: data)
    }
}

// MARK: - Recipe Result Card

struct RecipeResultCard: View {
    let recipe: Recipe
    let mode: StructuredOutputDemoView.OutputMode
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Parsed Recipe")
                    .font(.headline)
                Spacer()
                Label(mode == .jsonObject ? "Prompt-based" : "Schema-validated", 
                      systemImage: mode == .jsonObject ? "text.bubble" : "checkmark.shield")
                    .font(.caption)
                    .foregroundColor(mode == .jsonObject ? .blue : .green)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                Text(recipe.name)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                HStack(spacing: 20) {
                    Label("\(recipe.servings) servings", systemImage: "person.2")
                    Label("\(recipe.prepTime + recipe.cookTime)m total", systemImage: "clock")
                    Text(recipe.difficulty.rawValue.capitalized)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(difficultyColor(recipe.difficulty))
                        .foregroundColor(.white)
                        .cornerRadius(4)
                        .font(.caption)
                }
                .font(.caption)
                
                Text("\(recipe.ingredients.count) ingredients • \(recipe.instructions.count) steps")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
    
    func difficultyColor(_ difficulty: Recipe.Difficulty) -> Color {
        switch difficulty {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        }
    }
}

enum ValidationError: LocalizedError {
    case missingAPIKey(String)
    
    var errorDescription: String? {
        switch self {
        case .missingAPIKey(let key):
            return "\(key) environment variable not set"
        }
    }
}