import Foundation
import CloudKit
import SwiftUI

class CloudKitManager: ObservableObject {
    @Published var isSignedIn = false
    @Published var accountStatus: CKAccountStatus = .couldNotDetermine
    @Published var errorMessage: String?
    
    private let container = CKContainer(identifier: "iCloud.com.recipecircle.app")
    
    init() {
        checkAccountStatus()
    }
    
    func checkAccountStatus() {
        container.accountStatus { [weak self] status, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "Error checking iCloud account: \(error.localizedDescription)"
                    self?.isSignedIn = false
                    return
                }
                
                self?.accountStatus = status
                self?.isSignedIn = (status == .available)
                
                switch status {
                case .available:
                    self?.errorMessage = nil
                case .noAccount:
                    self?.errorMessage = "No iCloud account signed in. Please sign in to iCloud in Settings."
                case .restricted:
                    self?.errorMessage = "iCloud account is restricted."
                case .couldNotDetermine:
                    self?.errorMessage = "Could not determine iCloud account status."
                case .temporarilyUnavailable:
                    self?.errorMessage = "Temporarily Unavailable."
                @unknown default:
                    self?.errorMessage = "Unknown iCloud account status."
                }
            }
        }
    }
    
    func requestAccountStatus() {
        checkAccountStatus()
    }
    
    var statusMessage: String {
        switch accountStatus {
        case .available:
            return "iCloud sync is enabled"
        case .noAccount:
            return "Sign in to iCloud to sync recipes"
        case .restricted:
            return "iCloud account is restricted"
        case .couldNotDetermine:
            return "Checking iCloud status..."
        case .temporarilyUnavailable:
            return "Temporarily Unavailable"
        @unknown default:
            return "Unknown iCloud status"
        }
    }
    
    var statusColor: Color {
        switch accountStatus {
        case .available:
            return .green
        case .noAccount, .restricted:
            return .orange
        case .couldNotDetermine:
            return .gray
        case .temporarilyUnavailable:
            return .gray
        @unknown default:
            return .gray
        }
    }
}
