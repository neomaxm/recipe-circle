import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var cloudKitManager: CloudKitManager
    @State private var showingCloudKitInfo = false
    
    var body: some View {
        ConditionalNavigationView {
            List {
                Section(header: Text("iCloud Sync")) {
                    HStack {
                        Image(systemName: "icloud")
                            .foregroundColor(cloudKitManager.statusColor)
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("iCloud Status")
                                .font(.headline)
                            
                            Text(cloudKitManager.statusMessage)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if cloudKitManager.accountStatus == .available {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                    .padding(.vertical, 4)
                    
                    if let errorMessage = cloudKitManager.errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.orange)
                            .padding(.vertical, 2)
                    }
                    
                    Button("Refresh Status") {
                        cloudKitManager.requestAccountStatus()
                    }
                    .disabled(cloudKitManager.accountStatus == .available)
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                        Text("Recipe Circle")
                        Spacer()
                        Text("1.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Button(action: { showingCloudKitInfo = true }) {
                        HStack {
                            Image(systemName: "questionmark.circle")
                                .foregroundColor(.blue)
                            Text("iCloud Sync Help")
                        }
                    }
                }
                
                Section(header: Text("Data")) {
                    HStack {
                        Image(systemName: "externaldrive")
                            .foregroundColor(.gray)
                        Text("Recipes are stored locally and synced to iCloud")
                        Spacer()
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingCloudKitInfo) {
                CloudKitInfoView()
            }
        }
    }
}

struct CloudKitInfoView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("iCloud Sync")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Recipe Circle uses iCloud to sync your recipes across all your devices.")
                            .font(.body)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("How it works:")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            InfoRow(icon: "1.circle.fill", text: "Sign in to iCloud on all your devices")
                            InfoRow(icon: "2.circle.fill", text: "Recipes automatically sync between devices")
                            InfoRow(icon: "3.circle.fill", text: "Changes appear on all devices within minutes")
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Requirements:")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            InfoRow(icon: "checkmark.circle.fill", text: "iCloud account signed in")
                            InfoRow(icon: "checkmark.circle.fill", text: "Internet connection")
                            InfoRow(icon: "checkmark.circle.fill", text: "iOS 17.0 or later")
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Privacy:")
                            .font(.headline)
                        
                        Text("Your recipes are encrypted and stored securely in your personal iCloud account. Only you can access your data.")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
            }
            .navigationTitle("iCloud Help")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct InfoRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            Text(text)
                .font(.body)
            
            Spacer()
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(CloudKitManager())
}
