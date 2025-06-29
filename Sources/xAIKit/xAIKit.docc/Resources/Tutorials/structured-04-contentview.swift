import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = RecipeParserViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Input section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Enter Recipe Text")
                        .font(.headline)
                    
                    TextEditor(text: $viewModel.inputText)
                        .frame(minHeight: 200)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .padding(4)
                }
                
                // Parse button
                Button(action: {
                    Task {
                        await viewModel.parseRecipe()
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
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(viewModel.inputText.isEmpty || viewModel.isLoading)
                
                // Error message
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                // Results section
                if let recipe = viewModel.parsedRecipe {
                    NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(recipe.name)
                                    .font(.headline)
                                Text("\(recipe.servings) servings • \(recipe.prepTime + recipe.cookTime) min total")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Recipe Parser")
        }
    }
}