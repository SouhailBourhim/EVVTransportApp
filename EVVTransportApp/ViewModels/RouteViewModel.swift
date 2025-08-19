import SwiftUI
import Combine
import UserNotifications

@MainActor
class RouteViewModel: ObservableObject {
    @Published var passengers: [Passenger] = []
    @Published var isLoading = false
    @Published var isSyncing = false
    @Published var errorMessage = ""
    @Published var lastSyncTime = Date()
    @Published var showStatusNotification = false
    @Published var statusNotificationMessage = ""
    @Published var pendingUpdates: [StatusUpdate] = []
    @Published var showErrorAlert = false
    @Published var showSuccessMessage = false
    @Published var successMessage = ""
    @Published var showRetryButton = false
    
    private let networkService = NetworkService.shared
    private let locationService = LocationService.shared
    private let dataService = DataService.shared
    
    // MARK: - Computed Properties
    
    var onBusPassengers: [Passenger] {
        passengers.filter { $0.status == .pickedUp }.limitedTo(Constants.maxPassengers)
    }
    
    var pendingPassengers: [Passenger] {
        passengers.filter { $0.status == .pending }.limitedTo(Constants.maxPassengers)
    }
    
    var hasPendingUpdates: Bool {
        !pendingUpdates.isEmpty
    }
    
    // MARK: - Data Loading
    
    func loadPassengers() async {
        guard let routeId = getCurrentRouteId() else {
            showError("No route assigned. Please log in again.")
            return
        }
        
        // Check network connectivity
        guard networkService.checkNetworkConnectivity() else {
            showError("No internet connection available", showRetry: true)
            return
        }
        
        isLoading = true
        clearError()
        
        do {
            passengers = try await networkService.fetchPassengers(routeId: routeId)
            lastSyncTime = Date()
            dataService.saveLastSyncTime(lastSyncTime)
            
            showSuccess("Loaded \(passengers.count) passengers")
            print("✅ Loaded \(passengers.count) passengers for route: \(routeId)")
            
        } catch let error as NetworkError {
            let showRetry = error.isRetryable
            showError(error.errorDescription ?? Constants.ErrorMessages.networkUnavailable, showRetry: showRetry)
            print("❌ Failed to load passengers: \(error.localizedDescription)")
        } catch {
            showError(error.localizedDescription, showRetry: true)
            print("❌ Unexpected error loading passengers: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Status Updates
    
    func updatePassengerStatus(_ passenger: Passenger, to newStatus: PassengerStatus) async {
        // Validate GPS location before allowing status updates
        let locationValidation = await locationService.getValidatedLocation()
        
        guard case .success(let location) = locationValidation else {
            if case .failure(let error) = locationValidation {
                errorMessage = error.localizedDescription
                print("❌ Location validation failed: \(error.localizedDescription)")
                
                // Provide specific guidance based on error type
                switch error {
                case .permissionDenied:
                    errorMessage = "Location permission is required. Please enable location access in Settings."
                case .locationServicesDisabled:
                    errorMessage = "Location services are disabled. Please enable Location Services in Settings."
                case .accuracyTooLow:
                    errorMessage = "GPS location is not accurate enough. Please wait for better signal or move to an open area."
                case .locationTooOld:
                    errorMessage = "GPS location is too old. Please wait for a fresh reading."
                case .noLocationAvailable:
                    errorMessage = "Unable to get current location. Please check your GPS signal and try again."
                case .invalidCoordinates:
                    errorMessage = "Invalid GPS coordinates. Please try again."
                case .timeout:
                    errorMessage = "Location request timed out. Please check your GPS signal and try again."
                }
            } else {
                errorMessage = Constants.ErrorMessages.locationRequired
            }
            return
        }
        
        // Store original passenger state for rollback
        let originalPassenger = passenger
        let originalPassengers = passengers
        
        // Optimistic UI update - immediately show the change
        if let index = passengers.firstIndex(where: { $0.recid == passenger.recid }) {
            passengers[index].status = newStatus
        }
        
        // Show immediate feedback
        showStatusChangeNotification(passenger: passenger, newStatus: newStatus)
        
        // Remove passenger if dropped off (optimistic)
        if newStatus == .droppedOff {
            passengers.removeAll { $0.recid == passenger.recid }
        }
        
        let statusUpdate = StatusUpdate(
            recid: passenger.recid,
            status: newStatus.rawValue,
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            driverId: dataService.getCurrentSessionId(),
            routeId: getCurrentRouteId()
        )
        
        do {
            let success = try await networkService.updatePassengerStatus(statusUpdate)
            
            if success {
                // Update last sync time
                lastSyncTime = Date()
                dataService.saveLastSyncTime(lastSyncTime)
                
                // Trigger auto-sync to ensure UI is in sync with backend
                await autoSyncAfterStatusUpdate()
                
                print("✅ Status update successful for \(passenger.name): \(newStatus.rawValue)")
            } else {
                // Rollback optimistic update on failure
                passengers = originalPassengers
                errorMessage = "Failed to update passenger status. Please try again."
                print("❌ Status update failed for passenger \(passenger.name)")
                
                // Show rollback notification
                statusNotificationMessage = "❌ Update failed - reverted changes"
                showStatusNotification = true
            }
            
        } catch let error as NetworkError {
            // Rollback optimistic update on error
            passengers = originalPassengers
            errorMessage = error.errorDescription ?? "Failed to update passenger status"
            print("❌ Status update failed: \(error.localizedDescription)")
            
            // Show rollback notification
            statusNotificationMessage = "❌ Update failed - reverted changes"
            showStatusNotification = true
            
            // Queue for retry if it's a network error
            if case .networkFailure = error {
                queueStatusUpdate(statusUpdate)
            }
        } catch {
            // Rollback optimistic update on error
            passengers = originalPassengers
            errorMessage = error.localizedDescription
            print("❌ Unexpected error in status update: \(error)")
            
            // Show rollback notification
            statusNotificationMessage = "❌ Update failed - reverted changes"
            showStatusNotification = true
        }
    }
    
    // MARK: - Force Refresh
    
    func forceRefresh() async {
        guard let routeId = getCurrentRouteId() else {
            errorMessage = "No route assigned. Please log in again."
            return
        }
        
        // Set loading state and clear previous errors
        isSyncing = true
        errorMessage = ""
        showStatusNotification = false
        
        do {
            // Perform force refresh with retry logic
            passengers = try await networkService.refreshPassengerData(routeId: routeId)
            
            // Update sync timestamp
            lastSyncTime = Date()
            dataService.saveLastSyncTime(lastSyncTime)
            
            // Show success notification
            statusNotificationMessage = "✓ Data refreshed successfully (\(passengers.count) passengers)"
            showStatusNotification = true
            
            print("✅ Force refresh completed. Loaded \(passengers.count) passengers")
            
            // Hide success notification after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    self.showStatusNotification = false
                }
            }
            
        } catch let error as NetworkError {
            errorMessage = error.errorDescription ?? Constants.ErrorMessages.syncFailed
            print("❌ Force refresh failed: \(error.localizedDescription)")
            
            // Show error notification
            statusNotificationMessage = "❌ Refresh failed: \(error.errorDescription ?? "Unknown error")"
            showStatusNotification = true
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Unexpected error in force refresh: \(error)")
            
            // Show error notification
            statusNotificationMessage = "❌ Refresh failed: \(error.localizedDescription)"
            showStatusNotification = true
        }
        
        isSyncing = false
    }
    
    // MARK: - Offline Support
    
    func queueStatusUpdate(_ update: StatusUpdate) {
        pendingUpdates.append(update)
        print("📝 Queued status update for passenger \(update.recid)")
    }
    
    func syncPendingUpdates() async {
        guard !pendingUpdates.isEmpty else { return }
        
        print("🔄 Syncing \(pendingUpdates.count) pending updates...")
        
        let updatesToProcess = pendingUpdates
        pendingUpdates.removeAll()
        
        for update in updatesToProcess {
            do {
                let success = try await networkService.updatePassengerStatus(update)
                if success {
                    print("✅ Synced pending update for passenger \(update.recid)")
                } else {
                    // Re-queue failed updates
                    pendingUpdates.append(update)
                }
            } catch {
                print("❌ Failed to sync pending update: \(error.localizedDescription)")
                // Re-queue failed updates
                pendingUpdates.append(update)
            }
        }
        
        if !pendingUpdates.isEmpty {
            print("⚠️ \(pendingUpdates.count) updates still pending")
        }
    }
    
    // MARK: - Private Helper Methods
    
    private func getCurrentRouteId() -> String? {
        return dataService.getCurrentRouteId()
    }
    
    private func showStatusChangeNotification(passenger: Passenger, newStatus: PassengerStatus) {
        switch newStatus {
        case .pickedUp:
            statusNotificationMessage = "✓ Successfully picked up \(passenger.name)"
        case .droppedOff:
            statusNotificationMessage = "✓ Successfully dropped off \(passenger.name)"
        case .pending:
            statusNotificationMessage = "✓ Status updated for \(passenger.name)"
        }
        
        showStatusNotification = true
        
        // Hide notification after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                self.showStatusNotification = false
            }
        }
    }
    
    private func autoSyncAfterStatusUpdate() async {
        // Re-fetch passenger data to ensure UI is in sync with backend
        do {
            guard let routeId = getCurrentRouteId() else { 
                print("⚠️ No route ID available for auto-sync")
                return 
            }
            
            print("🔄 Starting auto-sync after status update...")
            
            // Fetch fresh data from backend
            let updatedPassengers = try await networkService.fetchPassengers(routeId: routeId)
            
            // Update passengers list with fresh data
            passengers = updatedPassengers
            
            // Update sync timestamp
            lastSyncTime = Date()
            dataService.saveLastSyncTime(lastSyncTime)
            
            print("✅ Auto-sync completed after status update. Updated \(updatedPassengers.count) passengers")
            
        } catch let error as NetworkError {
            print("⚠️ Auto-sync failed after status update: \(error.localizedDescription)")
            // Don't show error to user for auto-sync failures, just log them
        } catch {
            print("⚠️ Unexpected error in auto-sync: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Location Management
    
    func requestLocationPermission() {
        locationService.requestLocationPermission()
    }
    
    func openLocationSettings() {
        locationService.openLocationSettings()
    }
    
    func checkLocationAvailability() -> Bool {
        return locationService.checkLocationAvailability()
    }
    
    func getLocationErrorDescription() -> String {
        return locationService.getLocationErrorDescription()
    }
    
    func getLocationErrorRecoverySuggestion() -> String {
        return locationService.getLocationErrorRecoverySuggestion()
    }
    
    // MARK: - Error and Success Handling
    
    private func showError(_ message: String, showRetry: Bool = false) {
        errorMessage = message
        showErrorAlert = true
        showRetryButton = showRetry
        print("❌ Route error: \(message)")
    }
    
    private func showSuccess(_ message: String) {
        successMessage = message
        showSuccessMessage = true
        print("✅ Route success: \(message)")
        
        // Hide success message after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                self.showSuccessMessage = false
            }
        }
    }
    
    func clearError() {
        errorMessage = ""
        showErrorAlert = false
        showRetryButton = false
    }
    
    func retryLastOperation() async {
        // Retry the last failed operation
        await loadPassengers()
    }
    
    func getTimeSinceLastSync() -> TimeInterval {
        return Date().timeIntervalSince(lastSyncTime)
    }
    
    func formatLastSyncTime() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .short
        return formatter.string(from: lastSyncTime)
    }
}
