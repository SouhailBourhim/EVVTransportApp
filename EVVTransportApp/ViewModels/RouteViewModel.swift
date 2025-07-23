import SwiftUI
import Combine
import UserNotifications

@MainActor
class RouteViewModel: ObservableObject {
    @Published var passengers: [Passenger] = []
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var lastSyncTime = Date()
    @Published var showStatusNotification = false
    @Published var statusNotificationMessage = ""
    
    private let networkService = NetworkService.shared
    private let locationService = LocationService.shared
    
    var onBusPassengers: [Passenger] {
        passengers.filter { $0.status == .pickedUp }.limitedTo(Constants.maxPassengers)
    }
    
    var pendingPassengers: [Passenger] {
        passengers.filter { $0.status == .pending }.limitedTo(Constants.maxPassengers)
    }
    
    func loadPassengers() async {
        isLoading = true
        errorMessage = ""
        
        do {
            passengers = try await networkService.fetchPassengers()
            lastSyncTime = Date()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func updatePassengerStatus(_ passenger: Passenger, to newStatus: PassengerStatus) async {
        guard let location = await locationService.getCurrentLocation() else {
            errorMessage = "Unable to get current location. Please enable location services."
            return
        }
        
        isLoading = true
        
        let statusUpdate = StatusUpdate(
            recid: passenger.recid,
            status: newStatus.rawValue,
            datetime: ISO8601DateFormatter().string(from: Date()),
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
        
        do {
            try await networkService.updatePassengerStatus(statusUpdate)
            
            // Update local state
            if let index = passengers.firstIndex(where: { $0.recid == passenger.recid }) {
                passengers[index].status = newStatus
                
                // Show notification for status change
                if newStatus == .pickedUp {
                    statusNotificationMessage = "✓ Successfully picked up \(passenger.name)"
                } else if newStatus == .droppedOff {
                    statusNotificationMessage = "✓ Successfully dropped off \(passenger.name)"
                }
                showStatusNotification = true
                
                // Hide notification after 3 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation {
                        self.showStatusNotification = false
                    }
                }
            }
            
            // Remove passenger if dropped off
            if newStatus == .droppedOff {
                passengers.removeAll { $0.recid == passenger.recid }
            }
            
            lastSyncTime = Date()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func forceRefresh() async {
        await loadPassengers()
    }
}
