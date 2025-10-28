import SwiftUI
import CoreData

struct CategoryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Recipe.dateCreated, ascending: false)],
        animation: .default)
    private var recipes: FetchedResults<Recipe>
    
    @State private var showingAddCategory = false
    @State private var newCategoryName = ""
    
    var categories: [String] {
        let cats = recipes.compactMap { $0.category }.filter { !$0.isEmpty }
        return Array(Set(cats)).sorted()
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if categories.isEmpty {
                    EmptyCategoriesView()
                } else {
                    List {
                        ForEach(categories, id: \.self) { category in
                            CategoryRowView(category: category, recipeCount: getRecipeCount(for: category))
                        }
                        .onDelete(perform: deleteCategories)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Categories")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddCategory = true }) {
                        Image(systemName: "plus")
                            .foregroundColor(.orange)
                    }
                }
            }
            .alert("Add Category", isPresented: $showingAddCategory) {
                TextField("Category Name", text: $newCategoryName)
                Button("Add") {
                    addCategory()
                }
                Button("Cancel", role: .cancel) {
                    newCategoryName = ""
                }
            } message: {
                Text("Enter a name for the new category")
            }
        }
    }
    
    private func getRecipeCount(for category: String) -> Int {
        let request: NSFetchRequest<Recipe> = Recipe.fetchRequest()
        request.predicate = NSPredicate(format: "category == %@", category)
        
        do {
            return try viewContext.count(for: request)
        } catch {
            return 0
        }
    }
    
    private func deleteCategories(offsets: IndexSet) {
        for index in offsets {
            let category = categories[index]
            // Move recipes to "Uncategorized"
            let request: NSFetchRequest<Recipe> = Recipe.fetchRequest()
            request.predicate = NSPredicate(format: "category == %@", category)
            
            do {
                let recipesToUpdate = try viewContext.fetch(request)
                for recipe in recipesToUpdate {
                    recipe.category = "Uncategorized"
                }
                try viewContext.save()
            } catch {
                print("Error updating recipes: \(error)")
            }
        }
    }
    
    private func addCategory() {
        guard !newCategoryName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        let categoryName = newCategoryName.trimmingCharacters(in: .whitespaces)
        
        // Create a sample recipe with the new category
        let newRecipe = Recipe(context: viewContext)
        newRecipe.id = UUID()
        newRecipe.title = "Sample Recipe for \(categoryName)"
        newRecipe.ingredients = "Add your ingredients here"
        newRecipe.instructions = "Add your instructions here"
        newRecipe.category = categoryName
        newRecipe.difficulty = "Easy"
        newRecipe.cookingTime = 30
        newRecipe.prepTime = 15
        newRecipe.servings = 4
        newRecipe.notes = "This is a sample recipe created for the \(categoryName) category. You can edit or delete it."
        newRecipe.tags = "sample, \(categoryName.lowercased())"
        newRecipe.dateCreated = Date()
        newRecipe.dateModified = Date()
        newRecipe.totalTime = 45
        
        do {
            try viewContext.save()
        } catch {
            print("Error creating sample recipe: \(error)")
        }
        
        newCategoryName = ""
        showingAddCategory = false
    }
}

struct CategoryRowView: View {
    let category: String
    let recipeCount: Int
    
    var body: some View {
        NavigationLink(destination: CategoryDetailView(category: category)) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(category)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("\(recipeCount) recipe\(recipeCount == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
        }
    }
}

struct CategoryDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    let category: String
    
    var fetchRequest: FetchRequest<Recipe>
    
    init(category: String) {
        self.category = category
        self.fetchRequest = FetchRequest<Recipe>(
            sortDescriptors: [NSSortDescriptor(keyPath: \Recipe.dateCreated, ascending: false)],
            predicate: NSPredicate(format: "category == %@", category),
            animation: .default
        )
    }
    
    var body: some View {
        List {
            ForEach(fetchRequest.wrappedValue, id: \.id) { recipe in
                NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                    RecipeRowView(recipe: recipe)
                }
            }
        }
        .navigationTitle(category)
        .navigationBarTitleDisplayMode(.large)
    }
}

struct EmptyCategoriesView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "folder")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Categories Yet")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("Categories will appear here as you add recipes. You can organize your recipes by type, cuisine, or any other way you prefer!")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    CategoryView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
