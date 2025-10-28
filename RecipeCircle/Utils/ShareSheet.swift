import SwiftUI
import UIKit
import MessageUI

struct ShareSheet: UIViewControllerRepresentable {
    let recipe: Recipe
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let activityItems = createActivityItems()
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
        // Configure for iPad
        if let popover = activityViewController.popoverPresentationController {
            // Use modern iOS 15+ approach to get the window scene
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                popover.sourceView = window.rootViewController?.view
            }
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

// MARK: - SMS Message Composer

struct SMSComposeView: UIViewControllerRepresentable {
    let recipe: Recipe
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> MFMessageComposeViewController {
        let composer = MFMessageComposeViewController()
        composer.messageComposeDelegate = context.coordinator
        composer.body = createSMSText()
        
        // Add image attachment if available and not too large
        if let imageData = recipe.imageData,
           imageData.count < 1_000_000, // Limit to ~1MB for SMS
           let image = UIImage(data: imageData),
           let compressedData = image.jpegData(compressionQuality: 0.5) {
            composer.addAttachmentData(compressedData, typeIdentifier: "public.jpeg", filename: "recipe.jpg")
        }
        
        return composer
    }
    
    func updateUIViewController(_ uiViewController: MFMessageComposeViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    private func createSMSText() -> String {
        var text = ""
        
        text += "🍽️ \(recipe.title ?? "Recipe")\n\n"
        
        if let category = recipe.category {
            text += "📂 \(category)"
        }
        
        if let difficulty = recipe.difficulty {
            text += " • \(difficulty)"
        }
        
        if recipe.cookingTime > 0 {
            text += " • ⏱️ \(recipe.cookingTime)min"
        }
        
        if recipe.servings > 0 {
            text += " • 👥 \(recipe.servings) servings"
        }
        
        text += "\n\n"
        
        // Ingredients
        if let ingredients = recipe.ingredients, !ingredients.isEmpty {
            text += "🥘 INGREDIENTS:\n\(ingredients)\n\n"
        }
        
        // Instructions
        if let instructions = recipe.instructions, !instructions.isEmpty {
            text += "👨‍🍳 INSTRUCTIONS:\n\(instructions)\n\n"
        }
        
        text += "📱 Shared from Recipe Circle"
        
        return text
    }
    
    class Coordinator: NSObject, MFMessageComposeViewControllerDelegate {
        let parent: SMSComposeView
        
        init(_ parent: SMSComposeView) {
            self.parent = parent
        }
        
        func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

// MARK: - Email Composer

struct EmailComposeView: UIViewControllerRepresentable {
    let recipe: Recipe
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = context.coordinator
        composer.setSubject("Recipe: \(recipe.title ?? "Untitled")")
        composer.setMessageBody(createEmailHTML(), isHTML: true)
        
        // Add image attachment if available
        if let imageData = recipe.imageData {
            composer.addAttachmentData(imageData, mimeType: "image/jpeg", fileName: "recipe.jpg")
        }
        
        return composer
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    private func createEmailHTML() -> String {
        var html = """
        <html>
        <head>
            <style>
                body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Arial, sans-serif; padding: 20px; background-color: #f5f5f5; }
                .container { background-color: white; border-radius: 10px; padding: 30px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); max-width: 600px; margin: 0 auto; }
                h1 { color: #FF6B35; margin-bottom: 10px; }
                .meta { background-color: #FFF3E0; padding: 15px; border-radius: 8px; margin: 20px 0; }
                .meta-item { display: inline-block; margin-right: 15px; color: #666; }
                .section { margin: 25px 0; }
                .section-title { color: #FF6B35; font-weight: bold; font-size: 18px; margin-bottom: 10px; border-bottom: 2px solid #FF6B35; padding-bottom: 5px; }
                .content { line-height: 1.6; white-space: pre-wrap; color: #333; }
                .footer { text-align: center; color: #999; margin-top: 40px; padding-top: 20px; border-top: 1px solid #ddd; font-size: 12px; }
            </style>
        </head>
        <body>
            <div class="container">
                <h1>🍽️ \(recipe.title ?? "Untitled Recipe")</h1>
        """
        
        // Meta information
        html += "<div class='meta'>"
        
        if let category = recipe.category {
            html += "<span class='meta-item'>📂 \(category)</span>"
        }
        
        if let difficulty = recipe.difficulty {
            html += "<span class='meta-item'>⭐ \(difficulty)</span>"
        }
        
        if recipe.cookingTime > 0 {
            html += "<span class='meta-item'>⏱️ \(recipe.cookingTime) min</span>"
        }
        
        if recipe.prepTime > 0 {
            html += "<span class='meta-item'>🔪 Prep: \(recipe.prepTime) min</span>"
        }
        
        if recipe.servings > 0 {
            html += "<span class='meta-item'>👥 \(recipe.servings) servings</span>"
        }
        
        html += "</div>"
        
        // Ingredients
        if let ingredients = recipe.ingredients, !ingredients.isEmpty {
            html += """
                <div class="section">
                    <div class="section-title">🥘 Ingredients</div>
                    <div class="content">\(ingredients.replacingOccurrences(of: "\n", with: "<br>"))</div>
                </div>
            """
        }
        
        // Instructions
        if let instructions = recipe.instructions, !instructions.isEmpty {
            html += """
                <div class="section">
                    <div class="section-title">👨‍🍳 Instructions</div>
                    <div class="content">\(instructions.replacingOccurrences(of: "\n", with: "<br>"))</div>
                </div>
            """
        }
        
        // Notes
        if let notes = recipe.notes, !notes.isEmpty {
            html += """
                <div class="section">
                    <div class="section-title">📝 Notes</div>
                    <div class="content">\(notes.replacingOccurrences(of: "\n", with: "<br>"))</div>
                </div>
            """
        }
        
        // Tags
        if let tags = recipe.tags, !tags.isEmpty {
            html += """
                <div class="section">
                    <div class="section-title">🏷️ Tags</div>
                    <div class="content">\(tags)</div>
                </div>
            """
        }
        
        html += """
                <div class="footer">
                    📱 Shared from Recipe Circle
                </div>
            </div>
        </body>
        </html>
        """
        
        return html
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let parent: EmailComposeView
        
        init(_ parent: EmailComposeView) {
            self.parent = parent
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            parent.presentationMode.wrappedValue.dismiss()
        }
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
