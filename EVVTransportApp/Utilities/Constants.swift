// Constants for EVV Transport App backend integration
import Foundation
import SwiftUI

struct Constants {
    // MARK: - Developer Testing Configuration
    /// Set to true to use mock data for testing when backend is unavailable
    /// Set to false to use real backend API calls
    static let useMockDataForTesting = false
    
    // MARK: - App Configuration
    static let appVersion = "1.0.0"
    static let maxPassengers = 20
    
    // MARK: - API Configuration
    struct API {
        static let baseURL = "http://advantecis-csmwebservicebus.com"
        static let loginEndpoint = "/business/login"
        static let getDriverEventsEndpoint = "/business/getdriverevents"
        static let insertCoordinatesEndpoint = "/business/insertcoordinates"
        static let updateDriverEventStatusEndpoint = "/business/updatedrivereventstatus"
        static let updateDriverCallStatusEndpoint = "/business/updatedrivercallstatus"
        static let startTripEndpoint = "/business/starttrip"
        static let endTripEndpoint = "/business/endtrip"
        
        // Timeout configurations
        static let requestTimeout: TimeInterval = 30.0
        static let resourceTimeout: TimeInterval = 60.0
        
        // HTTP Headers
        static let contentTypeHeader = "Content-Type"
        static let authorizationHeader = "Authorization"
        static let contentTypeJSON = "application/json"
        static let bearerPrefix = "Bearer "
        
        // Retry Configuration
        static let maxRetryAttempts = 3
        static let retryBaseDelay: TimeInterval = 1.0
        static let retryMaxDelay: TimeInterval = 10.0
        
        // Authentication
        static let tokenExpirationBuffer: TimeInterval = 300.0 // 5 minutes before expiry
    }
    
    // MARK: - UI Configuration
    struct UI {
        // Font sizes optimized for driver use
        static let largeTouchTarget: CGFloat = 44.0
        static let cardCornerRadius: CGFloat = 16.0
        static let buttonCornerRadius: CGFloat = 12.0
        static let defaultPadding: CGFloat = 16.0
        
        // Colors - Dark Mode Compatible
        struct Colors {
            // Primary colors that work in both light and dark mode
            static let primaryBlue = Color.accentColor
            static let successGreen = Color.green
            static let warningOrange = Color.orange
            static let errorRed = Color.red
            static let secondaryGray = Color.gray
            
            // Modern color scheme - adaptive with better visual appeal
            static let background = Color(UIColor.systemBackground)
            static let secondaryBackground = Color(UIColor.secondarySystemBackground)
            static let groupedBackground = Color(UIColor.systemGroupedBackground)
            static let tertiaryBackground = Color(UIColor.tertiarySystemBackground)
            
            // Pure black dark mode
            static let primaryBackground = Color(UIColor { traitCollection in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0) // Pure black
                default:
                    return UIColor(red: 0.98, green: 0.98, blue: 0.99, alpha: 1.0)
                }
            })
            static let secondaryBackgroundEnhanced = Color(UIColor { traitCollection in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0) // Pure black
                default:
                    return UIColor(red: 0.95, green: 0.96, blue: 0.98, alpha: 1.0)
                }
            })
            static let cardBackgroundEnhanced = Color(UIColor { traitCollection in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0) // Pure black
                default:
                    return UIColor(red: 0.99, green: 0.99, blue: 1.0, alpha: 1.0)
                }
            })
            
            // Additional dark mode colors for better contrast
            static let darkModeAccent = Color(UIColor { traitCollection in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return UIColor(red: 0.25, green: 0.25, blue: 0.26, alpha: 1.0) // Subtle accent
                default:
                    return UIColor(red: 0.92, green: 0.92, blue: 0.93, alpha: 1.0)
                }
            })
            
            static let darkModeBorder = Color(UIColor { traitCollection in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return UIColor(red: 0.30, green: 0.30, blue: 0.31, alpha: 1.0) // Subtle borders
                default:
                    return UIColor(red: 0.85, green: 0.85, blue: 0.86, alpha: 1.0)
                }
            })
            
            // Simple text colors for clean dark mode
            static let primaryText = Color(UIColor { traitCollection in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0) // Clean white
                default:
                    return UIColor.label
                }
            })
            static let secondaryText = Color(UIColor { traitCollection in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return UIColor(red: 0.70, green: 0.70, blue: 0.70, alpha: 1.0) // Light grey
                default:
                    return UIColor.secondaryLabel
                }
            })
            static let tertiaryText = Color(UIColor { traitCollection in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return UIColor(red: 0.55, green: 0.55, blue: 0.55, alpha: 1.0) // Medium grey
                default:
                    return UIColor.tertiaryLabel
                }
            })
            static let placeholderText = Color(UIColor { traitCollection in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return UIColor(red: 0.45, green: 0.45, blue: 0.45, alpha: 1.0) // Dark grey
                default:
                    return UIColor.placeholderText
                }
            })
            
            // System colors
            static let separator = Color(UIColor.separator)
            static let opaqueSeparator = Color(UIColor.opaqueSeparator)
            static let link = Color(UIColor.link)
            
            // Card and surface colors
            static let cardBackground = Color(UIColor.systemBackground)
            static let cardSecondaryBackground = Color(UIColor.secondarySystemBackground)
            
            // Pure black search bar colors for dark mode
            static let searchBarBackground = Color(UIColor { traitCollection in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0) // Pure black
                default:
                    return UIColor.systemGray6
                }
            })
            static let searchBarBorder = Color(UIColor { traitCollection in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0) // Pure black
                default:
                    return UIColor.systemGray4
                }
            })
            
            // Button colors - adaptive
            static let buttonBackground = Color.accentColor
            static let buttonText = Color.white
            static let destructiveButtonBackground = Color.red
            static let destructiveButtonText = Color.white
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
        static let tokenExpired = "Your session has expired. Please log in again."
        static let serverError = "Server error occurred. Please try again later."
        static let invalidResponse = "Invalid response from server. Please try again."
        static let locationRequired = "GPS location is required to update passenger status."
        static let syncFailed = "Failed to sync data. Please try again."
    }
    
    // MARK: - UserDefaults Keys
    struct UserDefaultsKeys {
        static let currentUser = "currentUser"
        static let lastSyncTime = "lastSyncTime"
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let authToken = "authToken"
        static let tokenExpiration = "tokenExpiration"
        static let currentRouteId = "currentRouteId"
        static let sessionId = "sessionId"
        static let pendingStatusUpdates = "pendingStatusUpdates"
    }
    
    // MARK: - Accessibility
    struct Accessibility {
        static let minimumTouchTarget: CGFloat = 44.0
        static let preferredFontSize: CGFloat = 18.0
        static let highContrastMode = false
    }
}
