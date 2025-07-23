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
        lastSyncTime = "Last sync: \(formatter.string(from: Date()))"
    }
    
    private func refreshData() async {
        await routeViewModel.loadPassengers()
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
                                Label("Sync Now", systemImage: "arrow.clockwise")
                            }
                            Button(role: .destructive, action: { authViewModel.logout() }) {
                                Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                            }
                        } label: {
                            Image(systemName: "person.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
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
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingSyncInfo) {
                SyncInfoView()
            }
            .task {
                await routeViewModel.loadPassengers()
            }
            .alert("Error", isPresented: .constant(!routeViewModel.errorMessage.isEmpty)) {
                Button("OK") {
                    routeViewModel.errorMessage = ""
                }
            } message: {
                Text(routeViewModel.errorMessage)
            }
            .overlay(
                Group {
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
                            .zIndex(1)
                            .onTapGesture {
                                withAnimation {
                                    routeViewModel.showStatusNotification = false
                                }
                            }
                    }
                },
                alignment: .top
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    DashboardView()
        .environmentObject(RouteViewModel())
        .environmentObject(AuthViewModel())
}
