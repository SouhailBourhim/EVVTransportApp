import CoreLocation
import SwiftUI

@MainActor
class LocationService: NSObject, ObservableObject {
    static let shared = LocationService()
    
    private let locationManager = CLLocationManager()
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var currentLocation: CLLocation?
    
    private var locationContinuation: CheckedContinuation<CLLocation?, Never>?
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    func requestLocationPermission() {
        switch authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            print("Location permission denied")
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        @unknown default:
            break
        }
    }
    
    func getCurrentLocation() async -> CLLocation? {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            print("❌ Location permission not granted - using mock location")
            // Mock Bronx coordinates for development/testing
            return CLLocation(latitude: 40.8448, longitude: -73.8648)
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
                    print("⚠️ Location timeout - using mock location")
                    cont.resume(returning: CLLocation(latitude: 40.8448, longitude: -73.8648))
                }
            }
        }
    }
    
    private func completeLocationRequest(with location: CLLocation?) {
        if let continuation = locationContinuation {
            locationContinuation = nil
            continuation.resume(returning: location)
        }
    }
}

extension LocationService: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            self.authorizationStatus = manager.authorizationStatus
            
            switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                print("✅ Location permission granted")
                manager.requestLocation()
            case .denied, .restricted:
                print("❌ Location permission denied")
            case .notDetermined:
                print("⏳ Location permission not determined")
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
            print("📍 Location updated: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Location error: \(error.localizedDescription)")
        
        Task { @MainActor in
            // Return mock location on error for development
            let mockLocation = CLLocation(latitude: 40.8448, longitude: -73.8648)
            self.completeLocationRequest(with: mockLocation)
        }
    }
}
