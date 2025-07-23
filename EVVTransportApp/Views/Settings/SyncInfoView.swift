// SyncInfoView placeholder 
import SwiftUI

struct SyncInfoView: View {
    @EnvironmentObject var routeViewModel: RouteViewModel
    @Environment(\.dismiss) private var dismiss
    
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
                    InfoItem(title: "Last Synced", value: DateFormatter.syncFormatter.string(from: routeViewModel.lastSyncTime), icon: "clock")
                    InfoItem(title: "Total Passengers", value: "\(routeViewModel.passengers.count)", icon: "person.3")
                    InfoItem(title: "On Bus", value: "\(routeViewModel.onBusPassengers.count)", icon: "figure.walk")
                    InfoItem(title: "Pending Pickup", value: "\(routeViewModel.pendingPassengers.count)", icon: "clock.badge")
                }
                .padding(20)
                .background(Color(.systemBackground))
                .cornerRadius(Constants.UI.cardCornerRadius)
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                .padding(.horizontal)
                
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
    }
}

struct InfoItem: View {
    let title: String
    let value: String
    let icon: String
    
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
            }
            
            Spacer()
        }
    }
}

#Preview {
    SyncInfoView()
        .environmentObject(RouteViewModel())
}
