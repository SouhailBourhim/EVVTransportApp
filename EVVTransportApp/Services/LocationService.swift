import CoreLocation
import SwiftUI

@MainActor
class LocationService: NSObject, ObservableObject {
    static let shared = LocationService()
    
    private let locationManager = CLLocationManager()
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var currentLocation: CLLocation?
    @Published var locationAvailable = false
    @Published var locationError: LocationError?
    
    private var locationContinuation: CheckedContinuation<CLLocation?, Never>?
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = Constants.Location.locationAccuracy
        locationManager.requestWhenInUseAuthorization()
    }
    
    // MARK: - Location Permission Management
    
    func requestLocationPermission() {
        switch authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            print("❌ Location permission denied")
            locationError = .permissionDenied
            locationAvailable = false
        case .authorizedWhenInUse, .authorizedAlways:
            print("✅ Location permission granted")
            locationManager.requestLocation()
        @unknown default:
            break
        }
    }
    
    func openLocationSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
    
    // MARK: - Location Availability Checking
    
    func checkLocationAvailability() -> Bool {
        // Check if we have permission (this is safe to call on main thread)
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            locationError = .permissionDenied
            locationAvailable = false
            return false
        }
        
        // Check if location services are enabled (use authorizationStatus as proxy)
        guard authorizationStatus != .denied && authorizationStatus != .restricted else {
            locationError = .locationServicesDisabled
            locationAvailable = false
            return false
        }
        
        // Check if we have a recent location
        guard let location = currentLocation else {
            locationError = .noLocationAvailable
            locationAvailable = false
            return false
        }
        
        // Check if location is recent enough
        let maxAge = Constants.Location.maxLocationAge
        if Date().timeIntervalSince(location.timestamp) > maxAge {
            locationError = .locationTooOld
            locationAvailable = false
            return false
        }
        
        // Check if location accuracy is sufficient
        if location.horizontalAccuracy > Constants.Location.locationAccuracy {
            locationError = .accuracyTooLow
            locationAvailable = false
            return false
        }
        
        // All checks passed
        locationError = nil
        locationAvailable = true
        return true
    }
    
    // MARK: - GPS Validation
    
    func validateLocationForStatusUpdate() -> LocationValidationResult {
        // Check if we have permission (this is safe to call on main thread)
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            return .failure(.permissionDenied)
        }
        
        // Check if location services are enabled (use authorizationStatus as proxy)
        guard authorizationStatus != .denied && authorizationStatus != .restricted else {
            return .failure(.locationServicesDisabled)
        }
        
        // Check if we have a current location
        guard let location = currentLocation else {
            return .failure(.noLocationAvailable)
        }
        
        // Check if location is recent enough
        let maxAge = Constants.Location.maxLocationAge
        if Date().timeIntervalSince(location.timestamp) > maxAge {
            return .failure(.locationTooOld)
        }
        
        // Check if location accuracy is sufficient
        if location.horizontalAccuracy > Constants.Location.locationAccuracy {
            return .failure(.accuracyTooLow)
        }
        
        // Validate coordinates are within reasonable bounds
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        guard latitude >= -90 && latitude <= 90 else {
            return .failure(.invalidCoordinates)
        }
        
        guard longitude >= -180 && longitude <= 180 else {
            return .failure(.invalidCoordinates)
        }
        
        return .success(location)
    }
    
    // MARK: - Location Retrieval
    
    func getCurrentLocation() async -> CLLocation? {
        // First check if location is available
        guard checkLocationAvailability() else {
            print("❌ Location not available: \(locationError?.localizedDescription ?? "Unknown error")")
            return nil
        }
        
        return await withCheckedContinuation { continuation in
            self.locationContinuation = continuation
            
            // Request location update
            self.locationManager.requestLocation()
            
            // Set timeout to prevent hanging
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 10_000_000_000) // 10 seconds
                
                if let cont = self.locationContinuation {
                    self.locationContinuation = nil
                    print("⚠️ Location timeout")
                    cont.resume(returning: nil)
                }
            }
        }
    }
    
    func getValidatedLocation() async -> LocationValidationResult {
        // Try to get current location first
        guard await getCurrentLocation() != nil else {
            return .failure(.noLocationAvailable)
        }
        
        // Validate the location
        return validateLocationForStatusUpdate()
    }
    
    private func completeLocationRequest(with location: CLLocation?) {
        if let continuation = locationContinuation {
            locationContinuation = nil
            continuation.resume(returning: location)
        }
    }
    
    // MARK: - Location Monitoring
    
    func startLocationMonitoring() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            return
        }
        
        locationManager.startUpdatingLocation()
        print("📍 Started location monitoring")
    }
    
    func stopLocationMonitoring() {
        locationManager.stopUpdatingLocation()
        print("📍 Stopped location monitoring")
    }
    
    // MARK: - Error Handling
    
    func clearLocationError() {
        locationError = nil
    }
    
    func getLocationErrorDescription() -> String {
        return locationError?.localizedDescription ?? Constants.ErrorMessages.unknownError
    }
    
    func getLocationErrorRecoverySuggestion() -> String {
        return locationError?.recoverySuggestion ?? ""
    }
}

// MARK: - Location Validation Result

enum LocationValidationResult {
    case success(CLLocation)
    case failure(LocationError)
}

// MARK: - Location Error Types

enum LocationError: LocalizedError {
    case locationServicesDisabled
    case permissionDenied
    case noLocationAvailable
    case locationTooOld
    case accuracyTooLow
    case invalidCoordinates
    case timeout
    
    var errorDescription: String? {
        switch self {
        case .locationServicesDisabled:
            return "Location services are disabled"
        case .permissionDenied:
            return "Location permission is required"
        case .noLocationAvailable:
            return "Unable to get current location"
        case .locationTooOld:
            return "Location data is too old"
        case .accuracyTooLow:
            return "GPS location is not accurate enough"
        case .invalidCoordinates:
            return "Invalid GPS coordinates"
        case .timeout:
            return "Location request timed out"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .locationServicesDisabled:
            return "Please enable Location Services in Settings > Privacy & Security > Location Services"
        case .permissionDenied:
            return "Please allow location access in Settings > Privacy & Security > Location Services > EVV Transport App"
        case .noLocationAvailable:
            return "Please try again or move to an area with better GPS signal"
        case .locationTooOld:
            return "Please wait for a fresh GPS reading"
        case .accuracyTooLow:
            return "Please wait for better GPS accuracy or move to an open area"
        case .invalidCoordinates:
            return "Please try again to get valid GPS coordinates"
        case .timeout:
            return "Please check your GPS signal and try again"
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationService: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            self.authorizationStatus = manager.authorizationStatus
            
            switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                print("✅ Location permission granted")
                self.locationAvailable = true
                self.locationError = nil
                manager.requestLocation()
            case .denied, .restricted:
                print("❌ Location permission denied")
                self.locationAvailable = false
                self.locationError = .permissionDenied
            case .notDetermined:
                print("⏳ Location permission not determined")
                self.locationAvailable = false
                self.locationError = nil
            @unknown default:
                break
            }
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        Task { @MainActor in
            self.currentLocation = location
            self.completeLocationRequest(with: location)
            
            // Update availability status
            self.locationAvailable = self.checkLocationAvailability()
            
            print("📍 Location updated: \(location.coordinate.latitude), \(location.coordinate.longitude)")
            print("   Accuracy: \(location.horizontalAccuracy)m")
            print("   Age: \(Date().timeIntervalSince(location.timestamp))s")
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Location error: \(error.localizedDescription)")
        
        Task { @MainActor in
            // Determine the specific error
            if let clError = error as? CLError {
                switch clError.code {
                case .denied:
                    self.locationError = .permissionDenied
                case .locationUnknown:
                    self.locationError = .noLocationAvailable
                case .network:
                    self.locationError = .noLocationAvailable
                default:
                    self.locationError = .noLocationAvailable
                }
            } else {
                self.locationError = .noLocationAvailable
            }
            
            self.locationAvailable = false
            self.completeLocationRequest(with: nil)
        }
    }
}
