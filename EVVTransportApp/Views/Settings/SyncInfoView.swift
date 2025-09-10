// SyncInfoView placeholder 
import SwiftUI

struct SyncInfoView: View {
    @EnvironmentObject var routeViewModel: RouteViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var networkService: NetworkService
    @Environment(\.dismiss) private var dismiss
    @State private var showingLogoutConfirmation = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Header - more compact
                    VStack(spacing: 8) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 40))
                            .foregroundColor(Constants.UI.Colors.primaryBlue)
                        Text("Sync Information")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .padding(.top, 8)
                    
                    // Info items - more compact
                    VStack(alignment: .leading, spacing: 12) {
                        InfoItem(title: "App Version", value: Constants.appVersion, icon: "app.badge")
                        
                        InfoItem(
                            title: "Last Synced", 
                            value: routeViewModel.formatLastSyncTime(), 
                            icon: "clock",
                            subtitle: routeViewModel.getTimeSinceLastSync() < 60 ? "Just now" : "\(Int(routeViewModel.getTimeSinceLastSync() / 60)) minutes ago"
                        )
                        
                        InfoItem(
                            title: "Connection Status", 
                            value: networkService.isNetworkAvailable ? "Connected" : "Offline", 
                            icon: networkService.isNetworkAvailable ? "wifi" : "wifi.slash",
                            valueColor: networkService.isNetworkAvailable ? .green : .red
                        )
                        
                        InfoItem(title: "Total Passengers", value: "\(routeViewModel.passengers.count)", icon: "person.3")
                        InfoItem(title: "On Bus", value: "\(routeViewModel.onBusPassengers.count)", icon: "figure.walk")
                        InfoItem(title: "Pending Pickup", value: "\(routeViewModel.pendingPassengers.count)", icon: "clock.badge")
                        
                        if let user = authViewModel.currentUser {
                            InfoItem(title: "Driver", value: user.driverName ?? user.username, icon: "person.circle")
                            InfoItem(title: "Route ID", value: user.routeId, icon: "map")
                        }
                    }
                .padding(16)
                .background(Constants.UI.Colors.cardBackground)
                .cornerRadius(Constants.UI.cardCornerRadius)
                .shadow(color: Constants.UI.Colors.primaryText.opacity(0.08), radius: 8, x: 0, y: 4)
                    .padding(.horizontal)
                    
                    // Action buttons - fixed at bottom
                    VStack(spacing: 12) {
                        Button(action: {
                            // Add haptic feedback
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                            
                            Task {
                                await routeViewModel.forceRefresh()
                            }
                        }) {
                            HStack {
                                if routeViewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: Constants.UI.Colors.buttonText))
                                        .scaleEffect(0.8)
                                }
                                Text("Force Refresh")
                                    .fontWeight(.semibold)
                                    .font(.title3)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                        .background(Constants.UI.Colors.buttonBackground)
                        .foregroundColor(Constants.UI.Colors.buttonText)
                            .cornerRadius(Constants.UI.buttonCornerRadius)
                            .shadow(color: Constants.UI.Colors.primaryBlue.opacity(0.08), radius: 4, y: 2)
                        }
                        .disabled(routeViewModel.isLoading)
                        
                        Button(action: {
                            // Add haptic feedback
                            let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
                            impactFeedback.impactOccurred()
                            
                            showingLogoutConfirmation = true
                        }) {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("Sign Out")
                                    .fontWeight(.semibold)
                                    .font(.title3)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                        .background(Constants.UI.Colors.destructiveButtonBackground)
                        .foregroundColor(Constants.UI.Colors.destructiveButtonText)
                            .cornerRadius(Constants.UI.buttonCornerRadius)
                            .shadow(color: .red.opacity(0.08), radius: 4, y: 2)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20) // Extra padding at bottom for safe area
                }
            }
            .background(Constants.UI.Colors.groupedBackground.ignoresSafeArea())
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { 
                        // Add haptic feedback
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                        
                        dismiss() 
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(Constants.UI.Colors.secondaryText)
                    }
                    .accessibilityLabel("Close")
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .alert("Sign Out", isPresented: $showingLogoutConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                authViewModel.logout()
                dismiss()
            }
        } message: {
            Text("Are you sure you want to sign out? This will clear all your session data and return you to the login screen.")
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
            // Success notification overlay
            Group {
                if routeViewModel.showStatusNotification {
                    VStack {
                        Spacer()
                        HStack {
                            Text(routeViewModel.statusNotificationMessage)
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(Constants.UI.Colors.destructiveButtonText)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color.green)
                                .cornerRadius(8)
                                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100) // Position above the buttons
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .animation(.easeInOut(duration: 0.3), value: routeViewModel.showStatusNotification)
                    }
                }
            }
        )
    }
}

struct InfoItem: View {
    let title: String
    let value: String
    let icon: String
    let subtitle: String?
    let valueColor: Color?
    
    init(title: String, value: String, icon: String, subtitle: String? = nil, valueColor: Color? = nil) {
        self.title = title
        self.value = value
        self.icon = icon
        self.subtitle = subtitle
        self.valueColor = valueColor
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(Constants.UI.Colors.primaryBlue)
                .font(.title3)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                Text(value)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(valueColor)
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundColor(Constants.UI.Colors.secondaryText)
                }
            }
            
            Spacer()
        }
    }
}

#Preview("Light Mode") {
    SyncInfoView()
        .environmentObject(RouteViewModel())
        .environmentObject(AuthViewModel())
        .environmentObject(NetworkService.shared)
}

#Preview("Dark Mode") {
    SyncInfoView()
        .environmentObject(RouteViewModel())
        .environmentObject(AuthViewModel())
        .environmentObject(NetworkService.shared)
        .preferredColorScheme(.dark)
}
