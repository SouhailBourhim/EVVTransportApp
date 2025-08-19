# Design Document

## Overview

This design document outlines the integration of the iOS EVV Transport App with an ASP.NET backend server running on IIS with Microsoft SQL Server. The integration will replace mock data implementations with real REST API calls while maintaining the existing SwiftUI architecture and user experience. The design focuses on secure authentication, real-time data synchronization, and robust error handling.

## Architecture

### High-Level Architecture

```
iOS App (SwiftUI) ←→ HTTP/REST ←→ ASP.NET Web API (IIS) ←→ SQL Server Database
Backend URL: http://advantecis-csmwebservicebus.com/Help
```

### Component Layers

1. **Presentation Layer**: SwiftUI Views and ViewModels
2. **Service Layer**: NetworkService, DataService, LocationService
3. **Model Layer**: Data models matching backend API contracts
4. **Security Layer**: Keychain storage and HTTP communication with token authentication

### Data Flow

1. **Authentication Flow**: Login → Token Storage → Route Assignment
2. **Data Retrieval Flow**: Fetch Passengers → Cache Locally → Display in UI
3. **Status Update Flow**: User Action → GPS Location → API Call → UI Update → Data Refresh

## Components and Interfaces

### 1. NetworkService Enhancement

**Current State**: Contains mock implementations with TODO comments
**Target State**: Full REST API integration with proper error handling

#### API Endpoints to Implement

Base URL: `http://advantecis-csmwebservicebus.com`

```swift
// Authentication
POST /api/auth/login
Request: { "username": string, "password": string }
Response: { "token": string, "user": User, "routeId": string }

// Passenger Data
GET /api/passengers?routeId={routeId}
Headers: Authorization: Bearer {token}
Response: [Passenger]

// Status Updates
POST /api/status-update
Headers: Authorization: Bearer {token}
Request: StatusUpdate
Response: { "success": boolean, "message": string }

// Force Refresh
GET /api/passengers/refresh?routeId={routeId}
Headers: Authorization: Bearer {token}
Response: [Passenger]
```

**Note**: The backend uses HTTP (not HTTPS), so security considerations will focus on token-based authentication and secure local storage.

#### Enhanced NetworkService Methods

```swift
class NetworkService: ObservableObject {
    private var authToken: String?
    private let session: URLSession
    
    // Authentication
    func login(username: String, password: String) async throws -> (User, String)
    
    // Data Retrieval
    func fetchPassengers(routeId: String) async throws -> [Passenger]
    func refreshPassengerData(routeId: String) async throws -> [Passenger]
    
    // Status Updates
    func updatePassengerStatus(_ statusUpdate: StatusUpdate) async throws -> Bool
    
    // Token Management
    func setAuthToken(_ token: String)
    func clearAuthToken()
    
    // Request Building
    private func buildRequest(url: URL, method: HTTPMethod, body: Data?) -> URLRequest
    private func handleResponse<T: Codable>(_ data: Data, _ response: URLResponse, type: T.Type) throws -> T
}
```

### 2. Enhanced Data Models

#### User Model Updates
```swift
struct User: Codable {
    let username: String
    let routeId: String
    let driverName: String?
    let sessionId: String?
}
```

#### Passenger Model Updates
```swift
struct Passenger: Identifiable, Codable {
    let id = UUID()
    let recid: String
    let name: String
    let pickupLocation: String
    let dropoffLocation: String
    let scheduledPickup: String
    let scheduledDropoff: String
    var status: PassengerStatus
    let medicalNotes: String?
    let contactInfo: String?
    let wheelchairFlag: Bool
    let homeAddress: String?
    
    // Computed properties for UI
    var displayPickupTime: String { /* formatted time */ }
    var displayDropoffTime: String { /* formatted time */ }
    var hasSpecialNeeds: Bool { wheelchairFlag || !(medicalNotes?.isEmpty ?? true) }
}
```

#### API Response Models
```swift
struct LoginResponse: Codable {
    let token: String
    let user: User
    let routeId: String
    let expiresAt: Date
}

struct StatusUpdateResponse: Codable {
    let success: Bool
    let message: String
    let timestamp: Date
}

struct APIError: Codable, Error {
    let code: String
    let message: String
    let details: String?
}
```

### 3. Enhanced DataService

#### Secure Token Management
```swift
class DataService: ObservableObject {
    // Enhanced token management
    func saveAuthToken(_ token: String, expiresAt: Date)
    func getAuthToken() -> (token: String, expiresAt: Date)?
    func isTokenValid() -> Bool
    
    // Session management
    func saveUserSession(_ user: User, routeId: String)
    func getCurrentRouteId() -> String?
    
    // Sync tracking
    func updateLastSyncTime(_ date: Date)
    func getTimeSinceLastSync() -> TimeInterval
}
```

### 4. Enhanced ViewModels

#### AuthViewModel Updates
```swift
@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var currentRouteId: String?
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    func login(username: String, password: String) async
    func logout()
    func checkExistingSession() -> Bool
    private func handleLoginSuccess(_ response: LoginResponse)
}
```

#### RouteViewModel Updates
```swift
@MainActor
class RouteViewModel: ObservableObject {
    @Published var passengers: [Passenger] = []
    @Published var isLoading = false
    @Published var isSyncing = false
    @Published var errorMessage = ""
    @Published var lastSyncTime = Date()
    @Published var pendingUpdates: [StatusUpdate] = []
    
    // Enhanced passenger management
    func loadPassengers() async
    func forceRefresh() async
    func updatePassengerStatus(_ passenger: Passenger, to newStatus: PassengerStatus) async
    
    // Offline support
    func queueStatusUpdate(_ update: StatusUpdate)
    func syncPendingUpdates() async
    
    // UI helpers
    var onBusPassengers: [Passenger]
    var pendingPassengers: [Passenger]
    var hasPendingUpdates: Bool
}
```

## Data Models

### Request/Response Contracts

#### Login Request/Response
```swift
struct LoginRequest: Codable {
    let username: String
    let password: String
}

struct LoginResponse: Codable {
    let success: Bool
    let token: String?
    let user: User?
    let routeId: String?
    let message: String?
    let expiresAt: String? // ISO 8601 format
}
```

#### Status Update Contract
```swift
struct StatusUpdate: Codable {
    let recid: String
    let status: String // "picked up" or "dropped off"
    let datetime: String // ISO 8601 format
    let latitude: Double
    let longitude: Double
    let driverId: String?
    let routeId: String?
}
```

### Data Validation

```swift
extension StatusUpdate {
    var isValid: Bool {
        !recid.isEmpty &&
        !status.isEmpty &&
        !datetime.isEmpty &&
        latitude >= -90 && latitude <= 90 &&
        longitude >= -180 && longitude <= 180
    }
}

extension Passenger {
    var isValid: Bool {
        !recid.isEmpty &&
        !name.isEmpty &&
        !pickupLocation.isEmpty &&
        !dropoffLocation.isEmpty
    }
}
```

## Error Handling

### Error Types and Recovery Strategies

```swift
enum NetworkError: LocalizedError {
    case invalidCredentials
    case tokenExpired
    case networkFailure
    case invalidResponse
    case serverError(String)
    case locationUnavailable
    case rateLimited
    
    var errorDescription: String? { /* user-friendly messages */ }
    var recoverySuggestion: String? { /* actionable suggestions */ }
}
```

### Retry Logic

```swift
class RetryManager {
    static func executeWithRetry<T>(
        maxAttempts: Int = 3,
        delay: TimeInterval = 1.0,
        operation: @escaping () async throws -> T
    ) async throws -> T
    
    static func exponentialBackoff(attempt: Int) -> TimeInterval
}
```

### Offline Support Strategy

1. **Queue Failed Updates**: Store status updates locally when network fails
2. **Background Sync**: Retry queued updates when connectivity returns
3. **Cache Management**: Maintain last known passenger state
4. **User Feedback**: Clear indicators of sync status and pending operations

## Testing Strategy

### Unit Testing Approach

#### NetworkService Tests
```swift
class NetworkServiceTests: XCTestCase {
    func testLoginSuccess()
    func testLoginFailure()
    func testFetchPassengers()
    func testStatusUpdateWithValidLocation()
    func testStatusUpdateWithoutLocation()
    func testTokenExpiration()
    func testNetworkFailureRecovery()
}
```

#### ViewModel Tests
```swift
class AuthViewModelTests: XCTestCase {
    func testSuccessfulLogin()
    func testFailedLogin()
    func testSessionPersistence()
    func testLogout()
}

class RouteViewModelTests: XCTestCase {
    func testPassengerLoading()
    func testStatusUpdates()
    func testOfflineQueueing()
    func testForceRefresh()
}
```

### Integration Testing

#### API Integration Tests
- Test actual API endpoints with test server
- Validate request/response formats
- Test authentication flow end-to-end
- Verify GPS coordinate transmission

#### UI Integration Tests
```swift
class BackendIntegrationUITests: XCTestCase {
    func testLoginFlow()
    func testPassengerStatusUpdates()
    func testOfflineScenarios()
    func testForceRefreshFunctionality()
}
```

### Mock Strategy for Development

```swift
protocol NetworkServiceProtocol {
    func login(username: String, password: String) async throws -> (User, String)
    func fetchPassengers(routeId: String) async throws -> [Passenger]
    func updatePassengerStatus(_ statusUpdate: StatusUpdate) async throws -> Bool
}

class MockNetworkService: NetworkServiceProtocol {
    // Configurable mock responses for testing
}
```

## Security Considerations

### Authentication Security
- Store JWT tokens in iOS Keychain for secure local storage
- Implement token refresh mechanism
- Clear tokens on logout or expiration
- Handle authentication failures gracefully

### Data Transmission Security
- Use HTTP as required by the backend (http://advantecis-csmwebservicebus.com)
- Implement token-based authentication for API requests
- Validate API response integrity and format
- Sanitize user inputs before sending to backend
- **Note**: Since HTTP is used, ensure sensitive operations are handled carefully and consider the network environment

### Location Privacy
- Request location permission appropriately
- Only collect GPS when needed for status updates
- Clear location data after transmission
- Respect user privacy settings

## Performance Considerations

### Network Optimization
- Implement request caching where appropriate
- Use compression for large responses
- Batch status updates when possible
- Implement connection pooling

### UI Responsiveness
- Perform all network calls on background threads
- Use loading indicators for long operations
- Implement optimistic UI updates
- Cache passenger data for offline viewing

### Memory Management
- Limit passenger list to 20 items as specified
- Implement proper image caching if needed
- Clean up network resources properly
- Monitor memory usage in testing