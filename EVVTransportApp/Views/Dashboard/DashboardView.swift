import SwiftUI

// MARK: - Dashboard View

struct DashboardView: View {
    @EnvironmentObject var routeViewModel: RouteViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
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
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                Color(.systemGroupedBackground)
                    .edgesIgnoringSafeArea(.all)
                
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
                                    .foregroundColor(.secondary)
                            }
                        }
                        Spacer()
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
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding([.horizontal, .top])
                    .padding(.bottom, 8)
                    .background(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.05), radius: 5, y: 2)

                    GeometryReader { geometry in
                        VStack(spacing: 0) {
                            // On the Bus (Top Half)
                            VStack(spacing: 0) {
                                OnBusSectionView()
                            }
                            .frame(height: geometry.size.height / 2)
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 0))
                            .shadow(color: Color.black.opacity(0.03), radius: 2, y: 1)

                            Divider()

                            // To Be Picked Up (Bottom Half)
                            VStack(spacing: 0) {
                                PendingPickupSectionView()
                            }
                            .frame(height: geometry.size.height / 2)
                            .background(Color(.systemBackground))
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
                            .background(Color.green.opacity(0.9))
                            .foregroundColor(.white)
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
                            .background(Color.blue.opacity(0.9))
                            .foregroundColor(.white)
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
    }
}

#Preview {
    DashboardView()
        .environmentObject(RouteViewModel())
        .environmentObject(AuthViewModel())
}
