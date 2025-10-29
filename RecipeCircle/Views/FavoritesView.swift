import SwiftUI
import CoreData

struct FavoritesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Recipe.dateModified, ascending: false)],
        predicate: NSPredicate(format: "isFavorite == %@", NSNumber(value: true)),
        animation: .default)
    private var favoriteRecipes: FetchedResults<Recipe>
    
    @State private var searchText = ""
    
    var filteredRecipes: [Recipe] {
        var result = Array(favoriteRecipes)
        
        // Apply search filter
        if !searchText.isEmpty {
            result = result.filter { recipe in
                (recipe.title?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (recipe.ingredients?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (recipe.instructions?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        return result
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Search Bar
                if !favoriteRecipes.isEmpty {
                    SearchBar(text: $searchText, onSearchButtonClicked: {})
                        .padding(.horizontal)
                }
                
                // Favorites List
                if filteredRecipes.isEmpty {
                    if favoriteRecipes.isEmpty {
                        EmptyFavoritesView()
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
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Favorites")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct EmptyFavoritesView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Favorite Recipes Yet")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("Mark recipes as favorites to see them here. Tap the heart icon on any recipe to add it to your favorites!")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    FavoritesView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

