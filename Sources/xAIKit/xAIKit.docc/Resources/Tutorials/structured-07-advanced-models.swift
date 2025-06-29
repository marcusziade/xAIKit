import Foundation

// Enhanced recipe model with nutritional information
struct AdvancedRecipe: Codable, Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let servings: Int
    let prepTime: Int
    let cookTime: Int
    let ingredients: [DetailedIngredient]
    let instructions: [Instruction]
    let difficulty: Difficulty
    let cuisine: String
    let mealType: [String] // breakfast, lunch, dinner, snack
    let dietaryInfo: DietaryInfo
    let nutrition: NutritionInfo
    
    enum Difficulty: String, Codable, CaseIterable {
        case easy, medium, hard
    }
}

struct DetailedIngredient: Codable, Identifiable {
    let id = UUID()
    let name: String
    let amount: Double
    let unit: String
    let preparation: String? // "diced", "minced", etc.
    let category: String // "protein", "vegetable", "dairy", etc.
}

struct Instruction: Codable, Identifiable {
    let id = UUID()
    let step: Int
    let description: String
    let duration: Int? // in minutes
    let temperature: Temperature?
}

struct Temperature: Codable {
    let value: Int
    let unit: String // "F" or "C"
}

struct DietaryInfo: Codable {
    let vegetarian: Bool
    let vegan: Bool
    let glutenFree: Bool
    let dairyFree: Bool
    let nutFree: Bool
}

struct NutritionInfo: Codable {
    let calories: Int
    let protein: Double // in grams
    let carbohydrates: Double
    let fat: Double
    let fiber: Double
    let sugar: Double
    let sodium: Double // in mg
}