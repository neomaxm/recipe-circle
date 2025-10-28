import SwiftUI
import CoreData

struct CategoryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var viewModel: RecipeViewModel?
    @State private var showingAddCategory = false
    @State private var newCategoryName = ""
    
    var body: some View {
        NavigationView {
            VStack {
                if let viewModel = viewModel {
                    if viewModel.getCategories().isEmpty {
                        EmptyCategoriesView()
                    } else {
                        List {
                            ForEach(viewModel.getCategories(), id: \.self) { category in
                                CategoryRowView(category: category, recipeCount: getRecipeCount(for: category))
                            }
                            .onDelete(perform: { offsets in
                                deleteCategories(offsets: offsets, viewModel: viewModel)
                            })
                        }
                        .listStyle(PlainListStyle())
                    }
                } else {
                    ProgressView("Loading...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                if viewModel == nil {
                    viewModel = RecipeViewModel(context: viewContext)
                }
                viewModel?.fetchRecipes()
            }
            .onChange(of: showingAddCategory) {
                if !showingAddCategory {
                    // Refresh categories when the add category alert is dismissed
                    viewModel?.fetchRecipes()
                }
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
    
    private func deleteCategories(offsets: IndexSet, viewModel: RecipeViewModel) {
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
        
        // Create a sample recipe with the new category to make it appear in the list
        guard let viewModel = viewModel else { return }
        
        let categoryName = newCategoryName.trimmingCharacters(in: .whitespaces)
        
        viewModel.addRecipe(
            title: "Sample Recipe for \(categoryName)",
            ingredients: "Add your ingredients here",
            instructions: "Add your instructions here",
            category: categoryName,
            difficulty: "Easy",
            cookingTime: 30,
            prepTime: 15,
            servings: 4,
            notes: "This is a sample recipe created for the \(categoryName) category. You can edit or delete it.",
            tags: "sample, \(categoryName.lowercased())",
            imageData: nil
        )
        
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
    @State private var viewModel: RecipeViewModel?
    let category: String
    
    var body: some View {
        Group {
            if let viewModel = viewModel {
                List {
                    ForEach(viewModel.recipes.filter { $0.category == category }, id: \.id) { recipe in
                        NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                            RecipeRowView(recipe: recipe)
                        }
                    }
                }
                .navigationTitle(category)
                .navigationBarTitleDisplayMode(.large)
            } else {
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            setupViewModel()
        }
    }
    
    init(category: String) {
        self.category = category
    }
    
    private func setupViewModel() {
        if viewModel == nil {
            viewModel = RecipeViewModel(context: viewContext)
        }
        viewModel?.selectedCategory = category
        viewModel?.fetchRecipes()
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
