import SwiftUI

// MARK: - Search Bar
struct SearchBar: View {
    @Binding var text: String
    var placeholder: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
                .font(.system(size: 16))
            
            TextField(placeholder, text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .font(.body)
            
            if !text.isEmpty {
                Button(action: {
                    self.text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.system(size: 16))
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray4), lineWidth: 1)
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
                    .foregroundColor(.primary)
                    .lineLimit(1)
            }
            
            Text(label.uppercased())
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .padding(8)
        .frame(minWidth: 80)
        .background(Color(.secondarySystemBackground))
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
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color(.systemGray5))
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
                    .foregroundColor(.primary)
                
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
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
            .background(Color(.systemBackground))
            
            // Header with count badge
            HStack {
                Text("Pending Pickups")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.subheadline)
                        .foregroundColor(.orange)
                    Text("\(routeViewModel.pendingPassengers.count)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color.orange))
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(.systemBackground))
            
            if filteredPassengers.isEmpty {
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
                        color: .gray
                    )
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredPassengers) { passenger in
                            PassengerCardView(
                                passenger: passenger,
                                buttonTitle: "Mark as Picked Up",
                                buttonColor: .blue,
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
                    .padding(.horizontal)
                    .padding(.bottom, 24) // Extra padding for button visibility
                }
            }
        }
        .frame(maxHeight: .infinity)
        .sheet(item: $selectedPassenger) { passenger in
            PassengerDetailView(passenger: passenger)
        }
    }
}

#Preview {
    PendingPickupSectionView()
        .environmentObject(RouteViewModel())
}
