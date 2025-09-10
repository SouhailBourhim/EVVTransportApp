import SwiftUI

// MARK: - Offline Banner
struct OfflineBanner: View {
    @EnvironmentObject var networkMonitor: NetworkMonitor
    
    var body: some View {
        if !networkMonitor.isConnected {
            HStack(spacing: 12) {
                Image(systemName: "wifi.slash")
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .medium))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("No Internet Connection")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text("Check your network settings and try again")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                Button(action: {
                    // Dismiss the banner
                    withAnimation(.easeInOut(duration: 0.3)) {
                        networkMonitor.showOfflineNotification = false
                    }
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                        .font(.system(size: 14, weight: .medium))
                        .padding(4)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.red, Color.red.opacity(0.8)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(8)
            .shadow(color: .red.opacity(0.3), radius: 4, x: 0, y: 2)
            .transition(.move(edge: .top).combined(with: .opacity))
            .animation(.easeInOut(duration: 0.3), value: networkMonitor.isConnected)
        }
    }
}

// MARK: - Reconnected Notification
struct ReconnectedNotification: View {
    @EnvironmentObject var networkMonitor: NetworkMonitor
    
    var body: some View {
        if networkMonitor.showReconnectedNotification {
            HStack(spacing: 12) {
                Image(systemName: "wifi")
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .medium))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Connection Restored")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text("Connected via \(networkMonitor.getConnectionTypeDescription())")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .medium))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.green, Color.green.opacity(0.8)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(8)
            .shadow(color: .green.opacity(0.3), radius: 4, x: 0, y: 2)
            .transition(.move(edge: .top).combined(with: .opacity))
            .animation(.easeInOut(duration: 0.3), value: networkMonitor.showReconnectedNotification)
        }
    }
}

// MARK: - Toast Notification
struct ToastNotification: View {
    let message: String
    let type: ToastType
    @Binding var isShowing: Bool
    
    enum ToastType {
        case success
        case error
        case warning
        case info
        
        var color: Color {
            switch self {
            case .success: return .green
            case .error: return .red
            case .warning: return .orange
            case .info: return .blue
            }
        }
        
        var icon: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .error: return "xmark.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .info: return "info.circle.fill"
            }
        }
    }
    
    var body: some View {
        if isShowing {
            HStack(spacing: 12) {
                Image(systemName: type.icon)
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .medium))
                
                Text(message)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isShowing = false
                    }
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                        .font(.system(size: 14, weight: .medium))
                        .padding(4)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [type.color, type.color.opacity(0.8)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(8)
            .shadow(color: type.color.opacity(0.3), radius: 4, x: 0, y: 2)
            .transition(.move(edge: .top).combined(with: .opacity))
            .animation(.easeInOut(duration: 0.3), value: isShowing)
        }
    }
}

// MARK: - Dashboard View

struct DashboardView: View {
    @EnvironmentObject var routeViewModel: RouteViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @State private var showingSyncInfo = false
    @State private var lastSyncTime: String = ""
    
    
    private func updateLastSyncTime() {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        lastSyncTime = "Last sync: \(formatter.string(from: routeViewModel.lastSyncTime))"
    }
    
    private func refreshData() async {
        await routeViewModel.forceRefresh()
        updateLastSyncTime()
    }
    
    private func openAllPassengersInMaps() {
        openMapsWithPassengers(routeViewModel.passengers, title: "All Passengers")
    }
    
    private func openPendingPassengersInMaps() {
        openMapsWithPassengers(routeViewModel.pendingPassengers, title: "Pending Pickups")
    }
    
    private func openOnBusPassengersInMaps() {
        openMapsWithPassengers(routeViewModel.onBusPassengers, title: "On Bus Passengers")
    }
    
    private func openMapsWithPassengers(_ passengers: [Passenger], title: String) {
        // Get all unique addresses from passengers
        let addresses = Set(passengers.map { $0.address })
        
        if addresses.isEmpty {
            print("❌ No passenger addresses available for navigation")
            return
        }
        
        // Create a query string with all addresses
        let addressQuery = addresses.joined(separator: " ")
        
        // Create Apple Maps URL
        let encodedQuery = addressQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let mapsURL = "https://maps.apple.com/?q=\(encodedQuery)"
        
        if let url = URL(string: mapsURL) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
                print("🗺️ Opened Apple Maps with \(addresses.count) \(title.lowercased()) locations")
            } else {
                print("❌ Cannot open Apple Maps")
            }
        } else {
            print("❌ Invalid maps URL")
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                // Simple background with subtle gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Constants.UI.Colors.primaryBackground,
                        Constants.UI.Colors.secondaryBackgroundEnhanced
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea(.container, edges: [.leading, .trailing, .bottom])
                
                // Network status notifications
                VStack(spacing: 8) {
                    OfflineBanner()
                    ReconnectedNotification()
                    
                    // Test button for offline functionality (remove in production)
                    #if DEBUG
                    HStack(spacing: 8) {
                        Button(action: {
                            networkMonitor.simulateOffline()
                        }) {
                            Text("Test Offline")
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.red)
                                .cornerRadius(8)
                        }
                        
                        Button(action: {
                            networkMonitor.simulateOnline()
                        }) {
                            Text("Test Online")
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.green)
                                .cornerRadius(8)
                        }
                    }
                    .padding(.top, 4)
                    #endif
                    
                    Spacer()
                }
                .padding(.top, 0)
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Route Dashboard")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            if !lastSyncTime.isEmpty {
                                Text(lastSyncTime)
                                    .font(.caption)
                                    .foregroundColor(Constants.UI.Colors.secondaryText)
                            }
                        }
                        Spacer()
                        
                        // Map/Navigation button
                        Menu {
                            Button(action: {
                                openAllPassengersInMaps()
                            }) {
                                Label("View All Locations", systemImage: "map")
                            }
                            .disabled(routeViewModel.passengers.isEmpty)
                            
                            if !routeViewModel.pendingPassengers.isEmpty {
                                Button(action: {
                                    openPendingPassengersInMaps()
                                }) {
                                    Label("Pending Pickups (\(routeViewModel.pendingPassengers.count))", systemImage: "location.circle")
                                }
                            }
                            
                            if !routeViewModel.onBusPassengers.isEmpty {
                                Button(action: {
                                    openOnBusPassengersInMaps()
                                }) {
                                    Label("On Bus (\(routeViewModel.onBusPassengers.count))", systemImage: "bus")
                                }
                            }
                        } label: {
                            Image(systemName: "map.fill")
                                .font(.title2)
                                .foregroundColor(Constants.UI.Colors.primaryBlue)
                        }
                        .disabled(routeViewModel.passengers.isEmpty)
                        
                        // Profile button
                        Menu {
                            Button(action: { showingSyncInfo = true }) {
                                Label("Sync Info", systemImage: "info.circle")
                            }
                            Button(action: { Task { await refreshData() } }) {
                                Label("Force Refresh", systemImage: "arrow.clockwise")
                            }
                            .disabled(routeViewModel.isSyncing)
                            Button(role: .destructive, action: { authViewModel.logout() }) {
                                Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                            }
                        } label: {
                            HStack(spacing: 4) {
                                if routeViewModel.isSyncing {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                }
                                Image(systemName: "person.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(Constants.UI.Colors.primaryBlue)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 1) // Minimal top padding to respect status bar
                    .padding(.bottom, 8)
                    .background(Constants.UI.Colors.cardBackgroundEnhanced)
                    .shadow(color: Constants.UI.Colors.primaryText.opacity(0.08), radius: 8, y: 4)

                    GeometryReader { geometry in
                        VStack(spacing: 0) {
                            // On the Bus (Top Half)
                            VStack(spacing: 0) {
                                OnBusSectionView()
                            }
                            .frame(height: geometry.size.height / 2)
                            .background(Constants.UI.Colors.cardBackgroundEnhanced)
                            .clipShape(RoundedRectangle(cornerRadius: 0))
                            .shadow(color: Constants.UI.Colors.primaryText.opacity(0.06), radius: 4, y: 2)

                            Divider()

                            // To Be Picked Up (Bottom Half)
                            VStack(spacing: 0) {
                                PendingPickupSectionView()
                            }
                            .frame(height: geometry.size.height / 2)
                            .background(Constants.UI.Colors.cardBackgroundEnhanced)
                            .clipShape(RoundedRectangle(cornerRadius: 0))
                        }
                        .frame(height: geometry.size.height)
                    }
                    .clipped() // Ensure content doesn't overflow
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingSyncInfo) {
                SyncInfoView()
            }
            .task {
                await routeViewModel.loadPassengers()
            }
            .alert("Error", isPresented: $routeViewModel.showErrorAlert) {
                Button("OK") {
                    routeViewModel.clearError()
                }
                if routeViewModel.showRetryButton {
                    Button("Retry") {
                        Task {
                            await routeViewModel.retryLastOperation()
                        }
                    }
                }
            } message: {
                Text(routeViewModel.errorMessage)
            }
            .overlay(
                VStack {
                    if routeViewModel.showStatusNotification {
                        Text(routeViewModel.statusNotificationMessage)
                            .padding()
                            .background(Constants.UI.Colors.successGreen.opacity(0.9))
                            .foregroundColor(Constants.UI.Colors.buttonText)
                            .cornerRadius(10)
                            .shadow(radius: 10)
                            .transition(.move(edge: .top).combined(with: .opacity))
                            .animation(.easeInOut, value: routeViewModel.showStatusNotification)
                            .padding(.top, 44)
                            .onTapGesture {
                                withAnimation {
                                    routeViewModel.showStatusNotification = false
                                }
                            }
                    }
                    
                    if routeViewModel.showSuccessMessage {
                        Text(routeViewModel.successMessage)
                            .padding()
                            .background(Constants.UI.Colors.primaryBlue.opacity(0.9))
                            .foregroundColor(Constants.UI.Colors.buttonText)
                            .cornerRadius(10)
                            .shadow(radius: 10)
                            .transition(.move(edge: .top).combined(with: .opacity))
                            .animation(.easeInOut, value: routeViewModel.showSuccessMessage)
                            .padding(.top, 44)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .top),
                alignment: .top
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .statusBarHidden(false)
    }
}

// MARK: - Preview
#Preview("Light Mode") {
    let routeViewModel = RouteViewModel()
    // Add mock data for preview
    let mockPassengers = [
        Passenger(
            recid: "1",
            name: "Sarah Johnson",
            address: "123 Oak Street, Springfield, IL 62701",
            status: .pickedUp,
            contactInfo: "(555) 123-4567",
            gender: 2,
            city: "Springfield"
        ),
        Passenger(
            recid: "2", 
            name: "Michael Chen",
            address: "456 Pine Avenue, Springfield, IL 62701",
            status: .pickedUp,
            contactInfo: "(555) 234-5678",
            gender: 1,
            city: "Springfield"
        ),
        Passenger(
            recid: "3",
            name: "Emily Rodriguez",
            address: "789 Maple Drive, Springfield, IL 62701",
            status: .pending,
            contactInfo: "(555) 345-6789",
            gender: 2,
            city: "Springfield"
        ),
        Passenger(
            recid: "4",
            name: "David Thompson",
            address: "321 Elm Street, Springfield, IL 62701", 
            status: .pending,
            contactInfo: "(555) 456-7890",
            gender: 1,
            city: "Springfield"
        ),
        Passenger(
            recid: "5",
            name: "Lisa Anderson",
            address: "654 Cedar Lane, Springfield, IL 62701",
            status: .pending,
            contactInfo: "(555) 567-8901",
            gender: 2,
            city: "Springfield"
        )
    ]
    
    // Set mock data
    routeViewModel.passengers = mockPassengers
    
    return DashboardView()
        .environmentObject(AuthViewModel())
        .environmentObject(routeViewModel)
        .environmentObject(NetworkService.shared)
        .environmentObject(NetworkMonitor())
}

#Preview("Dark Mode") {
    let routeViewModel = RouteViewModel()
    let mockPassengers = [
        Passenger(
            recid: "1",
            name: "Sarah Johnson",
            address: "123 Oak Street, Springfield, IL 62701",
            status: .pickedUp,
            contactInfo: "(555) 123-4567",
            gender: 2,
            city: "Springfield"
        ),
        Passenger(
            recid: "2", 
            name: "Michael Chen",
            address: "456 Pine Avenue, Springfield, IL 62701",
            status: .pickedUp,
            contactInfo: "(555) 234-5678",
            gender: 1,
            city: "Springfield"
        ),
        Passenger(
            recid: "3",
            name: "Emily Rodriguez",
            address: "789 Maple Drive, Springfield, IL 62701",
            status: .pending,
            contactInfo: "(555) 345-6789",
            gender: 2,
            city: "Springfield"
        ),
        Passenger(
            recid: "4",
            name: "David Thompson",
            address: "321 Elm Street, Springfield, IL 62701", 
            status: .pending,
            contactInfo: "(555) 456-7890",
            gender: 1,
            city: "Springfield"
        ),
        Passenger(
            recid: "5",
            name: "Lisa Anderson",
            address: "654 Cedar Lane, Springfield, IL 62701",
            status: .pending,
            contactInfo: "(555) 567-8901",
            gender: 2,
            city: "Springfield"
        )
    ]
    
    // Set mock data
    routeViewModel.passengers = mockPassengers
    
    return DashboardView()
        .environmentObject(AuthViewModel())
        .environmentObject(routeViewModel)
        .environmentObject(NetworkService.shared)
        .environmentObject(NetworkMonitor())
        .preferredColorScheme(.dark)
}
