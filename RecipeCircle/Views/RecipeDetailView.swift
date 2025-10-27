import SwiftUI
import CoreData

struct RecipeDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel: RecipeViewModel
    @State private var showingEditRecipe = false
    @State private var showingShareSheet = false
    @State private var showingDeleteAlert = false
    
    let recipe: Recipe
    
    init(recipe: Recipe) {
        self.recipe = recipe
        _viewModel = StateObject(wrappedValue: RecipeViewModel(context: PersistenceController.shared.container.viewContext))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Recipe Image
                if let imageData = recipe.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 250)
                        .clipped()
                        .cornerRadius(16)
                } else {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 250)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                                .font(.system(size: 50))
                        )
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    // Recipe Title and Meta Info
                    VStack(alignment: .leading, spacing: 8) {
                        Text(recipe.title ?? "Untitled Recipe")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 16) {
                            if recipe.cookingTime > 0 {
                                RecipeMetaInfo(icon: "clock", text: "\(recipe.cookingTime) min")
                            }
                            
                            if recipe.servings > 0 {
                                RecipeMetaInfo(icon: "person", text: "\(recipe.servings) servings")
                            }
                            
                            if let difficulty = recipe.difficulty {
                                RecipeMetaInfo(icon: "star", text: difficulty)
                            }
                        }
                        
                        if let category = recipe.category {
                            Text(category)
                                .font(.subheadline)
                                .foregroundColor(.orange)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(Color.orange.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                    
                    Divider()
                    
                    // Ingredients Section
                    if let ingredients = recipe.ingredients, !ingredients.isEmpty {
                        RecipeSectionView(title: "Ingredients", content: ingredients)
                    }
                    
                    Divider()
                    
                    // Instructions Section
                    if let instructions = recipe.instructions, !instructions.isEmpty {
                        RecipeSectionView(title: "Instructions", content: instructions)
                    }
                    
                    // Notes Section
                    if let notes = recipe.notes, !notes.isEmpty {
                        Divider()
                        RecipeSectionView(title: "Notes", content: notes)
                    }
                    
                    // Tags Section
                    if let tags = recipe.tags, !tags.isEmpty {
                        Divider()
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tags")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            FlowLayout(spacing: 8) {
                                ForEach(tags.components(separatedBy: ","), id: \.self) { tag in
                                    Text(tag.trimmingCharacters(in: .whitespaces))
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.blue.opacity(0.1))
                                        .foregroundColor(.blue)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                    
                    // Date Information
                    VStack(alignment: .leading, spacing: 4) {
                        if let dateCreated = recipe.dateCreated {
                            Text("Created: \(dateCreated, formatter: dateFormatter)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        if let dateModified = recipe.dateModified, dateModified != recipe.dateCreated {
                            Text("Modified: \(dateModified, formatter: dateFormatter)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button("Edit Recipe") {
                        showingEditRecipe = true
                    }
                    
                    Button("Share Recipe") {
                        showingShareSheet = true
                    }
                    
                    Button("Delete Recipe", role: .destructive) {
                        showingDeleteAlert = true
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingEditRecipe) {
            AddRecipeView(recipe: recipe)
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(recipe: recipe)
        }
        .alert("Delete Recipe", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                viewModel.deleteRecipe(recipe)
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("Are you sure you want to delete this recipe? This action cannot be undone.")
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
}

struct RecipeMetaInfo: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(.orange)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

struct RecipeSectionView: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(content)
                .font(.body)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct FlowLayout: Layout {
    let spacing: CGFloat
    
    init(spacing: CGFloat = 8) {
        self.spacing = spacing
    }
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: result.positions[index], proposal: .unspecified)
        }
    }
}

struct FlowResult {
    let size: CGSize
    let positions: [CGPoint]
    
    init(in maxWidth: CGFloat, subviews: LayoutSubviews, spacing: CGFloat) {
        var currentPosition = CGPoint.zero
        var lineHeight: CGFloat = 0
        var positions: [CGPoint] = []
        
        for subview in subviews {
            let subviewSize = subview.sizeThatFits(.unspecified)
            
            if currentPosition.x + subviewSize.width > maxWidth && currentPosition.x > 0 {
                currentPosition.x = 0
                currentPosition.y += lineHeight + spacing
                lineHeight = 0
            }
            
            positions.append(currentPosition)
            lineHeight = max(lineHeight, subviewSize.height)
            currentPosition.x += subviewSize.width + spacing
        }
        
        self.positions = positions
        self.size = CGSize(
            width: maxWidth,
            height: currentPosition.y + lineHeight
        )
    }
}

#Preview {
    NavigationView {
        RecipeDetailView(recipe: PersistenceController.preview.container.viewContext.registeredObjects.first(where: { $0 is Recipe }) as! Recipe)
    }
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
