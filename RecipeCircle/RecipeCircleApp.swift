import SwiftUI

@main
struct RecipeCircleApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var cloudKitManager = CloudKitManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(cloudKitManager)
        }
    }
}