import Foundation
import Network

// MARK: - HTTP Methods

enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

// MARK: - Retry Manager

class RetryManager {
    static func executeWithRetry<T>(_ operation: @escaping () async throws -> T) async throws -> T {
        var lastError: Error?
        
        for attempt in 1...Constants.API.maxRetryAttempts {
            do {
                return try await operation()
            } catch {
                lastError = error
                print("⚠️ Attempt \(attempt) failed: \(error)")
                
                if attempt < Constants.API.maxRetryAttempts {
                    let delay = min(Constants.API.retryBaseDelay * pow(2.0, Double(attempt - 1)), Constants.API.retryMaxDelay)
                    print("🔄 Retrying in \(delay) seconds...")
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                }
            }
        }
        
        throw lastError ?? NetworkError.networkFailure
    }
}

// MARK: - API Models

struct LoginRequest: Codable {
    let userName: String
    let password: String
    
    enum CodingKeys: String, CodingKey {
        case userName = "UserName"
        case password = "Password"
    }
}

struct LoginResponse: Codable {
    let tennantId: Int
    let userId: String?
    let roleType: String?
    let loginStatus: LoginStatus
    let userName: String?
    
    enum CodingKeys: String, CodingKey {
        case tennantId = "TennantId"
        case userId = "UserId"
        case roleType = "RoleType"
        case loginStatus = "LoginStatus"
        case userName = "UserName"
    }
}

enum LoginStatus: String, Codable {
    case valid = "VALID"
    case invalid = "INVALID"
}

struct GetDriverEventsResponse: Codable {
    let driverEvents: [DriverEvent]
    let operationStatus: OperationStatus
    
    enum CodingKeys: String, CodingKey {
        case driverEvents = "DriverEvents"
        case operationStatus = "OperationStatus"
    }
}

struct DriverEvent: Codable {
    let customerAddress: String
    let gender: Int
    let city: String
    let fullName: String
    let eventId: Int
    let homePhone: String
    let route: Int
    let eventStatus: String
    let event: String
    
    enum CodingKeys: String, CodingKey {
        case customerAddress = "CustomerAddress"
        case gender = "Gender"
        case city = "City"
        case fullName = "FullName"
        case eventId = "EventId"
        case homePhone = "HomePhone"
        case route = "Route"
        case eventStatus = "EventStatus"
        case event = "Event"
    }
}

struct UpdateDriverEventStatusRequest: Codable {
    let eventId: Int
    let eventStatus: String
    let latitude: String
    let longitude: String
    let tenantId: Int
    let userName: String
    
    enum CodingKeys: String, CodingKey {
        case eventId = "EventId"
        case eventStatus = "EventStatus"
        case latitude = "Latitude"
        case longitude = "Longitude"
        case tenantId = "TenantId"
        case userName = "UserName"
    }
}

struct UpdateStatusResponse: Codable {
    let operationStatus: OperationStatus
    
    enum CodingKeys: String, CodingKey {
        case operationStatus = "OperationStatus"
    }
}

enum OperationStatus: String, Codable {
    case success = "SUCCESS"
    case failure = "FAILURE"
    case error = "ERROR"
}

// MARK: - NetworkService Class

class NetworkService: ObservableObject {
    static let shared = NetworkService()
    
    private let baseURL = Constants.API.baseURL
    private let session: URLSession
    private var authToken: String?
    var currentTenantId: Int = 1
    
    // Network monitoring
    @Published var isNetworkAvailable = true
    @Published var networkError: NetworkError?
    private let networkMonitor = NWPathMonitor()
    private let networkQueue = DispatchQueue(label: "NetworkMonitor")
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = Constants.API.requestTimeout
        config.timeoutIntervalForResource = Constants.API.resourceTimeout
        self.session = URLSession(configuration: config)
        
        startNetworkMonitoring()
    }
    
    deinit {
        networkMonitor.cancel()
    }
    
    // MARK: - Network Monitoring
    
    private func startNetworkMonitoring() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.handleNetworkPathUpdate(path)
            }
        }
        networkMonitor.start(queue: networkQueue)
    }
    
    private func handleNetworkPathUpdate(_ path: NWPath) {
        let wasAvailable = isNetworkAvailable
        isNetworkAvailable = path.status == .satisfied
        
        if isNetworkAvailable {
            networkError = nil
            if !wasAvailable {
                print("✅ Network connection restored")
            }
        } else {
            networkError = .noInternetConnection
            print("❌ Network connection lost")
        }
    }
    
    // MARK: - Authentication
    
    func login(username: String, password: String) async throws -> User {
        guard !username.isEmpty && !password.isEmpty else {
            throw NetworkError.invalidCredentials
        }
        
        // Check if we should use mock data for testing
        if Constants.useMockDataForTesting {
            print("🔧 TESTING MODE: Using mock data for login")
            print("   Username: \(username)")
            print("   Password: \(password)")
            
            // Create a mock successful login response
            let mockUser = User(
                username: username,
                routeId: "1", // Mock route ID
                driverName: username,
                sessionId: "mock-session-\(UUID().uuidString)"
            )
            
            // Store mock auth token
            self.authToken = mockUser.sessionId
            DataService.shared.saveAuthToken(mockUser.sessionId!)
            self.currentTenantId = 1
            
            // Save user session
            DataService.shared.saveUserSession(mockUser, routeId: mockUser.routeId)
            
            print("✅ TESTING MODE: Mock login successful")
            print("   Mock User: \(mockUser.username)")
            print("   Mock Route ID: \(mockUser.routeId)")
            print("   Mock Session ID: \(mockUser.sessionId ?? "nil")")
            
            return mockUser
        }
        
        return try await RetryManager.executeWithRetry {
            let loginRequest = LoginRequest(userName: username, password: password)
            let url = URL(string: "\(self.baseURL)\(Constants.API.loginEndpoint)")!
            
            print("🔐 Attempting login for user: \(username)")
            print("   URL: \(url)")
            
            let request = self.buildRequest(
                url: url,
                method: .POST,
                body: try JSONEncoder().encode(loginRequest)
            )
            
            let (data, response) = try await self.session.data(for: request)
            
            // Debug: Print the raw response
            if let responseString = String(data: data, encoding: .utf8) {
                print("📡 Server response: \(responseString)")
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            print("📊 HTTP Status: \(httpResponse.statusCode)")
            
            guard httpResponse.statusCode == 200 else {
                print("❌ HTTP Error: \(httpResponse.statusCode)")
                throw NetworkError.serverError("HTTP \(httpResponse.statusCode)")
            }
            
            let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
            print("🔍 Parsed login status: \(loginResponse.loginStatus)")
            print("   Tenant ID: \(loginResponse.tennantId)")
            print("   User ID: \(loginResponse.userId ?? "nil")")
            print("   User Name: \(loginResponse.userName ?? "nil")")
            
            guard loginResponse.loginStatus == .valid else {
                print("❌ Login failed: \(loginResponse.loginStatus)")
                throw NetworkError.invalidCredentials
            }
            
            // Create user object
            let user = User(
                username: loginResponse.userName ?? username,
                routeId: loginResponse.userId ?? "1",
                driverName: loginResponse.userName ?? username,
                sessionId: UUID().uuidString
            )
            
            // Store auth token
            self.authToken = user.sessionId
            DataService.shared.saveAuthToken(user.sessionId!)
            self.currentTenantId = loginResponse.tennantId
            
            // Save user session
            DataService.shared.saveUserSession(user, routeId: user.routeId)
            
            print("✅ Login successful")
            print("   User: \(user.username)")
            print("   Route ID: \(user.routeId)")
            print("   Session ID: \(user.sessionId ?? "nil")")
            
            return user
        }
    }
    
    
    // MARK: - Data Retrieval
    
    func fetchPassengers(routeId: String) async throws -> [Passenger] {
        guard (authToken ?? DataService.shared.getAuthToken()) != nil else {
            throw NetworkError.unauthorized
        }
        
        // Check if we should use mock data for testing
        if Constants.useMockDataForTesting {
            print("🔧 TESTING MODE: Using mock passenger data")
            
            // Create mock passenger data for testing
            let mockPassengers = [
                Passenger(
                    recid: "1",
                    name: "John Smith",
                    address: "123 Main St, City",
                    status: .pending,
                    contactInfo: "555-0101",
                    gender: 1,
                    city: "City"
                ),
                Passenger(
                    recid: "2",
                    name: "Jane Doe",
                    address: "456 Oak Ave, Town",
                    status: .pickedUp,
                    contactInfo: "555-0202",
                    gender: 2,
                    city: "Town"
                ),
                Passenger(
                    recid: "3",
                    name: "Mike Johnson",
                    address: "789 Pine Rd, Village",
                    status: .pending,
                    contactInfo: "555-0303",
                    gender: 1,
                    city: "Village"
                ),
                Passenger(
                    recid: "4",
                    name: "Sarah Wilson",
                    address: "321 Elm St, Borough",
                    status: .droppedOff,
                    contactInfo: "555-0404",
                    gender: 2,
                    city: "Borough"
                )
            ]
            
            print("✅ TESTING MODE: Returning \(mockPassengers.count) mock passengers")
            return mockPassengers
        }
        
        return try await RetryManager.executeWithRetry {
            // Build URL with correct parameters as per API documentation
            var urlComponents = URLComponents(string: "\(self.baseURL)\(Constants.API.getDriverEventsEndpoint)")!
            
            // Get current user for API parameters
            let currentUser = DataService.shared.loadUserSession()
            let userName = currentUser?.username ?? ""
            let userID = currentUser?.routeId ?? ""
            
            urlComponents.queryItems = [
                URLQueryItem(name: "userName", value: userName),
                URLQueryItem(name: "userID", value: userID),
                URLQueryItem(name: "tennantId", value: "\(self.currentTenantId)")
            ]
            
            guard let url = urlComponents.url else {
                throw NetworkError.invalidResponse
            }
            
            print("📡 Fetching passengers for route: \(routeId)")
            print("   URL: \(url)")
            
            let request = self.buildRequest(url: url, method: .GET)
            
            let (data, response) = try await self.session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                throw NetworkError.serverError("HTTP \(httpResponse.statusCode)")
            }
            
            let driverEventsResponse = try JSONDecoder().decode(GetDriverEventsResponse.self, from: data)
            
            let passengers = driverEventsResponse.driverEvents.map { event in
                Passenger(
                    recid: String(event.eventId),
                    name: event.fullName,
                    address: event.customerAddress,
                    status: self.mapEventStatusToPassengerStatus(event.eventStatus),
                    contactInfo: event.homePhone,
                    gender: event.gender,
                    city: event.city
                )
            }
            
            print("✅ Retrieved \(passengers.count) passengers for route: \(routeId)")
            return passengers
        }
    }
    
    func refreshPassengerData(routeId: String) async throws -> [Passenger] {
        // Force refresh by clearing any cached data and re-fetching
        print("🔄 Starting force refresh for route: \(routeId)")
        
        // Check if we should use mock data for testing
        if Constants.useMockDataForTesting {
            print("🔧 TESTING MODE: Mock refresh for testing")
            return try await fetchPassengers(routeId: routeId)
        }
        
        // Clear any cached data and force fresh fetch
        return try await RetryManager.executeWithRetry {
            let passengers = try await self.fetchPassengers(routeId: routeId)
            print("✅ Force refresh completed. Retrieved \(passengers.count) passengers")
            return passengers
        }
    }
    
    // MARK: - Status Updates
    
    func updatePassengerStatus(_ statusUpdate: StatusUpdate) async throws -> Bool {
        guard (authToken ?? DataService.shared.getAuthToken()) != nil else {
            throw NetworkError.unauthorized
        }
        
        // Check if we should use mock data for testing
        if Constants.useMockDataForTesting {
            print("🔧 TESTING MODE: Mock status update")
            print("   Record ID: \(statusUpdate.recid)")
            print("   Status: \(statusUpdate.status)")
            print("   Location: \(statusUpdate.latitude), \(statusUpdate.longitude)")
            
            // Simulate network delay
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            
            print("✅ TESTING MODE: Mock status update successful")
            return true
        }
        
        // Validate status update
        guard statusUpdate.isValid else {
            throw NetworkError.invalidResponse
        }
        
        guard statusUpdate.isLocationValid else {
            throw NetworkError.serverError(Constants.ErrorMessages.locationRequired)
        }
        
        guard let eventId = Int(statusUpdate.recid) else {
            throw NetworkError.invalidResponse
        }
        
        return try await RetryManager.executeWithRetry {
            // Create backend-compatible status update request
            let updateRequest = UpdateDriverEventStatusRequest(
                eventId: eventId,
                eventStatus: self.mapPassengerStatusToEventStatus(statusUpdate.status),
                latitude: String(statusUpdate.latitude),
                longitude: String(statusUpdate.longitude),
                tenantId: self.currentTenantId,
                userName: DataService.shared.loadUserSession()?.username ?? ""
            )
            
            let url = URL(string: "\(self.baseURL)\(Constants.API.updateDriverEventStatusEndpoint)")!
            
            print("📡 Updating passenger status")
            print("   URL: \(url)")
            print("   Record ID: \(statusUpdate.recid)")
            print("   Status: \(statusUpdate.status)")
            print("   Location: \(statusUpdate.latitude), \(statusUpdate.longitude)")
            
            let request = self.buildRequest(
                url: url,
                method: .POST,
                body: try JSONEncoder().encode(updateRequest)
            )
            
            let (data, response) = try await self.session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                throw NetworkError.serverError("HTTP \(httpResponse.statusCode)")
            }
            
            let updateResponse = try JSONDecoder().decode(UpdateStatusResponse.self, from: data)
            
            guard updateResponse.operationStatus == .success else {
                throw NetworkError.serverError("Status update failed")
            }
            
            print("✅ Status update successful")
            return true
        }
    }
    
    // MARK: - Token Management
    
    func setAuthToken(_ token: String) {
        self.authToken = token
    }
    
    func clearAuthToken() {
        self.authToken = nil
        DataService.shared.deleteAuthToken()
    }
    
    func isAuthenticated() -> Bool {
        return (authToken ?? DataService.shared.getAuthToken()) != nil
    }
    
    // MARK: - Helper Methods
    
    private func buildRequest(url: URL, method: HTTPMethod, body: Data? = nil) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = authToken ?? DataService.shared.getAuthToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            request.httpBody = body
        }
        
        return request
    }
    
    func checkNetworkConnectivity() -> Bool {
        return isNetworkAvailable
    }
    
    private func mapEventStatusToPassengerStatus(_ eventStatus: String) -> PassengerStatus {
        switch eventStatus.lowercased() {
        case "completed", "picked up":
            return .pickedUp
        case "finished", "dropped off":
            return .droppedOff
        default:
            return .pending
        }
    }
    
    private func mapPassengerStatusToEventStatus(_ status: String) -> String {
        switch status.lowercased() {
        case "picked up":
            return "COMPLETED"
        case "dropped off":
            return "FINISHED"
        default:
            return "PENDING"
        }
    }
}

// MARK: - NetworkError Enum

enum NetworkError: LocalizedError {
    // Authentication Errors
    case invalidCredentials
    case unauthorized
    case tokenExpired
    case sessionExpired
    
    // Network Connectivity Errors
    case networkFailure
    case noInternetConnection
    case timeout
    case connectionLost
    
    // Server Response Errors
    case invalidResponse
    case serverError(String)
    case httpError(Int)
    case rateLimitExceeded
    
    // Data Processing Errors
    case decodingError(Error)
    case encodingError(Error)
    case invalidData
    
    // Location and Validation Errors
    case locationRequired
    case invalidLocation
    case locationAccuracyTooLow
    
    // General Errors
    case unknown(Error)
    case operationCancelled
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid username or password"
        case .unauthorized:
            return "Access denied. Please log in again."
        case .tokenExpired:
            return "Your session has expired. Please log in again."
        case .sessionExpired:
            return "Your session has timed out. Please log in again."
        case .networkFailure:
            return "Network connection failed"
        case .noInternetConnection:
            return "No internet connection available"
        case .timeout:
            return "Request timed out. Please try again."
        case .connectionLost:
            return "Connection was lost. Please try again."
        case .invalidResponse:
            return "Invalid response from server"
        case .serverError(let message):
            return message.isEmpty ? "Server error occurred" : message
        case .httpError(let code):
            switch code {
            case 400:
                return "Bad request. Please check your input."
            case 401:
                return "Authentication required. Please log in again."
            case 403:
                return "Access forbidden. Please contact support."
            case 404:
                return "Resource not found."
            case 429:
                return "Too many requests. Please wait and try again."
            case 500...599:
                return "Server error. Please try again later."
            default:
                return "HTTP error \(code). Please try again."
            }
        case .rateLimitExceeded:
            return "Too many requests. Please wait before trying again."
        case .decodingError:
            return "Failed to process server response"
        case .encodingError:
            return "Failed to prepare request data"
        case .invalidData:
            return "Invalid data received from server"
        case .locationRequired:
            return "GPS location is required for this operation"
        case .invalidLocation:
            return "Invalid GPS coordinates"
        case .locationAccuracyTooLow:
            return "GPS location is not accurate enough"
        case .unknown(let error):
            return "An unexpected error occurred: \(error.localizedDescription)"
        case .operationCancelled:
            return "Operation was cancelled"
        }
    }
    
    var isRetryable: Bool {
        switch self {
        case .networkFailure, .noInternetConnection, .timeout, .connectionLost,
             .serverError, .httpError, .rateLimitExceeded:
            return true
        case .invalidCredentials, .unauthorized, .tokenExpired, .sessionExpired,
             .invalidResponse, .decodingError, .encodingError, .invalidData,
             .locationRequired, .invalidLocation, .locationAccuracyTooLow,
             .unknown, .operationCancelled:
            return false
        }
    }
}

