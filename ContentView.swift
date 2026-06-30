import SwiftUI

// MARK: - Color Palette Configuration
extension Color {
    static let brandBg = Color(red: 250/255, green: 248/255, blue: 245/255)     // #faf8f5 Warm Stone Background
    static let brandCard = Color.white                                          // White Cards
    static let brandText = Color(red: 43/255, green: 32/255, blue: 11/255)       // #432e0b Deep Espresso Text
    static let brandSecondary = Color(red: 120/255, green: 110/255, blue: 95/255) // Neutral Stone Subtitles
    static let brandGold = Color(red: 226/255, green: 179/255, blue: 60/255)     // #e2b33c Accent Gold
    static let brandGoldLight = Color(red: 253/255, green: 251/255, blue: 235/255) // #fdfbeb Tinted Badge
    static let brandBorder = Color(red: 230/255, green: 225/255, blue: 218/255)  // Soft warm border
}

// MARK: - Models
struct Recipe: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let ingredients: [String]
    let instructions: [String]
    let prepTime: Int
}

// MARK: - App Entry Point
@main
struct CookeryAIApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// MARK: - Main Interface
struct ContentView: View {
    @State private var recipes: [Recipe] = [
        Recipe(
            title: "Classic Avocado Toast",
            description: "A quick, creamy, and crispy breakfast favorite.",
            ingredients: ["1 slice of sourdough bread", "1/2 ripe avocado", "1 tsp chili flakes", "Salt & pepper to taste"],
            instructions: ["Toast the bread to your desired crispiness.", "Mash the avocado in a bowl with salt and pepper.", "Spread evenly over the toast and top with chili flakes."],
            prepTime: 5
        ),
        Recipe(
            title: "Quick Garlic Pasta",
            description: "A simple, comforting Italian dinner made in under 15 minutes.",
            ingredients: ["200g Spaghetti", "3 cloves garlic, sliced", "2 tbsp olive oil", "Fresh parsley"],
            instructions: ["Boil pasta in salted water according to package instructions.", "Sauté garlic in olive oil over low heat until golden.", "Toss pasta in the garlic oil and garnish with chopped parsley."],
            prepTime: 15
        )
    ]
    
    @State private var selectedRecipe: Recipe? = nil
    @State private var showingGenerator = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.brandBg.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {
                        HStack {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Cookery")
                                    .font(.system(.largeTitle, design: .serif))
                                    .fontWeight(.bold)
                                    .foregroundColor(.brandText)
                                Text("Your kitchen, thoughtfully guided.")
                                    .font(.system(.subheadline, design: .sans))
                                    .foregroundColor(.brandSecondary)
                            }
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top, 12)
                        
                        Button(action: { showingGenerator = true }) {
                            HStack(spacing: 8) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 14, weight: .semibold))
                                Text("Generate with AI")
                                    .font(.system(.headline, design: .sans))
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Color.brandText)
                            .cornerRadius(16)
                            .shadow(color: Color.brandText.opacity(0.1), radius: 8, x: 0, y: 4)
                        }
                        .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Your Recipes")
                                .font(.system(.title2, design: .serif))
                                .fontWeight(.medium)
                                .foregroundColor(.brandText)
                                .padding(.horizontal)
                            
                            ForEach(recipes) { recipe in
                                Button(action: { selectedRecipe = recipe }) {
                                    VStack(alignment: .leading, spacing: 10) {
                                        HStack(alignment: .firstTextBaseline) {
                                            Text(recipe.title)
                                                .font(.system(.headline, design: .serif))
                                                .foregroundColor(.brandText)
                                            Spacer()
                                            Text("\(recipe.prepTime) min")
                                                .font(.system(.caption, design: .sans))
                                                .fontWeight(.semibold)
                                                .foregroundColor(.brandGold)
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 4)
                                                .background(Color.brandGoldLight)
                                                .cornerRadius(20)
                                        }
                                        Text(recipe.description)
                                            .font(.system(.subheadline, design: .sans))
                                            .foregroundColor(.brandSecondary)
                                            .multilineTextAlignment(.leading)
                                            .lineSpacing(2)
                                    }
                                    .padding(20)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.brandCard)
                                    .cornerRadius(24)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 24)
                                            .stroke(Color.brandBorder, lineWidth: 1)
                                    )
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationBarHidden(true)
            .sheet(item: $selectedRecipe) { recipe in
                RecipeDetailView(recipe: recipe)
            }
            .sheet(isPresented: $showingGenerator) {
                AIGeneratorView(recipes: $recipes, isPresented: $showingGenerator)
            }
        }
    }
}

// MARK: - Detail View
struct RecipeDetailView: View {
    let recipe: Recipe
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.brandBg.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        HStack(spacing: 6) {
                            Image(systemName: "clock")
                                .font(.system(size: 14))
                                .foregroundColor(.brandGold)
                            Text("Ready in \(recipe.prepTime) minutes")
                                .font(.system(.subheadline, design: .sans))
                                .foregroundColor(.brandSecondary)
                        }
                        
                        Text(recipe.description)
                            .font(.system(.body, design: .sans))
                            .foregroundColor(.brandSecondary)
                            .lineSpacing(4)
                        
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Ingredients")
                                .font(.system(.headline, design: .serif))
                                .foregroundColor(.brandText)
                            
                            ForEach(recipe.ingredients, id: \.self) { ingredient in
                                HStack(alignment: .top, spacing: 10) {
                                    Text("•")
                                        .foregroundColor(.brandGold)
                                        .fontWeight(.bold)
                                    Text(ingredient)
                                        .font(.system(.subheadline, design: .sans))
                                        .foregroundColor(.brandText)
                                }
                            }
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.brandCard)
                        .cornerRadius(24)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.brandBorder, lineWidth: 1)
                        )
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Instructions")
                                .font(.system(.headline, design: .serif))
                                .foregroundColor(.brandText)
                            
                            ForEach(0..<recipe.instructions.count, id: \.self) { index in
                                HStack(alignment: .top, spacing: 12) {
                                    Text("\(index + 1)")
                                        .font(.system(.subheadline, design: .sans))
                                        .fontWeight(.bold)
                                        .foregroundColor(.brandGold)
                                        .frame(width: 22, height: 22)
                                        .background(Color.brandGoldLight)
                                        .clipShape(Circle())
                                    
                                    Text(recipe.instructions[index])
                                        .font(.system(.subheadline, design: .sans))
                                        .foregroundColor(.brandText)
                                        .lineSpacing(3)
                                }
                                .padding(.vertical, 2)
                            }
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.brandCard)
                        .cornerRadius(24)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.brandBorder, lineWidth: 1)
                        )
                    }
                    .padding()
                }
            }
            .navigationTitle(recipe.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(.system(.body, design: .sans))
                        .foregroundColor(.brandText)
                }
            }
        }
    }
}

// MARK: - AI Generator View
struct AIGeneratorView: View {
    @Binding var recipes: [Recipe]
    @Binding var isPresented: Bool
    @State private var ingredients = ""
    
    init(recipes: Binding<[Recipe]>, isPresented: Binding<Bool>) {
        self._recipes = recipes
        self._isPresented = isPresented
        UITableView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.brandBg.ignoresSafeArea()
                
                Form {
                    Section(header: Text("What's in your fridge?").font(.system(.caption, design: .sans)).foregroundColor(.brandSecondary)) {
                        TextField("Ingredients (e.g., eggs, tomato)", text: $ingredients)
                            .font(.system(.body, design: .sans))
                    }
                    .listRowBackground(Color.brandCard)
                    
                    Section {
                        Button(action: {
                            let newRecipe = Recipe(
                                title: "AI Generated Meal",
                                description: "A custom creation using your ingredients.",
                                ingredients: ingredients.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) },
                                instructions: ["Combine the ingredients.", "Cook thoroughly.", "Serve hot."],
                                prepTime: 10
                            )
                            recipes.append(newRecipe)
                            isPresented = false
                        }) {
                            Text("Generate Recipe")
                                .font(.system(.headline, design: .sans))
                                .frame(maxWidth: .infinity, alignment: .center)
                                .foregroundColor(ingredients.isEmpty ? .secondary : .white)
                        }
                        .disabled(ingredients.isEmpty)
                        .listRowBackground(ingredients.isEmpty ? Color(.systemGray4) : Color.brandText)
                    }
                }
            }
            .navigationTitle("AI Recipe Creator")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { isPresented = false }
                        .font(.system(.body, design: .sans))
                        .foregroundColor(.brandSecondary)
                }
            }
        }
    }
}