import CoreData
import SwiftUI

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Create sample data for previews
        let sampleRecipe = Recipe(context: viewContext)
        sampleRecipe.id = UUID()
        sampleRecipe.title = "Chocolate Chip Cookies"
        sampleRecipe.ingredients = "2 cups flour\n1 cup butter\n1 cup sugar\n2 eggs\n1 tsp vanilla\n1 cup chocolate chips"
        sampleRecipe.instructions = "1. Mix dry ingredients\n2. Cream butter and sugar\n3. Add eggs and vanilla\n4. Combine wet and dry ingredients\n5. Fold in chocolate chips\n6. Bake at 375°F for 10-12 minutes"
        sampleRecipe.cookingTime = 30
        sampleRecipe.servings = 24
        sampleRecipe.category = "Dessert"
        sampleRecipe.difficulty = "Easy"
        sampleRecipe.dateCreated = Date()
        sampleRecipe.dateModified = Date()
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "RecipeModel")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
