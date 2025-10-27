import SwiftUI
import UIKit

struct ShareSheet: UIViewControllerRepresentable {
    let recipe: Recipe
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let activityItems = createActivityItems()
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
        // Configure for iPad
        if let popover = activityViewController.popoverPresentationController {
            popover.sourceView = UIApplication.shared.windows.first?.rootViewController?.view
            popover.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        return activityViewController
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
    
    private func createActivityItems() -> [Any] {
        var items: [Any] = []
        
        // Create formatted text content
        let formattedText = createFormattedRecipeText()
        items.append(formattedText)
        
        // Add image if available
        if let imageData = recipe.imageData, let image = UIImage(data: imageData) {
            items.append(image)
        }
        
        return items
    }
    
    private func createFormattedRecipeText() -> String {
        var text = ""
        
        // Title
        text += "🍽️ \(recipe.title ?? "Untitled Recipe")\n\n"
        
        // Meta information
        if let category = recipe.category {
            text += "📂 Category: \(category)\n"
        }
        
        if let difficulty = recipe.difficulty {
            text += "⭐ Difficulty: \(difficulty)\n"
        }
        
        if recipe.cookingTime > 0 {
            text += "⏱️ Cooking Time: \(recipe.cookingTime) minutes\n"
        }
        
        if recipe.servings > 0 {
            text += "👥 Servings: \(recipe.servings)\n"
        }
        
        text += "\n"
        
        // Ingredients
        if let ingredients = recipe.ingredients, !ingredients.isEmpty {
            text += "🥘 INGREDIENTS:\n"
            text += ingredients
            text += "\n\n"
        }
        
        // Instructions
        if let instructions = recipe.instructions, !instructions.isEmpty {
            text += "👨‍🍳 INSTRUCTIONS:\n"
            text += instructions
            text += "\n\n"
        }
        
        // Notes
        if let notes = recipe.notes, !notes.isEmpty {
            text += "📝 NOTES:\n"
            text += notes
            text += "\n\n"
        }
        
        // Tags
        if let tags = recipe.tags, !tags.isEmpty {
            text += "🏷️ TAGS: \(tags)\n\n"
        }
        
        // Footer
        text += "📱 Shared from Recipe Circle"
        
        return text
    }
}

// MARK: - Recipe Export Formats

extension ShareSheet {
    static func createPDF(from recipe: Recipe) -> Data? {
        // This would create a PDF version of the recipe
        // For now, we'll return the formatted text as data
        let formattedText = createFormattedRecipeText(for: recipe)
        return formattedText.data(using: .utf8)
    }
    
    static func createFormattedRecipeText(for recipe: Recipe) -> String {
        var text = ""
        
        // Title
        text += "🍽️ \(recipe.title ?? "Untitled Recipe")\n\n"
        
        // Meta information
        if let category = recipe.category {
            text += "📂 Category: \(category)\n"
        }
        
        if let difficulty = recipe.difficulty {
            text += "⭐ Difficulty: \(difficulty)\n"
        }
        
        if recipe.cookingTime > 0 {
            text += "⏱️ Cooking Time: \(recipe.cookingTime) minutes\n"
        }
        
        if recipe.servings > 0 {
            text += "👥 Servings: \(recipe.servings)\n"
        }
        
        text += "\n"
        
        // Ingredients
        if let ingredients = recipe.ingredients, !ingredients.isEmpty {
            text += "🥘 INGREDIENTS:\n"
            text += ingredients
            text += "\n\n"
        }
        
        // Instructions
        if let instructions = recipe.instructions, !instructions.isEmpty {
            text += "👨‍🍳 INSTRUCTIONS:\n"
            text += instructions
            text += "\n\n"
        }
        
        // Notes
        if let notes = recipe.notes, !notes.isEmpty {
            text += "📝 NOTES:\n"
            text += notes
            text += "\n\n"
        }
        
        // Tags
        if let tags = recipe.tags, !tags.isEmpty {
            text += "🏷️ TAGS: \(tags)\n\n"
        }
        
        // Footer
        text += "📱 Shared from Recipe Circle"
        
        return text
    }
}

// MARK: - Recipe Import/Export Manager

class RecipeImportExportManager: ObservableObject {
    static let shared = RecipeImportExportManager()
    
    private init() {}
    
    func exportRecipe(_ recipe: Recipe, format: ExportFormat) -> Data? {
        switch format {
        case .text:
            return ShareSheet.createFormattedRecipeText(for: recipe).data(using: .utf8)
        case .json:
            return createJSONExport(for: recipe)
        case .pdf:
            return ShareSheet.createPDF(from: recipe)
        }
    }
    
    func importRecipe(from data: Data, format: ImportFormat) -> Recipe? {
        switch format {
        case .json:
            return importFromJSON(data)
        case .text:
            return importFromText(data)
        }
    }
    
    private func createJSONExport(for recipe: Recipe) -> Data? {
        let recipeDict: [String: Any] = [
            "title": recipe.title ?? "",
            "ingredients": recipe.ingredients ?? "",
            "instructions": recipe.instructions ?? "",
            "category": recipe.category ?? "",
            "difficulty": recipe.difficulty ?? "",
            "cookingTime": recipe.cookingTime,
            "prepTime": recipe.prepTime,
            "servings": recipe.servings,
            "notes": recipe.notes ?? "",
            "tags": recipe.tags ?? "",
            "dateCreated": recipe.dateCreated?.timeIntervalSince1970 ?? 0,
            "dateModified": recipe.dateModified?.timeIntervalSince1970 ?? 0
        ]
        
        return try? JSONSerialization.data(withJSONObject: recipeDict, options: .prettyPrinted)
    }
    
    private func importFromJSON(_ data: Data) -> Recipe? {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        
        let context = PersistenceController.shared.container.viewContext
        let recipe = Recipe(context: context)
        
        recipe.id = UUID()
        recipe.title = json["title"] as? String
        recipe.ingredients = json["ingredients"] as? String
        recipe.instructions = json["instructions"] as? String
        recipe.category = json["category"] as? String
        recipe.difficulty = json["difficulty"] as? String
        recipe.cookingTime = json["cookingTime"] as? Int16 ?? 0
        recipe.prepTime = json["prepTime"] as? Int16 ?? 0
        recipe.servings = json["servings"] as? Int16 ?? 1
        recipe.notes = json["notes"] as? String
        recipe.tags = json["tags"] as? String
        recipe.dateCreated = Date()
        recipe.dateModified = Date()
        recipe.totalTime = recipe.cookingTime + recipe.prepTime
        
        return recipe
    }
    
    private func importFromText(_ data: Data) -> Recipe? {
        guard let text = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        // Simple text parsing - this could be enhanced
        let lines = text.components(separatedBy: .newlines)
        let context = PersistenceController.shared.container.viewContext
        let recipe = Recipe(context: context)
        
        recipe.id = UUID()
        recipe.title = lines.first ?? "Imported Recipe"
        recipe.dateCreated = Date()
        recipe.dateModified = Date()
        
        return recipe
    }
}

enum ExportFormat {
    case text
    case json
    case pdf
}

enum ImportFormat {
    case json
    case text
}
