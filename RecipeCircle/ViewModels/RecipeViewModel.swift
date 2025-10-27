import Foundation
import CoreData
import SwiftUI

class RecipeViewModel: ObservableObject {
    @Published var recipes: [Recipe] = []
    @Published var searchText = ""
    @Published var selectedCategory = "All"
    @Published var selectedDifficulty = "All"
    @Published var sortOption = SortOption.dateCreated
    
    enum SortOption: String, CaseIterable {
        case dateCreated = "Date Created"
        case title = "Title"
        case cookingTime = "Cooking Time"
        case difficulty = "Difficulty"
    }
    
    private let viewContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
        fetchRecipes()
    }
    
    func fetchRecipes() {
        let request: NSFetchRequest<Recipe> = Recipe.fetchRequest()
        
        // Apply search filter
        if !searchText.isEmpty {
            request.predicate = NSPredicate(format: "title CONTAINS[cd] %@ OR ingredients CONTAINS[cd] %@ OR instructions CONTAINS[cd] %@", searchText, searchText, searchText)
        }
        
        // Apply category filter
        if selectedCategory != "All" {
            let categoryPredicate = NSPredicate(format: "category == %@", selectedCategory)
            if let existingPredicate = request.predicate {
                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [existingPredicate, categoryPredicate])
            } else {
                request.predicate = categoryPredicate
            }
        }
        
        // Apply difficulty filter
        if selectedDifficulty != "All" {
            let difficultyPredicate = NSPredicate(format: "difficulty == %@", selectedDifficulty)
            if let existingPredicate = request.predicate {
                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [existingPredicate, difficultyPredicate])
            } else {
                request.predicate = difficultyPredicate
            }
        }
        
        // Apply sorting
        switch sortOption {
        case .dateCreated:
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Recipe.dateCreated, ascending: false)]
        case .title:
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Recipe.title, ascending: true)]
        case .cookingTime:
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Recipe.cookingTime, ascending: true)]
        case .difficulty:
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Recipe.difficulty, ascending: true)]
        }
        
        do {
            recipes = try viewContext.fetch(request)
        } catch {
            print("Error fetching recipes: \(error)")
        }
    }
    
    func addRecipe(title: String, ingredients: String, instructions: String, category: String, difficulty: String, cookingTime: Int16, prepTime: Int16, servings: Int16, notes: String = "", tags: String = "", imageData: Data? = nil) {
        let newRecipe = Recipe(context: viewContext)
        newRecipe.id = UUID()
        newRecipe.title = title
        newRecipe.ingredients = ingredients
        newRecipe.instructions = instructions
        newRecipe.category = category
        newRecipe.difficulty = difficulty
        newRecipe.cookingTime = cookingTime
        newRecipe.prepTime = prepTime
        newRecipe.servings = servings
        newRecipe.notes = notes
        newRecipe.tags = tags
        newRecipe.imageData = imageData
        newRecipe.dateCreated = Date()
        newRecipe.dateModified = Date()
        newRecipe.totalTime = cookingTime + prepTime
        
        saveContext()
        fetchRecipes()
    }
    
    func updateRecipe(_ recipe: Recipe, title: String, ingredients: String, instructions: String, category: String, difficulty: String, cookingTime: Int16, prepTime: Int16, servings: Int16, notes: String = "", tags: String = "", imageData: Data? = nil) {
        recipe.title = title
        recipe.ingredients = ingredients
        recipe.instructions = instructions
        recipe.category = category
        recipe.difficulty = difficulty
        recipe.cookingTime = cookingTime
        recipe.prepTime = prepTime
        recipe.servings = servings
        recipe.notes = notes
        recipe.tags = tags
        recipe.imageData = imageData
        recipe.dateModified = Date()
        recipe.totalTime = cookingTime + prepTime
        
        saveContext()
        fetchRecipes()
    }
    
    func deleteRecipe(_ recipe: Recipe) {
        viewContext.delete(recipe)
        saveContext()
        fetchRecipes()
    }
    
    func getCategories() -> [String] {
        let request: NSFetchRequest<Recipe> = Recipe.fetchRequest()
        request.propertiesToFetch = ["category"]
        request.returnsDistinctResults = true
        
        do {
            let recipes = try viewContext.fetch(request)
            let categories = recipes.compactMap { $0.category }.filter { !$0.isEmpty }
            return Array(Set(categories)).sorted()
        } catch {
            print("Error fetching categories: \(error)")
            return []
        }
    }
    
    func getDifficulties() -> [String] {
        return ["Easy", "Medium", "Hard"]
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
}
