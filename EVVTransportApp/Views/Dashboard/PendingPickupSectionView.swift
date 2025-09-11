import SwiftUI

// MARK: - Skeleton Components
struct SkeletonView: View {
    @State private var isAnimating = false
    
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Constants.UI.Colors.secondaryBackground,
                        Constants.UI.Colors.secondaryBackground.opacity(0.6),
                        Constants.UI.Colors.secondaryBackground
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .opacity(isAnimating ? 0.3 : 0.8)
            .animation(
                Animation.easeInOut(duration: 1.0)
                    .repeatForever(autoreverses: true),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
            }
    }
}

struct SkeletonPassengerCard: View {
    var body: some View {
        VStack(spacing: 0) {
            // Header skeleton
            HStack(alignment: .top) {
                // Profile placeholder skeleton
                SkeletonView()
                    .frame(width: 44, height: 44)
                    .clipShape(Circle())
                    .padding(.trailing, 12)
                
                // Passenger info skeleton
                VStack(alignment: .leading, spacing: 4) {
                    SkeletonView()
                        .frame(width: 120, height: 20)
                    
                    SkeletonView()
                        .frame(width: 80, height: 16)
                    
                    SkeletonView()
                        .frame(width: 100, height: 16)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            
            // Button skeleton
            SkeletonView()
                .frame(height: 50)
                .padding(.horizontal)
                .padding(.bottom)
        }
        .background(Constants.UI.Colors.background)
        .cornerRadius(12)
        .shadow(color: Constants.UI.Colors.primaryText.opacity(0.05), radius: 2, y: 1)
    }
}

// MARK: - Search Bar
struct SearchBar: View {
    @Binding var text: String
    var placeholder: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Constants.UI.Colors.secondaryText)
                .font(.system(size: 16))
            
            TextField(placeholder, text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .font(.body)
            
            if !text.isEmpty {
                Button(action: {
                    self.text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Constants.UI.Colors.secondaryText)
                        .font(.system(size: 16))
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Constants.UI.Colors.searchBarBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Constants.UI.Colors.searchBarBorder, lineWidth: 1)
        )
    }
}

// MARK: - Stat Badge
struct StatBadge: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption2)
                    .foregroundColor(color)
                
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Constants.UI.Colors.primaryText)
                    .lineLimit(1)
            }
            
            Text(label.uppercased())
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(Constants.UI.Colors.secondaryText)
                .lineLimit(1)
        }
        .padding(8)
        .frame(minWidth: 80)
        .background(Constants.UI.Colors.secondaryBackground)
        .cornerRadius(8)
    }
}

// MARK: - Sort Option View
struct SortOptionView: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? Constants.UI.Colors.buttonText : Constants.UI.Colors.primaryText)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Constants.UI.Colors.primaryBlue : Constants.UI.Colors.searchBarBackground)
                .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48, weight: .light))
                .foregroundColor(color)
                .opacity(0.8)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(Constants.UI.Colors.primaryText)
                
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(Constants.UI.Colors.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Constants.UI.Colors.groupedBackground)
    }
}

// MARK: - Pending Pickup Section View
struct PendingPickupSectionView: View {
    @EnvironmentObject var routeViewModel: RouteViewModel
    @State private var selectedPassenger: Passenger?
    @State private var searchText = ""
    @State private var sortOption: SortOption = .time
    
    enum SortOption: String, CaseIterable, Identifiable {
        case time = "Time"
        case name = "Name"
        case location = "Location"
        
        var id: String { self.rawValue }
    }
    
    private var filteredPassengers: [Passenger] {
        var passengers = routeViewModel.pendingPassengers
        
        // Apply search filter
        if !searchText.isEmpty {
            passengers = passengers.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.pickupLocation.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply sorting
        switch sortOption {
        case .time:
            return passengers.sorted { $0.scheduledPickup < $1.scheduledPickup }
        case .name:
            return passengers.sorted { $0.name < $1.name }
        case .location:
            return passengers.sorted { $0.pickupLocation < $1.pickupLocation }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Divider().frame(height: 4).background(Color(.systemGray5))
            // Search and filter bar
            VStack(spacing: 12) {
                SearchBar(text: $searchText, placeholder: "Search pending pickups...")
                    .padding(.horizontal, 16)
                    .zIndex(1) // Ensure it's on top
                
                // Sort options
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(SortOption.allCases) { option in
                            SortOptionView(
                                title: option.rawValue,
                                isSelected: sortOption == option,
                                action: { sortOption = option }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical, 8)
            .background(Constants.UI.Colors.background)
            
            // Header with count badge
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "clock.fill")
                        .font(.title)
                        .foregroundColor(Constants.UI.Colors.pendingRed)
                    Text("Pending Pickups")
                        .font(Constants.UI.Typography.title)
                        .foregroundColor(Constants.UI.Colors.pendingRed)
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "person.circle")
                        .font(.subheadline)
                        .foregroundColor(.white)
                    Text("\(routeViewModel.pendingPassengers.count)")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(Constants.UI.Colors.pendingRed))
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Constants.UI.Colors.background)
            
            if routeViewModel.isLoading && routeViewModel.pendingPassengers.isEmpty {
                // Show skeleton loading when loading and no data
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(0..<3, id: \.self) { _ in
                            SkeletonPassengerCard()
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            } else if filteredPassengers.isEmpty {
                if routeViewModel.pendingPassengers.isEmpty {
                    EmptyStateView(
                        icon: "checkmark.circle.fill",
                        title: "All Caught Up",
                        message: "No pending pickups at this time.",
                        color: .green
                    )
                } else {
                    EmptyStateView(
                        icon: "magnifyingglass",
                        title: "No Results",
                        message: "No passengers match your search.",
                        color: Constants.UI.Colors.secondaryGray
                    )
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredPassengers) { passenger in
                            PassengerCardView(
                                passenger: passenger,
                                buttonTitle: "Mark as Picked Up",
                                buttonColor: Constants.UI.Colors.pickupGreen,
                                action: {
                                    Task {
                                        await routeViewModel.updatePassengerStatus(passenger, to: .pickedUp)
                                    }
                                },
                                onTap: {
                                    selectedPassenger = passenger
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32) // Extra padding for button visibility
                }
            }
        }
        .frame(maxHeight: .infinity)
        .sheet(item: $selectedPassenger) { passenger in
            PassengerDetailView(passenger: passenger)
        }
    }
}

#Preview("Light Mode") {
    PendingPickupSectionView()
        .environmentObject(RouteViewModel())
}

#Preview("Dark Mode") {
    PendingPickupSectionView()
        .environmentObject(RouteViewModel())
        .preferredColorScheme(.dark)
}
