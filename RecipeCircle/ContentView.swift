import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        Group {
            if UIDevice.current.userInterfaceIdiom == .pad {
                // iPad: Use NavigationSplitView for better layout
                iPadLayout(selectedTab: $selectedTab)
            } else {
                // iPhone: Use TabView
                iPhoneLayout(selectedTab: $selectedTab)
            }
        }
        .accentColor(.orange)
    }
}

struct iPadLayout: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        NavigationSplitView {
            // Sidebar
            List {
                Button(action: { selectedTab = 0 }) {
                    Label("Recipes", systemImage: "book.fill")
                        .foregroundColor(selectedTab == 0 ? .orange : .primary)
                }
                
                Button(action: { selectedTab = 1 }) {
                    Label("Favorites", systemImage: "heart.fill")
                        .foregroundColor(selectedTab == 1 ? .orange : .primary)
                }
                
                Button(action: { selectedTab = 2 }) {
                    Label("Categories", systemImage: "folder.fill")
                        .foregroundColor(selectedTab == 2 ? .orange : .primary)
                }
                
                Button(action: { selectedTab = 3 }) {
                    Label("Search", systemImage: "magnifyingglass")
                        .foregroundColor(selectedTab == 3 ? .orange : .primary)
                }
                
                Button(action: { selectedTab = 4 }) {
                    Label("Settings", systemImage: "gear")
                        .foregroundColor(selectedTab == 4 ? .orange : .primary)
                }
            }
            .listStyle(.sidebar)
            .navigationTitle("Recipe Circle")
        } detail: {
            // Detail view
            Group {
                switch selectedTab {
                case 0:
                    RecipeListView()
                case 1:
                    FavoritesView()
                case 2:
                    CategoryView()
                case 3:
                    SearchView()
                case 4:
                    SettingsView()
                default:
                    RecipeListView()
                }
            }
        }
        .navigationSplitViewColumnWidth(min: 200, ideal: 250)
    }
}

struct iPhoneLayout: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        TabView(selection: $selectedTab) {
            RecipeListView()
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("Recipes")
                }
                .tag(0)
            
            FavoritesView()
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Favorites")
                }
                .tag(1)
            
            CategoryView()
                .tabItem {
                    Image(systemName: "folder.fill")
                    Text("Categories")
                }
                .tag(2)
            
            SearchView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
                .tag(3)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag(4)
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(CloudKitManager())
}
