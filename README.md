# recipe-circle
ios recipe circle app
=======
# Recipe Circle - iOS Recipe Management App

A beautiful and intuitive iOS app for keeping track of your favorite recipes and sharing them with others.

## Features

### 🍽️ Recipe Management
- **Create & Edit Recipes**: Add detailed recipes with ingredients, instructions, cooking times, and more
- **Photo Support**: Attach photos to your recipes for visual reference
- **Rich Metadata**: Track cooking time, prep time, servings, difficulty level, and categories
- **Notes & Tags**: Add personal notes and organize recipes with custom tags

### 📱 Modern iOS Design
- **SwiftUI Interface**: Built with the latest SwiftUI framework for a native iOS experience
- **Tabbed Navigation**: Easy access to Recipes, Categories, and Search
- **Responsive Layout**: Optimized for both iPhone and iPad
- **Dark Mode Support**: Automatically adapts to system appearance settings

### 🔍 Smart Search & Filtering
- **Full-Text Search**: Search across recipe titles, ingredients, and instructions
- **Category Filtering**: Filter recipes by category (Dessert, Main Course, Appetizer, etc.)
- **Difficulty Filtering**: Find recipes by difficulty level (Easy, Medium, Hard)
- **Multiple Sort Options**: Sort by date created, title, cooking time, or difficulty

### 📂 Organization
- **Categories**: Organize recipes into custom categories
- **Tags System**: Add multiple tags to recipes for flexible organization
- **Recipe Counts**: See how many recipes you have in each category

### 📤 Sharing & Export
- **Native Sharing**: Share recipes using iOS's built-in sharing system
- **Multiple Formats**: Export recipes as text, JSON, or PDF
- **Rich Formatting**: Beautifully formatted recipe text with emojis and structure
- **Import Support**: Import recipes from JSON format

### 💾 Data Persistence
- **Core Data**: Reliable local storage using Apple's Core Data framework
- **Automatic Backup**: Data is automatically backed up with iCloud (when enabled)
- **Offline Access**: All features work without internet connection

## Technical Details

### Architecture
- **SwiftUI**: Modern declarative UI framework
- **Core Data**: Local data persistence and management
- **MVVM Pattern**: Clean separation of concerns with ViewModels
- **Combine**: Reactive programming for data flow

### Requirements
- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

### Project Structure
```
RecipeCircle/
├── Views/                 # SwiftUI views
│   ├── RecipeListView.swift
│   ├── RecipeDetailView.swift
│   ├── AddRecipeView.swift
│   ├── CategoryView.swift
│   └── SearchView.swift
├── ViewModels/            # Business logic
│   └── RecipeViewModel.swift
├── Models/                # Core Data models
│   ├── RecipeModel.xcdatamodeld
│   └── PersistenceController.swift
├── Utils/                 # Utilities and helpers
│   └── ShareSheet.swift
└── Assets.xcassets/       # App icons and colors
```

## Getting Started

### Prerequisites
1. Install Xcode 15.0 or later
2. Ensure you have an Apple Developer account (for device testing)

### Installation
1. Clone the repository
2. Open `RecipeCircle.xcodeproj` in Xcode
3. Select your target device or simulator
4. Build and run the project (⌘+R)

### First Launch
1. The app will create a sample recipe to get you started
2. Tap the "+" button to add your first recipe
3. Explore the different tabs to see all features

## Usage Guide

### Adding Recipes
1. Tap the "+" button in the Recipes tab
2. Fill in the recipe details:
   - Title (required)
   - Category (required)
   - Ingredients (required)
   - Instructions (required)
   - Cooking time, prep time, servings
   - Add a photo (optional)
   - Notes and tags (optional)
3. Tap "Save" to add the recipe

### Searching Recipes
1. Go to the Search tab
2. Type in the search bar to find recipes by name, ingredients, or instructions
3. Use the filter chips to narrow down results by category, difficulty, or sort order

### Organizing Recipes
1. Use the Categories tab to see all your recipe categories
2. Tap on a category to see all recipes in that category
3. Add tags to recipes for more flexible organization

### Sharing Recipes
1. Open any recipe detail view
2. Tap the menu button (⋯) in the top right
3. Select "Share Recipe" to open the sharing sheet
4. Choose how you want to share (Messages, Mail, AirDrop, etc.)

## Data Model

The app uses Core Data with the following main entity:

### Recipe Entity
- `id`: Unique identifier (UUID)
- `title`: Recipe name
- `ingredients`: List of ingredients
- `instructions`: Step-by-step instructions
- `category`: Recipe category
- `difficulty`: Easy/Medium/Hard
- `cookingTime`: Cooking time in minutes
- `prepTime`: Preparation time in minutes
- `servings`: Number of servings
- `notes`: Additional notes
- `tags`: Comma-separated tags
- `imageData`: Recipe photo (Binary data)
- `dateCreated`: Creation timestamp
- `dateModified`: Last modification timestamp
- `totalTime`: Calculated total time (prep + cooking)

## Contributing

This is a personal project, but suggestions and improvements are welcome! Feel free to:
- Report bugs
- Suggest new features
- Submit pull requests
- Share feedback

## License

This project is available for personal use. Please respect the code and don't redistribute without permission.

## Future Enhancements

Potential features for future versions:
- Recipe scaling (double/half ingredients)
- Meal planning and shopping lists
- Recipe ratings and reviews
- Social features for sharing with friends
- Integration with cooking websites
- Voice instructions
- Timer integration
- Nutritional information

---

Built with ❤️ using SwiftUI and Core Data
