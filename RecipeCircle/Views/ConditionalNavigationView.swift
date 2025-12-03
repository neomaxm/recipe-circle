import SwiftUI

/// A view that conditionally wraps content in NavigationView/NavigationStack
/// On iPhone: wraps in NavigationView
/// On iPad: wraps in NavigationStack (for use in NavigationSplitView detail pane)
struct ConditionalNavigationView<Content: View>: View {
    let content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        if UIDevice.current.userInterfaceIdiom == .pad {
            // On iPad, wrap in NavigationStack for proper navigation context in NavigationSplitView detail pane
            NavigationStack {
                content()
            }
        } else {
            // On iPhone, wrap in NavigationView
            NavigationView {
                content()
            }
        }
    }
}

