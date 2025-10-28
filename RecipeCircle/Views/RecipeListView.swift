import SwiftUI
import CoreData

struct RecipeListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Recipe.dateCreated, ascending: false)],
        animation: .default)
    private var recipes: FetchedResults<Recipe>
    
    @State private var showingAddRecipe = false
    @State private var showingFilters = false
    @State private var searchText = ""
    @State private var selectedCategory = "All"
    @State private var selectedDifficulty = "All"
    @State private var sortOption = RecipeViewModel.SortOption.dateCreated
    
    var filteredRecipes: [Recipe] {
        var result = Array(recipes)
        
        // Apply search filter
        if !searchText.isEmpty {
            result = result.filter { recipe in
                (recipe.title?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (recipe.ingredients?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (recipe.instructions?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        // Apply category filter
        if selectedCategory != "All" {
            result = result.filter { $0.category == selectedCategory }
        }
        
        // Apply difficulty filter
        if selectedDifficulty != "All" {
            result = result.filter { $0.difficulty == selectedDifficulty }
        }
        
        // Apply sorting
        switch sortOption {
        case .dateCreated:
            result.sort { ($0.dateCreated ?? Date.distantPast) > ($1.dateCreated ?? Date.distantPast) }
        case .title:
            result.sort { ($0.title ?? "") < ($1.title ?? "") }
        case .cookingTime:
            result.sort { $0.cookingTime < $1.cookingTime }
        case .difficulty:
            result.sort { ($0.difficulty ?? "") < ($1.difficulty ?? "") }
        }
        
        return result
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Search Bar
                SearchBar(text: $searchText, onSearchButtonClicked: {})
                    .padding(.horizontal)
                
                // Filter Bar
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        FilterChip(title: "Category", value: selectedCategory, options: ["All"] + getCategories()) { category in
                            selectedCategory = category
                        }
                        
                        FilterChip(title: "Difficulty", value: selectedDifficulty, options: ["All"] + getDifficulties()) { difficulty in
                            selectedDifficulty = difficulty
                        }
                        
                        FilterChip(title: "Sort", value: sortOption.rawValue, options: RecipeViewModel.SortOption.allCases.map { $0.rawValue }) { sortOption in
                            if let option = RecipeViewModel.SortOption.allCases.first(where: { $0.rawValue == sortOption }) {
                                self.sortOption = option
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Recipe List
                if filteredRecipes.isEmpty {
                    if recipes.isEmpty {
                        EmptyStateView {
                            showingAddRecipe = true
                        }
                    } else {
                        // No results from filtering
                        VStack(spacing: 20) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            Text("No recipes found")
                                .font(.title2)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                } else {
                    List {
                        ForEach(filteredRecipes, id: \.id) { recipe in
                            NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                                RecipeRowView(recipe: recipe)
                            }
                        }
                        .onDelete(perform: deleteRecipes)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("My Recipes")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddRecipe = true }) {
                        Image(systemName: "plus")
                            .foregroundColor(.orange)
                    }
                }
            }
            .sheet(isPresented: $showingAddRecipe) {
                AddRecipeView()
            }
        }
    }
    
    private func deleteRecipes(offsets: IndexSet) {
        withAnimation {
            offsets.map { filteredRecipes[$0] }.forEach { recipe in
                viewContext.delete(recipe)
            }
            
            do {
                try viewContext.save()
            } catch {
                print("Error deleting recipe: \(error)")
            }
        }
    }
    
    private func getCategories() -> [String] {
        let categories = recipes.compactMap { $0.category }.filter { !$0.isEmpty }
        return Array(Set(categories)).sorted()
    }
    
    private func getDifficulties() -> [String] {
        return ["Easy", "Medium", "Hard"]
    }
}

struct RecipeRowView: View {
    let recipe: Recipe
    
    var body: some View {
        HStack(spacing: 12) {
            // Recipe Image
            if let imageData = recipe.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .clipped()
                    .cornerRadius(12)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                            .font(.title2)
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.title ?? "Untitled Recipe")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                if let category = recipe.category {
                    Text(category)
                        .font(.caption)
                        .foregroundColor(.orange)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                }
                
                HStack {
                    if recipe.cookingTime > 0 {
                        Label("\(recipe.cookingTime) min", systemImage: "clock")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if recipe.servings > 0 {
                        Label("\(recipe.servings) servings", systemImage: "person")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                if let difficulty = recipe.difficulty {
                    Text(difficulty)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct SearchBar: View {
    @Binding var text: String
    let onSearchButtonClicked: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search recipes...", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onSubmit {
                    onSearchButtonClicked()
                }
            
            if !text.isEmpty {
                Button("Clear") {
                    text = ""
                    onSearchButtonClicked()
                }
                .foregroundColor(.orange)
            }
        }
    }
}

struct FilterChip: View {
    let title: String
    let value: String
    let options: [String]
    let onSelectionChanged: (String) -> Void
    
    @State private var showingOptions = false
    
    var body: some View {
        Button(action: { showingOptions.toggle() }) {
            HStack(spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                Image(systemName: "chevron.down")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(16)
        }
        .actionSheet(isPresented: $showingOptions) {
            ActionSheet(
                title: Text(title),
                buttons: options.map { option in
                    .default(Text(option)) {
                        onSelectionChanged(option)
                    }
                } + [.cancel()]
            )
        }
    }
}

struct EmptyStateView: View {
    let onAddRecipe: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "book.closed")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Recipes Yet")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("Start building your recipe collection by adding your first recipe!")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button("Add Recipe") {
                onAddRecipe()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    RecipeListView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
