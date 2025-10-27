import SwiftUI
import CoreData

struct RecipeListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: RecipeViewModel
    @State private var showingAddRecipe = false
    @State private var showingFilters = false
    
    init() {
        // This will be properly initialized in the body
        _viewModel = StateObject(wrappedValue: RecipeViewModel(context: PersistenceController.shared.container.viewContext))
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Search Bar
                SearchBar(text: $viewModel.searchText, onSearchButtonClicked: {
                    viewModel.fetchRecipes()
                })
                .padding(.horizontal)
                
                // Filter Bar
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        FilterChip(title: "Category", value: viewModel.selectedCategory, options: ["All"] + viewModel.getCategories()) { category in
                            viewModel.selectedCategory = category
                            viewModel.fetchRecipes()
                        }
                        
                        FilterChip(title: "Difficulty", value: viewModel.selectedDifficulty, options: ["All"] + viewModel.getDifficulties()) { difficulty in
                            viewModel.selectedDifficulty = difficulty
                            viewModel.fetchRecipes()
                        }
                        
                        FilterChip(title: "Sort", value: viewModel.sortOption.rawValue, options: RecipeViewModel.SortOption.allCases.map { $0.rawValue }) { sortOption in
                            if let option = RecipeViewModel.SortOption.allCases.first(where: { $0.rawValue == sortOption }) {
                                viewModel.sortOption = option
                                viewModel.fetchRecipes()
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Recipe List
                if viewModel.recipes.isEmpty {
                    EmptyStateView()
                } else {
                    List {
                        ForEach(viewModel.recipes, id: \.id) { recipe in
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
            .onAppear {
                viewModel.fetchRecipes()
            }
        }
    }
    
    private func deleteRecipes(offsets: IndexSet) {
        withAnimation {
            offsets.map { viewModel.recipes[$0] }.forEach(viewModel.deleteRecipe)
        }
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
                // This will be handled by the parent view
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
