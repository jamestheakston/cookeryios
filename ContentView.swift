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

enum CreationMode {
    case ai, ingredients, manual
}

// MARK: - Native Supabase REST Client
class SupabaseAuth: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var errorMessage: String? = nil
    @Published var isLoading: Bool = false
    
    private let projectUrl = "https://ojvigxnwweixjhugekmm.supabase.co"
    private let apiKey = "sb_publishable_ok_vkZ1FDJ_hv-qdv76tJw_RJ78nd6W"
    
    func signUp(email: String, password: String) {
        performAuthAction(endpoint: "/auth/v1/signup", email: email, password: password)
    }
    
    func signIn(email: String, password: String) {
        performAuthAction(endpoint: "/auth/v1/token?grant_type=password", email: email, password: password)
    }
    
    private func performAuthAction(endpoint: String, email: String, password: String) {
        guard let url = URL(string: projectUrl + endpoint) else { return }
        
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["email": email, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    if (200...299).contains(httpResponse.statusCode) {
                        self.isAuthenticated = true
                    } else {
                        if let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                           let msg = json["error_description"] as? String ?? json["msg"] as? String {
                            self.errorMessage = msg
                        } else {
                            self.errorMessage = "Authentication failed (Status code: \(httpResponse.statusCode))"
                        }
                    }
                }
            }
        }.resume()
    }
    
    func signOut() {
        self.isAuthenticated = false
    }
}

// MARK: - App Entry Point
@main
struct CookeryAIApp: App {
    @StateObject private var auth = SupabaseAuth()
    
    var body: some Scene {
        WindowGroup {
            if auth.isAuthenticated {
                ContentView()
                    .environmentObject(auth)
            } else {
                LoginScreen()
                    .environmentObject(auth)
            }
        }
    }
}

// MARK: - Login / Signup Screen
struct LoginScreen: View {
    @EnvironmentObject var auth: SupabaseAuth
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUpMode = false
    
    var body: some View {
        ZStack {
            Color.brandBg.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 14) {
                        VStack(alignment: .leading, spacing: 16) {
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(Color.brandGold)
                                .frame(width: 64, height: 64)
                                .shadow(color: Color.brandText.opacity(0.1), radius: 6, x: 0, y: 3)
                                .overlay {
                                    Image(systemName: "fork.knife")
                                        .font(.system(size: 26, weight: .medium))
                                        .foregroundColor(.white)
                                }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Cookery")
                                    .font(.system(.largeTitle, design: .serif))
                                    .fontWeight(.bold)
                                    .foregroundColor(.brandText)
                                Text("Welcome to the future of recipes.")
                                    .font(.subheadline)
                                    .foregroundColor(.brandSecondary)
                            }
                        }
                        .padding(24)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .background(Color.brandCard)
                    .mask { RoundedRectangle(cornerRadius: 28, style: .continuous) }
                    .overlay(RoundedRectangle(cornerRadius: 28, style: .continuous).stroke(Color.brandBorder, lineWidth: 1))
                    .padding(.horizontal)
                    .padding(.top, 20)
                    .shadow(color: Color.brandText.opacity(0.04), radius: 12, x: 0, y: 6)
                    
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Email Address")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.brandSecondary)
                            TextField("name@example.com", text: $email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .padding()
                                .background(Color.brandBg)
                                .cornerRadius(12)
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Password")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.brandSecondary)
                            SecureField("••••••••", text: $password)
                                .padding()
                                .background(Color.brandBg)
                                .cornerRadius(12)
                        }
                    }
                    .padding(20)
                    .background(Color.brandCard)
                    .cornerRadius(24)
                    .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.brandBorder, lineWidth: 1))
                    .padding(.horizontal)
                    
                    if let error = auth.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    VStack(spacing: 12) {
                        Button(action: {
                            if isSignUpMode {
                                auth.signUp(email: email, password: password)
                            } else {
                                auth.signIn(email: email, password: password)
                            }
                        }) {
                            HStack {
                                if auth.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text(isSignUpMode ? "Create Account" : "Sign In")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(email.isEmpty || password.isEmpty ? Color.brandSecondary.opacity(0.5) : Color.brandText)
                            .cornerRadius(16)
                        }
                        .disabled(email.isEmpty || password.isEmpty || auth.isLoading)
                        
                        Button(action: { isSignUpMode.toggle() }) {
                            Text(isSignUpMode ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(Color.brandGold)
                                .padding(.vertical, 8)
                        }
                        
                        Button(action: { auth.isAuthenticated = true }) {
                            Text("Try without an account")
                                .font(.caption)
                                .foregroundColor(.brandSecondary)
                                .padding(.top, 8)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

// MARK: - Main Interface
struct ContentView: View {
    @EnvironmentObject var auth: SupabaseAuth
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
                                    .font(.subheadline)
                                    .foregroundColor(.brandSecondary)
                            }
                            Spacer()
                            
                            Button(action: { auth.signOut() }) {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .foregroundColor(.brandSecondary)
                                    .font(.system(size: 18))
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 12)
                        
                        Button(action: { showingGenerator = true }) {
                            HStack(spacing: 8) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 14, weight: .semibold))
                                Text("Recipe Lab")
                                    .font(.headline)
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
                                                .font(.caption)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.brandGold)
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 4)
                                                .background(Color.brandGoldLight)
                                                .cornerRadius(20)
                                        }
                                        Text(recipe.description)
                                            .font(.subheadline)
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
                                .font(.subheadline)
                                .foregroundColor(.brandSecondary)
                        }
                        
                        Text(recipe.description)
                            .font(.body)
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
                                        .font(.subheadline)
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
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.brandGold)
                                        .frame(width: 22, height: 22)
                                        .background(Color.brandGoldLight)
                                        .clipShape(Circle())
                                    
                                    Text(recipe.instructions[index])
                                        .font(.subheadline)
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
                        .font(.body)
                        .foregroundColor(.brandText)
                }
            }
        }
    }
}

// MARK: - AI Generator / Recipe Lab View
struct AIGeneratorView: View {
    @Binding var recipes: [Recipe]
    @Binding var isPresented: Bool
    
    @State private var selectedMode: CreationMode = .ai
    
    // Mode 1: AI Prompt variables
    @State private var cravingInput = ""
    @State private var selectedDiet = ""
    @State private var selectedStyle = ""
    
    // Mode 2: Ingredient isolation variables
    @State private var ingredientFields: [String] = [""]
    
    // Mode 3: Manual input variables
    @State private var manualTitle = ""
    @State private var manualDescription = ""
    @State private var manualPrepTime = ""
    @State private var manualIngredients: [String] = [""]
    @State private var manualInstructions: [String] = [""]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.brandBg.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // 3-Way Mode Toggle Segment Group
                        HStack(spacing: 4) {
                            Button(action: { selectedMode = .ai }) {
                                Text("AI Prompt")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 38)
                                    .background(selectedMode == .ai ? Color.brandGoldLight : Color.clear)
                                    .foregroundColor(selectedMode == .ai ? Color.brandText : Color.brandSecondary)
                                    .cornerRadius(10)
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(selectedMode == .ai ? Color.brandGold.opacity(0.3) : Color.clear, lineWidth: 1))
                            }
                            
                            Button(action: { selectedMode = .ingredients }) {
                                Text("Ingredients")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 38)
                                    .background(selectedMode == .ingredients ? Color.brandGoldLight : Color.clear)
                                    .foregroundColor(selectedMode == .ingredients ? Color.brandText : Color.brandSecondary)
                                    .cornerRadius(10)
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(selectedMode == .ingredients ? Color.brandGold.opacity(0.3) : Color.clear, lineWidth: 1))
                            }
                            
                            Button(action: { selectedMode = .manual }) {
                                Text("Manual")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 38)
                                    .background(selectedMode == .manual ? Color.brandGoldLight : Color.clear)
                                    .foregroundColor(selectedMode == .manual ? Color.brandText : Color.brandSecondary)
                                    .cornerRadius(10)
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(selectedMode == .manual ? Color.brandGold.opacity(0.3) : Color.clear, lineWidth: 1))
                            }
                        }
                        .padding(4)
                        .background(Color.brandCard)
                        .cornerRadius(14)
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.brandBorder, lineWidth: 1))
                        .padding(.horizontal)
                        
                        // Forms Switcher Logic
                        if selectedMode == .ai {
                            aiPromptForm
                        } else if selectedMode == .ingredients {
                            ingredientsIsolationForm
                        } else {
                            manualForm
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Recipe Lab")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { isPresented = false }
                        .font(.body)
                        .foregroundColor(.brandSecondary)
                }
            }
        }
    }
    
    // MARK: - Sub Form layouts
    private var aiPromptForm: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("What are you craving?")
                    .font(.caption).fontWeight(.bold).foregroundColor(.brandSecondary)
                TextField("e.g. A comforting warm pasta for a rainy day", text: $cravingInput)
                    .padding()
                    .background(Color.brandCard)
                    .cornerRadius(14)
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.brandBorder, lineWidth: 1))
            }
            .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Dietary Requirements")
                    .font(.caption).fontWeight(.bold).foregroundColor(.brandSecondary)
                
                HStack(spacing: 8) {
                    ForEach(["None", "Vegan", "Vegetarian", "Dairy-Free"], id: \.self) { diet in
                        Button(action: { selectedDiet = diet }) {
                            Text(diet)
                                .font(.caption)
                                .fontWeight(.medium)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(selectedDiet == diet ? Color.brandText : Color.brandCard)
                                .foregroundColor(selectedDiet == diet ? .white : Color.brandText)
                                .cornerRadius(10)
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.brandBorder, lineWidth: selectedDiet == diet ? 0 : 1))
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Cooking Method & Style")
                    .font(.caption).fontWeight(.bold).foregroundColor(.brandSecondary)
                
                HStack(spacing: 8) {
                    ForEach(["Quick & Easy", "Gourmet", "Baking", "Slow Cook"], id: \.self) { style in
                        Button(action: { selectedStyle = style }) {
                            Text(style)
                                .font(.caption)
                                .fontWeight(.medium)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(selectedStyle == style ? Color.brandText : Color.brandCard)
                                .foregroundColor(selectedStyle == style ? .white : Color.brandText)
                                .cornerRadius(10)
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.brandBorder, lineWidth: selectedStyle == style ? 0 : 1))
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            
            Button(action: {
                let generatedTitle = cravingInput.isEmpty ? "AI Prompt Meal" : cravingInput
                let newRecipe = Recipe(
                    title: generatedTitle,
                    description: "AI tailored discovery recipe structured around \(selectedStyle) guidelines.",
                    ingredients: ["Custom selected tailored components"],
                    instructions: ["Follow smart guidance steps tailored to \(selectedDiet) constraints."],
                    prepTime: 20
                )
                recipes.append(newRecipe)
                isPresented = false
            }) {
                Text("Generate AI Recipe Blueprint")
                    .font(.headline).foregroundColor(.white)
                    .frame(maxWidth: .infinity).frame(height: 52)
                    .background(cravingInput.isEmpty ? Color.brandSecondary.opacity(0.4) : Color.brandText)
                    .cornerRadius(16)
            }
            .disabled(cravingInput.isEmpty)
            .padding(.horizontal)
            .padding(.top, 10)
        }
    }
    
    private var ingredientsIsolationForm: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Isolate Available Ingredients")
                    .font(.caption).fontWeight(.bold).foregroundColor(.brandSecondary)
                
                ForEach(0..<ingredientFields.count, id: \.self) { index in
                    HStack {
                        TextField("e.g. 2 eggs or chicken breast", text: $ingredientFields[index])
                            .padding()
                            .background(Color.brandCard)
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.brandBorder, lineWidth: 1))
                        
                        if ingredientFields.count > 1 {
                            Button(action: { ingredientFields.remove(at: index) }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                                    .padding(.horizontal, 8)
                            }
                        }
                    }
                }
                
                Button(action: { ingredientFields.append("") }) {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add Ingredient Element")
                    }
                    .font(.caption).fontWeight(.semibold).foregroundColor(Color.brandGold)
                    .padding(.vertical, 4)
                }
            }
            .padding(.horizontal)
            
            Button(action: {
                let filteredIngredients = ingredientFields.filter { !$0.isEmpty }
                let newRecipe = Recipe(
                    title: "Ingredient Creation Match",
                    description: "A tailored compilation engineered purely using your isolated ingredients cabinet.",
                    ingredients: filteredIngredients.isEmpty ? ["Cabinet Items"] : filteredIngredients,
                    instructions: ["Prepare the structured ingredients list.", "Cook thoroughly according to temperature configurations."],
                    prepTime: 15
                )
                recipes.append(newRecipe)
                isPresented = false
            }) {
                Text("Synthesize Pure Recipe")
                    .font(.headline).foregroundColor(.white)
                    .frame(maxWidth: .infinity).frame(height: 52)
                    .background(Color.brandText)
                    .cornerRadius(16)
            }
            .padding(.horizontal)
        }
    }
    
    private var manualForm: some View {
        VStack(spacing: 20) {
            VStack(spacing: 14) {
                TextField("Recipe Title", text: $manualTitle)
                    .padding()
                    .background(Color.brandCard)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.brandBorder, lineWidth: 1))
                
                TextField("Short Description Summary", text: $manualDescription)
                    .padding()
                    .background(Color.brandCard)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.brandBorder, lineWidth: 1))
                
                TextField("Cooking Time (minutes)", text: $manualPrepTime)
                    .keyboardType(.numberPad)
                    .padding()
                    .background(Color.brandCard)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.brandBorder, lineWidth: 1))
            }
            .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Ingredients List")
                    .font(.caption).fontWeight(.bold).foregroundColor(.brandSecondary)
                
                ForEach(0..<manualIngredients.count, id: \.self) { index in
                    HStack {
                        TextField("Ingredient requirement", text: $manualIngredients[index])
                            .padding()
                            .background(Color.brandCard)
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.brandBorder, lineWidth: 1))
                        
                        if manualIngredients.count > 1 {
                            Button(action: { manualIngredients.remove(at: index) }) {
                                Image(systemName: "minus.circle")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                
                Button(action: { manualIngredients.append("") }) {
                    Text("+ Add Item row").font(.caption).foregroundColor(Color.brandGold)
                }
            }
            .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Directional Instructions")
                    .font(.caption).fontWeight(.bold).foregroundColor(.brandSecondary)
                
                ForEach(0..<manualInstructions.count, id: \.self) { index in
                    HStack {
                        TextField("Step instruction", text: $manualInstructions[index])
                            .padding()
                            .background(Color.brandCard)
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.brandBorder, lineWidth: 1))
                        
                        if manualInstructions.count > 1 {
                            Button(action: { manualInstructions.remove(at: index) }) {
                                Image(systemName: "minus.circle")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                
                Button(action: { manualInstructions.append("") }) {
                    Text("+ Add Step row").font(.caption).foregroundColor(Color.brandGold)
                }
            }
            .padding(.horizontal)
            
            Button(action: {
                let calculatedTime = Int(manualPrepTime) ?? 10
                let newRecipe = Recipe(
                    title: manualTitle.isEmpty ? "Custom Created Recipe" : manualTitle,
                    description: manualDescription.isEmpty ? "Manually documented cookbook creation." : manualDescription,
                    ingredients: manualIngredients.filter { !$0.isEmpty },
                    instructions: manualInstructions.filter { !$0.isEmpty },
                    prepTime: calculatedTime
                )
                recipes.append(newRecipe)
                isPresented = false
            }) {
                Text("Save to Kitchen Book")
                    .font(.headline).foregroundColor(.white)
                    .frame(maxWidth: .infinity).frame(height: 52)
                    .background(manualTitle.isEmpty ? Color.brandSecondary.opacity(0.4) : Color.brandText)
                    .cornerRadius(16)
            }
            .disabled(manualTitle.isEmpty)
            .padding(.horizontal)
        }
    }
}