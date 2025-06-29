import Foundation

// Define the structure for our recipe data
struct Recipe: Codable, Identifiable {
    let id = UUID()
    let name: String
    let servings: Int
    let prepTime: Int // in minutes
    let cookTime: Int // in minutes
    let ingredients: [Ingredient]
    let instructions: [String]
    let difficulty: Difficulty
    
    enum Difficulty: String, Codable, CaseIterable {
        case easy = "easy"
        case medium = "medium"
        case hard = "hard"
    }
}

struct Ingredient: Codable, Identifiable {
    let id = UUID()
    let name: String
    let amount: String
    let unit: String?
}