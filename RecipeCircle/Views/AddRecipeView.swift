import SwiftUI
import PhotosUI
import CoreData

struct AddRecipeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    // Form fields
    @State private var title = ""
    @State private var ingredients = ""
    @State private var instructions = ""
    @State private var category = ""
    @State private var difficulty = "Easy"
    @State private var cookingTime = ""
    @State private var prepTime = ""
    @State private var servings = ""
    @State private var notes = ""
    @State private var tags = ""
    @State private var selectedImage: PhotosPickerItem?
    @State private var imageData: Data?
    
    // UI State
    @State private var showingImagePicker = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var availableCategories: [String] = []
    
    let recipe: Recipe?
    let isEditing: Bool
    
    init(recipe: Recipe? = nil) {
        self.recipe = recipe
        self.isEditing = recipe != nil
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Basic Information")) {
                    TextField("Recipe Title", text: $title)
                    
                    Picker("Category", selection: $category) {
                        Text("Select Category").tag("")
                        ForEach(availableCategories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    
                    Picker("Difficulty", selection: $difficulty) {
                        ForEach(getDifficulties(), id: \.self) { difficulty in
                            Text(difficulty).tag(difficulty)
                        }
                    }
                }
                
                Section(header: Text("Recipe Image")) {
                    HStack {
                        if let imageData = imageData, let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipped()
                                .cornerRadius(8)
                        } else {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 100, height: 100)
                                .overlay(
                                    Image(systemName: "photo")
                                        .foregroundColor(.gray)
                                        .font(.title2)
                                )
                        }
                        
                        VStack(alignment: .leading) {
                            PhotosPicker(selection: $selectedImage, matching: .images) {
                                Text("Choose Photo")
                                    .foregroundColor(.orange)
                            }
                            
                            if imageData != nil {
                                Button("Remove Photo") {
                                    imageData = nil
                                    selectedImage = nil
                                }
                                .foregroundColor(.red)
                            }
                        }
                        
                        Spacer()
                    }
                }
                
                Section(header: Text("Timing & Servings")) {
                    HStack {
                        TextField("Prep Time (min)", text: $prepTime)
                            .keyboardType(.numberPad)
                        TextField("Cook Time (min)", text: $cookingTime)
                            .keyboardType(.numberPad)
                    }
                    
                    TextField("Servings", text: $servings)
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text("Ingredients")) {
                    TextField("Enter ingredients (one per line)", text: $ingredients, axis: .vertical)
                        .lineLimit(5...10)
                }
                
                Section(header: Text("Instructions")) {
                    TextField("Enter step-by-step instructions", text: $instructions, axis: .vertical)
                        .lineLimit(5...15)
                }
                
                Section(header: Text("Additional Information")) {
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...5)
                    
                    TextField("Tags (comma separated)", text: $tags)
                }
            }
            .navigationTitle(isEditing ? "Edit Recipe" : "Add Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveRecipe()
                    }
                    .disabled(!isFormValid)
                }
            }
            .onChange(of: selectedImage) {
                Task {
                    if let data = try? await selectedImage?.loadTransferable(type: Data.self) {
                        imageData = data
                    }
                }
            }
            .alert("Error", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
        .onAppear {
            loadAvailableCategories()
            if isEditing, let recipe = recipe {
                loadRecipeData(recipe)
            }
        }
    }
    
    private var isFormValid: Bool {
        !title.isEmpty && !ingredients.isEmpty && !instructions.isEmpty && !category.isEmpty
    }
    
    private func loadAvailableCategories() {
        let request: NSFetchRequest<Recipe> = Recipe.fetchRequest()
        request.propertiesToFetch = ["category"]
        request.returnsDistinctResults = true
        
        do {
            let recipes = try viewContext.fetch(request)
            let categories = recipes.compactMap { $0.category }.filter { !$0.isEmpty }
            availableCategories = Array(Set(categories)).sorted()
        } catch {
            print("Error fetching categories: \(error)")
            availableCategories = []
        }
    }
    
    private func getDifficulties() -> [String] {
        return ["Easy", "Medium", "Hard"]
    }
    
    private func loadRecipeData(_ recipe: Recipe) {
        title = recipe.title ?? ""
        ingredients = recipe.ingredients ?? ""
        instructions = recipe.instructions ?? ""
        category = recipe.category ?? ""
        difficulty = recipe.difficulty ?? "Easy"
        cookingTime = recipe.cookingTime > 0 ? String(recipe.cookingTime) : ""
        prepTime = recipe.prepTime > 0 ? String(recipe.prepTime) : ""
        servings = recipe.servings > 0 ? String(recipe.servings) : ""
        notes = recipe.notes ?? ""
        tags = recipe.tags ?? ""
        imageData = recipe.imageData
    }
    
    private func saveRecipe() {
        guard isFormValid else {
            alertMessage = "Please fill in all required fields"
            showingAlert = true
            return
        }
        
        let cookingTimeInt = Int16(cookingTime) ?? 0
        let prepTimeInt = Int16(prepTime) ?? 0
        let servingsInt = Int16(servings) ?? 1
        
        if isEditing, let recipe = recipe {
            // Update existing recipe
            recipe.title = title
            recipe.ingredients = ingredients
            recipe.instructions = instructions
            recipe.category = category
            recipe.difficulty = difficulty
            recipe.cookingTime = cookingTimeInt
            recipe.prepTime = prepTimeInt
            recipe.servings = servingsInt
            recipe.notes = notes
            recipe.tags = tags
            recipe.imageData = imageData
            recipe.dateModified = Date()
            recipe.totalTime = cookingTimeInt + prepTimeInt
        } else {
            // Create new recipe
            let newRecipe = Recipe(context: viewContext)
            newRecipe.id = UUID()
            newRecipe.title = title
            newRecipe.ingredients = ingredients
            newRecipe.instructions = instructions
            newRecipe.category = category
            newRecipe.difficulty = difficulty
            newRecipe.cookingTime = cookingTimeInt
            newRecipe.prepTime = prepTimeInt
            newRecipe.servings = servingsInt
            newRecipe.notes = notes
            newRecipe.tags = tags
            newRecipe.imageData = imageData
            newRecipe.dateCreated = Date()
            newRecipe.dateModified = Date()
            newRecipe.totalTime = cookingTimeInt + prepTimeInt
        }
        
        // Save the context
        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            alertMessage = "Error saving recipe: \(error.localizedDescription)"
            showingAlert = true
        }
    }
}

#Preview {
    AddRecipeView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
