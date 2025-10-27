import SwiftUI
import CoreData

struct CategoryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: RecipeViewModel
    @State private var showingAddCategory = false
    @State private var newCategoryName = ""
    
    init() {
        _viewModel = StateObject(wrappedValue: RecipeViewModel(context: PersistenceController.shared.container.viewContext))
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.getCategories().isEmpty {
                    EmptyCategoriesView()
                } else {
                    List {
                        ForEach(viewModel.getCategories(), id: \.self) { category in
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
            .onAppear {
                viewModel.fetchRecipes()
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
        let categories = viewModel.getCategories()
        for index in offsets {
            let category = categories[index]
            // Move recipes to "Uncategorized" or delete them
            let request: NSFetchRequest<Recipe> = Recipe.fetchRequest()
            request.predicate = NSPredicate(format: "category == %@", category)
            
            do {
                let recipes = try viewContext.fetch(request)
                for recipe in recipes {
                    recipe.category = "Uncategorized"
                }
                try viewContext.save()
                viewModel.fetchRecipes()
            } catch {
                print("Error updating recipes: \(error)")
            }
        }
    }
    
    private func addCategory() {
        guard !newCategoryName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        // Categories are automatically created when recipes are assigned to them
        // This is just for UI purposes - the actual category will be created when a recipe uses it
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
    @StateObject private var viewModel: RecipeViewModel
    let category: String
    
    init(category: String) {
        self.category = category
        _viewModel = StateObject(wrappedValue: RecipeViewModel(context: PersistenceController.shared.container.viewContext))
    }
    
    var body: some View {
        List {
            ForEach(viewModel.recipes.filter { $0.category == category }, id: \.id) { recipe in
                NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                    RecipeRowView(recipe: recipe)
                }
            }
        }
        .navigationTitle(category)
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            viewModel.selectedCategory = category
            viewModel.fetchRecipes()
        }
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
