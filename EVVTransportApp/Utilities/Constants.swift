// Constants utility placeholder 
import Foundation
import SwiftUI

struct Constants {
    // MARK: - App Configuration
    static let appVersion = "1.0.0"
    static let maxPassengers = 20
    
    // MARK: - API Configuration
    struct API {
        // TODO: Replace with your actual IIS backend URL
        static let baseURL = "https://your-backend-url.com/api"
        static let loginEndpoint = "/auth/login"
        static let passengersEndpoint = "/passengers"
        static let statusUpdateEndpoint = "/status-update"
        
        // Timeout configurations
        static let requestTimeout: TimeInterval = 30.0
        static let resourceTimeout: TimeInterval = 60.0
    }
    
    // MARK: - UI Configuration
    struct UI {
        // Font sizes optimized for driver use
        static let largeTouchTarget: CGFloat = 44.0
        static let cardCornerRadius: CGFloat = 16.0
        static let buttonCornerRadius: CGFloat = 12.0
        static let defaultPadding: CGFloat = 16.0
        
        // Colors
        struct Colors {
            static let primaryBlue = Color.blue
            static let successGreen = Color.green
            static let warningOrange = Color.orange
            static let errorRed = Color.red
            static let secondaryGray = Color.gray
        }
        
        // Animations
        static let defaultAnimation = Animation.easeInOut(duration: 0.3)
        static let quickAnimation = Animation.easeInOut(duration: 0.2)
    }
    
    // MARK: - Location Configuration
    struct Location {
        static let locationUpdateInterval: TimeInterval = 10.0
        static let locationAccuracy: Double = 10.0 // meters
        static let maxLocationAge: TimeInterval = 300.0 // 5 minutes
    }
    
    // MARK: - Passenger Status
    struct PassengerStatusMessages {
        static let pickedUp = "Passenger picked up successfully"
        static let droppedOff = "Passenger dropped off successfully"
        static let locationError = "Unable to get current location"
        static let networkError = "Network error occurred"
    }
    
    // MARK: - Error Messages
    struct ErrorMessages {
        static let loginFailed = "Login failed. Please check your credentials."
        static let networkUnavailable = "Network unavailable. Please check your connection."
        static let locationPermissionDenied = "Location permission is required for this app to function."
        static let unknownError = "An unexpected error occurred. Please try again."
    }
    
    // MARK: - UserDefaults Keys
    struct UserDefaultsKeys {
        static let currentUser = "currentUser"
        static let lastSyncTime = "lastSyncTime"
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let authToken = "authToken"
    }
    
    // MARK: - Accessibility
    struct Accessibility {
        static let minimumTouchTarget: CGFloat = 44.0
        static let preferredFontSize: CGFloat = 18.0
        static let highContrastMode = false
    }
}
