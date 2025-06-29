import SwiftUI

struct AdvancedRecipeView: View {
    let recipe: AdvancedRecipe
    @State private var selectedTab = 0
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Recipe header
                RecipeHeaderView(recipe: recipe)
                
                // Tab selector
                Picker("View", selection: $selectedTab) {
                    Text("Ingredients").tag(0)
                    Text("Instructions").tag(1)
                    Text("Nutrition").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // Tab content
                switch selectedTab {
                case 0:
                    IngredientsView(ingredients: recipe.ingredients)
                case 1:
                    InstructionsView(instructions: recipe.instructions)
                case 2:
                    NutritionView(nutrition: recipe.nutrition, dietary: recipe.dietaryInfo)
                default:
                    EmptyView()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct RecipeHeaderView: View {
    let recipe: AdvancedRecipe
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(recipe.name)
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text(recipe.description)
                .font(.body)
                .foregroundColor(.secondary)
            
            // Recipe metadata
            HStack(spacing: 15) {
                MetadataBadge(icon: "person.2", text: "\(recipe.servings)")
                MetadataBadge(icon: "clock", text: "\(recipe.prepTime + recipe.cookTime)m")
                MetadataBadge(icon: "flag", text: recipe.cuisine)
                DifficultyBadge(difficulty: recipe.difficulty)
            }
            
            // Meal type tags
            HStack {
                ForEach(recipe.mealType, id: \.self) { meal in
                    Text(meal.capitalized)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.2))
                        .foregroundColor(.blue)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
    }
}

struct MetadataBadge: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
            Text(text)
                .font(.caption)
        }
        .foregroundColor(.secondary)
    }
}

struct DifficultyBadge: View {
    let difficulty: AdvancedRecipe.Difficulty
    
    var difficultyColor: Color {
        switch difficulty {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        }
    }
    
    var body: some View {
        Text(difficulty.rawValue.capitalized)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(difficultyColor)
            .foregroundColor(.white)
            .cornerRadius(8)
    }
}

struct IngredientsView: View {
    let ingredients: [DetailedIngredient]
    
    var groupedIngredients: [String: [DetailedIngredient]] {
        Dictionary(grouping: ingredients, by: { $0.category })
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(groupedIngredients.keys.sorted(), id: \.self) { category in
                VStack(alignment: .leading, spacing: 10) {
                    Text(category.capitalized)
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(groupedIngredients[category] ?? []) { ingredient in
                        HStack {
                            Text("•")
                                .foregroundColor(.gray)
                            Text("\(String(format: "%.1f", ingredient.amount)) \(ingredient.unit)")
                                .fontWeight(.medium)
                            Text(ingredient.name)
                            if let prep = ingredient.preparation {
                                Text("(\(prep))")
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
    }
}

struct InstructionsView: View {
    let instructions: [Instruction]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(instructions) { instruction in
                HStack(alignment: .top, spacing: 15) {
                    // Step number circle
                    ZStack {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 30, height: 30)
                        Text("\(instruction.step)")
                            .foregroundColor(.white)
                            .fontWeight(.semibold)
                    }
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text(instruction.description)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        HStack(spacing: 15) {
                            if let duration = instruction.duration {
                                Label("\(duration) min", systemImage: "timer")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            if let temp = instruction.temperature {
                                Label("\(temp.value)°\(temp.unit)", systemImage: "thermometer")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct NutritionView: View {
    let nutrition: NutritionInfo
    let dietary: DietaryInfo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Dietary badges
            VStack(alignment: .leading, spacing: 10) {
                Text("Dietary Information")
                    .font(.headline)
                
                HStack {
                    DietaryBadge(label: "Vegetarian", isActive: dietary.vegetarian)
                    DietaryBadge(label: "Vegan", isActive: dietary.vegan)
                    DietaryBadge(label: "Gluten-Free", isActive: dietary.glutenFree)
                }
                HStack {
                    DietaryBadge(label: "Dairy-Free", isActive: dietary.dairyFree)
                    DietaryBadge(label: "Nut-Free", isActive: dietary.nutFree)
                }
            }
            .padding(.horizontal)
            
            Divider()
            
            // Nutrition facts
            VStack(alignment: .leading, spacing: 15) {
                Text("Nutrition Facts")
                    .font(.headline)
                
                Text("Per Serving")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                NutritionRow(label: "Calories", value: "\(nutrition.calories)")
                NutritionRow(label: "Protein", value: "\(String(format: "%.1f", nutrition.protein))g")
                NutritionRow(label: "Carbohydrates", value: "\(String(format: "%.1f", nutrition.carbohydrates))g")
                NutritionRow(label: "Fat", value: "\(String(format: "%.1f", nutrition.fat))g")
                NutritionRow(label: "Fiber", value: "\(String(format: "%.1f", nutrition.fiber))g")
                NutritionRow(label: "Sugar", value: "\(String(format: "%.1f", nutrition.sugar))g")
                NutritionRow(label: "Sodium", value: "\(String(format: "%.0f", nutrition.sodium))mg")
            }
            .padding(.horizontal)
        }
    }
}

struct DietaryBadge: View {
    let label: String
    let isActive: Bool
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: isActive ? "checkmark.circle.fill" : "xmark.circle")
                .foregroundColor(isActive ? .green : .gray)
            Text(label)
                .font(.caption)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

struct NutritionRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}