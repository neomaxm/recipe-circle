import SwiftUI
import CoreData

struct SearchView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: RecipeViewModel
    @State private var searchText = ""
    @State private var searchResults: [Recipe] = []
    @State private var isSearching = false
    
    init() {
        _viewModel = StateObject(wrappedValue: RecipeViewModel(context: PersistenceController.shared.container.viewContext))
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Search Bar
                SearchBar(text: $searchText, onSearchButtonClicked: performSearch)
                    .padding(.horizontal)
                
                // Search Filters
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        FilterChip(title: "Category", value: viewModel.selectedCategory, options: ["All"] + viewModel.getCategories()) { category in
                            viewModel.selectedCategory = category
                            performSearch()
                        }
                        
                        FilterChip(title: "Difficulty", value: viewModel.selectedDifficulty, options: ["All"] + viewModel.getDifficulties()) { difficulty in
                            viewModel.selectedDifficulty = difficulty
                            performSearch()
                        }
                        
                        FilterChip(title: "Sort", value: viewModel.sortOption.rawValue, options: RecipeViewModel.SortOption.allCases.map { $0.rawValue }) { sortOption in
                            if let option = RecipeViewModel.SortOption.allCases.first(where: { $0.rawValue == sortOption }) {
                                viewModel.sortOption = option
                                performSearch()
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Search Results
                if isSearching {
                    ProgressView("Searching...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if searchResults.isEmpty && !searchText.isEmpty {
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
            .onAppear {
                viewModel.fetchRecipes()
            }
        }
    }
    
    private func performSearch() {
        isSearching = true
        
        // Simulate search delay for better UX
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            viewModel.searchText = searchText
            viewModel.fetchRecipes()
            searchResults = viewModel.recipes
            isSearching = false
        }
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
