import SwiftUI

struct OnBusSectionView: View {
    @EnvironmentObject var routeViewModel: RouteViewModel
    @State private var selectedPassenger: Passenger?
    @State private var searchText = ""
    
    private var filteredPassengers: [Passenger] {
        if searchText.isEmpty {
            return routeViewModel.onBusPassengers
        } else {
            return routeViewModel.onBusPassengers.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.dropoffLocation.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search bar - always visible
            SearchBar(text: $searchText, placeholder: "Search passengers...")
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Constants.UI.Colors.background)
                .zIndex(1) // Ensure it's on top
            
            // Header with count badge
            HStack {
                Text("On the Bus")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "person.2.fill")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    Text("\(routeViewModel.onBusPassengers.count)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color.blue))
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Constants.UI.Colors.background)
            
            Divider().frame(height: 2).background(Constants.UI.Colors.separator)
            
            // Content area - always show search functionality
            if routeViewModel.onBusPassengers.isEmpty {
                VStack {
                    Spacer()
                    Image(systemName: "bus")
                        .font(.system(size: 50))
                        .foregroundColor(Constants.UI.Colors.secondaryText)
                    Text("No passengers on bus")
                        .foregroundColor(Constants.UI.Colors.secondaryText)
                        .font(.title3)
                    if routeViewModel.pendingPassengers.isEmpty {
                        Text("All passengers have been processed")
                            .foregroundColor(Constants.UI.Colors.tertiaryText)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredPassengers) { passenger in
                            PassengerCardView(
                                passenger: passenger,
                                buttonTitle: "Mark as Dropped Off",
                                buttonColor: .green,
                                action: {
                                    Task {
                                        await routeViewModel.updatePassengerStatus(passenger, to: .droppedOff)
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
            Divider().frame(height: 4).background(Constants.UI.Colors.separator)
        }
        .frame(maxHeight: .infinity)
        .sheet(item: $selectedPassenger) { passenger in
            PassengerDetailView(passenger: passenger)
        }
    }
}

#Preview {
    OnBusSectionView()
        .environmentObject(RouteViewModel())
}
