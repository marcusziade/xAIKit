import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Recipe header
                VStack(alignment: .leading, spacing: 10) {
                    Text(recipe.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    HStack(spacing: 20) {
                        Label("\(recipe.servings) servings", systemImage: "person.2")
                        Label("\(recipe.prepTime) min prep", systemImage: "clock")
                        Label("\(recipe.cookTime) min cook", systemImage: "flame")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    
                    // Difficulty badge
                    Text(recipe.difficulty.rawValue.capitalized)
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(difficultyColor(recipe.difficulty))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                
                Divider()
                
                // Ingredients section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Ingredients")
                        .font(.headline)
                    
                    ForEach(recipe.ingredients) { ingredient in
                        HStack {
                            Image(systemName: "circle.fill")
                                .font(.system(size: 6))
                                .foregroundColor(.gray)
                            Text("\(ingredient.amount) \(ingredient.unit ?? "") \(ingredient.name)")
                                .font(.body)
                        }
                    }
                }
                
                Divider()
                
                // Instructions section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Instructions")
                        .font(.headline)
                    
                    ForEach(Array(recipe.instructions.enumerated()), id: \.offset) { index, instruction in
                        HStack(alignment: .top, spacing: 10) {
                            Text("\(index + 1).")
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                            Text(instruction)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func difficultyColor(_ difficulty: Recipe.Difficulty) -> Color {
        switch difficulty {
        case .easy:
            return .green
        case .medium:
            return .orange
        case .hard:
            return .red
        }
    }
}