import SwiftUI
import CoreData

struct SearchView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Recipe.dateCreated, ascending: false)],
        animation: .default)
    private var recipes: FetchedResults<Recipe>
    
    @State private var searchText = ""
    @State private var selectedCategory = "All"
    @State private var selectedDifficulty = "All"
    @State private var sortOption = RecipeViewModel.SortOption.dateCreated
    
    var searchResults: [Recipe] {
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
                
                // Search Filters
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
                
                // Search Results
                if searchResults.isEmpty && !searchText.isEmpty {
                    EmptySearchResultsView()
                } else if searchResults.isEmpty {
                    EmptySearchView()
                } else {
                    List {
                        ForEach(searchResults, id: \.id) { recipe in
                            NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                                RecipeRowView(recipe: recipe)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Search Recipes")
            .navigationBarTitleDisplayMode(.large)
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

struct EmptySearchView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Search Your Recipes")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("Use the search bar above to find recipes by name, ingredients, or instructions. You can also filter by category and difficulty.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct EmptySearchResultsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Results Found")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("Try adjusting your search terms or filters to find what you're looking for.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    SearchView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
