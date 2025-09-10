// EVVTransportAppApp main entry point placeholder
import SwiftUI
import Network

// MARK: - Network Monitor
class NetworkMonitor: ObservableObject {
    private let networkMonitor = NWPathMonitor()
    private let workerQueue = DispatchQueue(label: "NetworkMonitor")
    
    @Published var isConnected = true
    @Published var connectionType: NWInterface.InterfaceType?
    @Published var showOfflineNotification = false
    @Published var showReconnectedNotification = false
    @Published var lastConnectionChange: Date = Date()
    
    private var wasConnected = true
    
    init() {
        print("🔍 NetworkMonitor: Initializing")
        networkMonitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                let isNowConnected = path.status == .satisfied
                let connectionType = path.availableInterfaces.first?.type
                
                print("🔍 NetworkMonitor: Status changed - isConnected: \(isNowConnected), wasConnected: \(self.wasConnected)")
                
                // Update connection status
                self.isConnected = isNowConnected
                self.connectionType = connectionType
                
                // Show offline notification if we're offline (regardless of change)
                if !isNowConnected {
                    print("🔍 NetworkMonitor: Setting offline notification")
                    self.showOfflineNotification = true
                } else {
                    print("🔍 NetworkMonitor: Clearing offline notification")
                    self.showOfflineNotification = false
                }
                
                // Only show reconnected notification when connection status actually changes
                if self.wasConnected != isNowConnected {
                    self.lastConnectionChange = Date()
                    
                    if isNowConnected {
                        print("🔍 NetworkMonitor: Showing reconnected notification")
                        // Just reconnected
                        self.showReconnectedNotification = true
                        // Hide reconnected notification after 3 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            self.showReconnectedNotification = false
                        }
                    }
                }
                
                self.wasConnected = isNowConnected
            }
        }
        networkMonitor.start(queue: workerQueue)
    }
    
    deinit {
        networkMonitor.cancel()
    }
    
    func getConnectionTypeDescription() -> String {
        switch connectionType {
        case .wifi:
            return "Wi-Fi"
        case .cellular:
            return "Cellular"
        case .wiredEthernet:
            return "Ethernet"
        case .loopback:
            return "Local"
        case .other:
            return "Other"
        case .none:
            return "Unknown"
        @unknown default:
            return "Unknown"
        }
    }
    
    // Method to manually test offline state
    func simulateOffline() {
        DispatchQueue.main.async {
            self.isConnected = false
            self.showOfflineNotification = true
            self.showReconnectedNotification = false
        }
    }
    
    // Method to manually test online state
    func simulateOnline() {
        DispatchQueue.main.async {
            self.isConnected = true
            self.showOfflineNotification = false
            self.showReconnectedNotification = true
            // Hide reconnected notification after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.showReconnectedNotification = false
            }
        }
    }
}

@main
struct EVVTransportAppApp: App {
    @StateObject private var networkMonitor = NetworkMonitor()
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var routeViewModel = RouteViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .environmentObject(routeViewModel)
                .environmentObject(NetworkService.shared)
                .environmentObject(networkMonitor)
                .onAppear {
                    // Check for existing session on app startup
                    Task {
                        await checkExistingSession()
                    }
                }
        }
        .windowResizability(.contentSize)
    }
    
    private func checkExistingSession() async {
        // Check if there's a valid existing session
        if authViewModel.checkExistingSession() {
            print("✅ Existing session restored successfully")
            // Don't automatically load passengers on startup to avoid authentication issues
            // Passengers will be loaded when the user navigates to the dashboard
        } else {
            print("ℹ️ No valid session found, user needs to log in")
        }
    }
}
