# iCloud Sync Setup Guide for Recipe Circle

This guide will help you enable iCloud sync for your Recipe Circle app.

## Prerequisites

1. An Apple Developer account (free or paid)
2. Xcode 15.0 or later
3. An iOS device or simulator running iOS 17.0 or later
4. Signed in to iCloud on your test device

## Step-by-Step Setup

### 1. Open Project in Xcode

```bash
cd /Users/wenchangliu/stash/recipe-circle
open RecipeCircle.xcodeproj
```

### 2. Configure Signing & Capabilities

1. In Xcode, select the **RecipeCircle** project in the Project Navigator
2. Select the **RecipeCircle** target
3. Go to the **Signing & Capabilities** tab
4. Under **Team**, select your Apple Developer account
5. Xcode will automatically create a unique Bundle Identifier

### 3. Add iCloud Capability

1. Still in **Signing & Capabilities**, click **+ Capability**
2. Search for and add **iCloud**
3. Check the following options:
   - ☑ **CloudKit**
4. Under **Containers**, click **+** to add a new container
5. Name it: `iCloud.com.recipecircle.app` (or use the auto-generated name)

### 4. Add Background Modes (Optional but Recommended)

1. Click **+ Capability** again
2. Add **Background Modes**
3. Check:
   - ☑ **Remote notifications** (for CloudKit sync notifications)

### 5. Update PersistenceController for CloudKit

The `PersistenceController.swift` file is ready for iCloud but currently disabled to allow local testing. To enable CloudKit sync:

1. Open `RecipeCircle/Models/PersistenceController.swift`
2. Replace the `init` method with the CloudKit-enabled version (see below)

### 6. Test iCloud Sync

1. Build and run the app on two devices signed in to the same iCloud account
2. Create a recipe on one device
3. Wait a few seconds (CloudKit sync can take 5-30 seconds)
4. Check if the recipe appears on the second device

## CloudKit-Enabled PersistenceController

Replace the `init` method in `PersistenceController.swift` with this code:

```swift
init(inMemory: Bool = false) {
    // Use NSPersistentCloudKitContainer for iCloud sync
    container = NSPersistentCloudKitContainer(name: "RecipeModel")
    
    if inMemory {
        container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
    } else {
        // Configure CloudKit integration
        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("Could not retrieve a persistent store description.")
        }
        
        // Enable persistent history tracking for CloudKit
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        // Configure CloudKit container options
        description.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(
            containerIdentifier: "iCloud.com.recipecircle.app"
        )
    }
    
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
        if let error = error as NSError? {
            fatalError("Unresolved error \(error), \(error.userInfo)")
            }
    })
    
    // Configure view context for CloudKit
    container.viewContext.automaticallyMergesChangesFromParent = true
    container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
}
```

## Important Notes

### Container Identifier

The container identifier `iCloud.com.recipecircle.app` must match:
1. The container you created in Xcode's Signing & Capabilities
2. The container in your Apple Developer account (created automatically by Xcode)
3. The container specified in `PersistenceController.swift`

### Testing

- **Simulator**: iCloud sync works in the simulator but requires being signed in to iCloud
- **Real Device**: Best for testing actual sync behavior
- **CloudKit Dashboard**: Monitor your data at [https://icloud.developer.apple.com/dashboard](https://icloud.developer.apple.com/dashboard)

### Sync Behavior

- Initial sync can take up to 30 seconds
- Subsequent changes usually sync within 5-10 seconds
- Large images may take longer to sync
- Offline changes will sync when the device reconnects

### Troubleshooting

1. **"No iCloud account" error**:
   - Make sure you're signed in to iCloud on your device
   - Go to Settings → [Your Name] → iCloud and ensure iCloud Drive is enabled

2. **Sync not working**:
   - Check that both devices are signed in to the same iCloud account
   - Ensure you have an internet connection
   - Check the Settings tab in the app for iCloud status

3. **Build errors**:
   - Ensure your Bundle Identifier is unique
   - Check that your Apple Developer account is valid
   - Try cleaning the build folder (Shift + Cmd + K)

4. **"Container not found" error**:
   - The container identifier in code must match Xcode's Signing & Capabilities
   - Wait a few minutes for Apple's servers to provision the container

## Features

Once iCloud is enabled, your app will:

- ✅ Automatically sync recipes across all your devices
- ✅ Work offline and sync when reconnected
- ✅ Handle conflicts intelligently
- ✅ Show iCloud status in the Settings tab
- ✅ Encrypt data securely in your personal iCloud account

## Privacy

All recipe data is:
- Stored in your personal iCloud account
- Encrypted in transit and at rest
- Only accessible by you
- Never shared with third parties

## Support

For issues with iCloud functionality:
1. Check the Settings tab for iCloud status
2. Review Apple's CloudKit documentation
3. Check the CloudKit Dashboard for errors

Enjoy syncing your recipes across all your devices! 🍽️


