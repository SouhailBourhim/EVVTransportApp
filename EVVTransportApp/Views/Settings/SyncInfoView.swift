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
            VStack(spacing: 28) {
                VStack(spacing: 12) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 60))
                        .foregroundColor(Constants.UI.Colors.primaryBlue)
                        .shadow(color: .blue.opacity(0.08), radius: 8, y: 4)
                    Text("Sync Information")
                        .font(.title)
                        .fontWeight(.bold)
                }
                .padding(.top, 12)
                
                VStack(alignment: .leading, spacing: 20) {
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
                .padding(20)
                .background(Color(.systemBackground))
                .cornerRadius(Constants.UI.cardCornerRadius)
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                .padding(.horizontal)
                
                VStack(spacing: 12) {
                    Button(action: {
                        Task {
                            await routeViewModel.forceRefresh()
                        }
                    }) {
                        HStack {
                            if routeViewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            }
                            Text("Force Refresh")
                                .fontWeight(.semibold)
                                .font(.title3)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Constants.UI.Colors.primaryBlue)
                        .foregroundColor(.white)
                        .cornerRadius(Constants.UI.buttonCornerRadius)
                        .shadow(color: .blue.opacity(0.08), radius: 4, y: 2)
                    }
                    .disabled(routeViewModel.isLoading)
                    
                    Button(action: {
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
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(Constants.UI.buttonCornerRadius)
                        .shadow(color: .red.opacity(0.08), radius: 4, y: 2)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.secondary)
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
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
    }
}

#Preview {
    SyncInfoView()
        .environmentObject(RouteViewModel())
        .environmentObject(AuthViewModel())
        .environmentObject(NetworkService.shared)
}
