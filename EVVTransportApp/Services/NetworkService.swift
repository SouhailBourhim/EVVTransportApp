import Foundation
import Network

// MARK: - API Models (inline for compilation)

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

// MARK: - RetryManager Class

class RetryManager {
    static func executeWithRetry<T>(
        maxAttempts: Int = Constants.API.maxRetryAttempts,
        delay: TimeInterval = Constants.API.retryBaseDelay,
        operation: @escaping () async throws -> T
    ) async throws -> T {
        var lastError: Error?
        
        for attempt in 1...maxAttempts {
            do {
                return try await operation()
            } catch let error as NetworkError {
                lastError = error
                
                // Don't retry non-retryable errors
                if !error.isRetryable {
                    throw error
                }
                
                if attempt < maxAttempts {
                    let backoffDelay = exponentialBackoff(attempt: attempt, baseDelay: delay)
                    print("⚠️ Retry attempt \(attempt)/\(maxAttempts) after \(backoffDelay)s for error: \(error.localizedDescription)")
                    try await Task.sleep(nanoseconds: UInt64(backoffDelay * 1_000_000_000))
                }
            } catch {
                lastError = error
                
                if attempt < maxAttempts {
                    let backoffDelay = exponentialBackoff(attempt: attempt, baseDelay: delay)
                    print("⚠️ Retry attempt \(attempt)/\(maxAttempts) after \(backoffDelay)s for error: \(error.localizedDescription)")
                    try await Task.sleep(nanoseconds: UInt64(backoffDelay * 1_000_000_000))
                }
            }
        }
        
        throw lastError ?? NetworkError.unknown(NSError(domain: "RetryFailed", code: -1))
    }
    
    static func exponentialBackoff(attempt: Int, baseDelay: TimeInterval) -> TimeInterval {
        return min(
            baseDelay * pow(2.0, Double(attempt - 1)),
            Constants.API.retryMaxDelay
        )
    }
}

// MARK: - NetworkService Class

class NetworkService: ObservableObject {
    static let shared = NetworkService()
    
    private let baseURL = Constants.API.baseURL
    private let session: URLSession
    private var authToken: String?
    private var currentTenantId: Int = 1 // Default, should be updated from login response
    
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
        
        // Start network monitoring
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
    
    func checkNetworkConnectivity() -> Bool {
        return isNetworkAvailable
    }
    
    // MARK: - Request Building Infrastructure
    
    private func buildRequest(
        url: URL,
        method: HTTPMethod,
        body: Data? = nil,
        headers: [String: String] = [:]
    ) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue(Constants.API.contentTypeJSON, forHTTPHeaderField: Constants.API.contentTypeHeader)
        
        // Add authorization header if token is available
        if let token = authToken ?? DataService.shared.getAuthToken() {
            request.setValue("\(Constants.API.bearerPrefix)\(token)", forHTTPHeaderField: Constants.API.authorizationHeader)
        }
        
        // Add custom headers
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // Add body if provided
        if let body = body {
            request.httpBody = body
        }
        
        return request
    }
    
    private func handleResponse<T: Codable>(
        _ data: Data,
        _ response: URLResponse,
        type: T.Type
    ) throws -> T {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        // Handle different HTTP status codes
        switch httpResponse.statusCode {
        case 200...299:
            // Success - decode the response
            do {
                return try JSONDecoder().decode(type, from: data)
            } catch {
                throw NetworkError.decodingError(error)
            }
        case 400:
            throw NetworkError.httpError(400)
        case 401:
            throw NetworkError.unauthorized
        case 403:
            throw NetworkError.httpError(403)
        case 404:
            throw NetworkError.httpError(404)
        case 429:
            throw NetworkError.rateLimitExceeded
        case 500...599:
            throw NetworkError.serverError("Server error: \(httpResponse.statusCode)")
        default:
            throw NetworkError.httpError(httpResponse.statusCode)
        }
    }
    
    // MARK: - HTTP Method Enum
    
    enum HTTPMethod: String {
        case GET = "GET"
        case POST = "POST"
        case PUT = "PUT"
        case DELETE = "DELETE"
    }
    
    // MARK: - Authentication
    
    func login(username: String, password: String) async throws -> User {
        guard !username.isEmpty && !password.isEmpty else {
            throw NetworkError.invalidCredentials
        }
        
        return try await RetryManager.executeWithRetry {
            let loginRequest = LoginRequest(userName: username, password: password)
            let url = URL(string: "\(self.baseURL)\(Constants.API.loginEndpoint)")!
            
            let request = self.buildRequest(
                url: url,
                method: .POST,
                body: try JSONEncoder().encode(loginRequest)
            )
            
            let (data, response) = try await self.session.data(for: request)
            let loginResponse = try self.handleResponse(data, response, type: LoginResponse.self)
            
            guard loginResponse.loginStatus == .valid else {
                throw NetworkError.unauthorized
            }
            
            // Store auth token and tenant ID
            if let userId = loginResponse.userId {
                self.authToken = userId
                DataService.shared.saveAuthToken(userId)
            }
            self.currentTenantId = loginResponse.tennantId
            
            // Convert backend response to app User model
            let user = User(
                username: loginResponse.userName ?? username,
                routeId: String(loginResponse.tennantId),
                driverName: loginResponse.userName ?? username,
                sessionId: loginResponse.userId
            )
            
            // Save user session with route ID
            DataService.shared.saveUserSession(user, routeId: user.routeId)
            
            return user
        }
    }
    
    // MARK: - Data Retrieval
    
    func fetchPassengers(routeId: String) async throws -> [Passenger] {
        guard let token = authToken ?? DataService.shared.getAuthToken() else {
            throw NetworkError.unauthorized
        }
        
        return try await RetryManager.executeWithRetry {
            // Build URL with query parameters as required by the API
            var urlComponents = URLComponents(string: "\(self.baseURL)\(Constants.API.getDriverEventsEndpoint)")!
            urlComponents.queryItems = [
                URLQueryItem(name: "userName", value: token),
                URLQueryItem(name: "userID", value: token),
                URLQueryItem(name: "tennantId", value: String(self.currentTenantId))
            ]
            
            let url = urlComponents.url!
            let request = self.buildRequest(url: url, method: .GET)
            
            let (data, response) = try await self.session.data(for: request)
            let driverEventsResponse = try self.handleResponse(data, response, type: GetDriverEventsResponse.self)
            
            guard driverEventsResponse.operationStatus == .success else {
                throw NetworkError.serverError("Failed to fetch driver events")
            }
            
            // Convert backend DriverEvent to app Passenger model
            let passengers = driverEventsResponse.driverEvents.prefix(Constants.maxPassengers).map { event in
                Passenger(
                    recid: String(event.eventId),
                    name: event.fullName,
                    address: event.customerAddress,
                    status: self.mapEventStatusToPassengerStatus(event.eventStatus),
                    contactInfo: event.homePhone.isEmpty ? nil : event.homePhone,
                    gender: event.gender,
                    city: event.city
                )
            }
            
            return Array(passengers)
        }
    }
    
    func refreshPassengerData(routeId: String) async throws -> [Passenger] {
        // Force refresh by clearing any cached data and re-fetching
        print("🔄 Starting force refresh for route: \(routeId)")
        
        // Clear any cached data and force fresh fetch
        return try await RetryManager.executeWithRetry {
            let passengers = try await self.fetchPassengers(routeId: routeId)
            print("✅ Force refresh completed. Retrieved \(passengers.count) passengers")
            return passengers
        }
    }
    
    // MARK: - Status Updates
    
    func updatePassengerStatus(_ statusUpdate: StatusUpdate) async throws -> Bool {
        guard let token = authToken ?? DataService.shared.getAuthToken() else {
            throw NetworkError.unauthorized
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
                userName: token
            )
            
            let url = URL(string: "\(self.baseURL)\(Constants.API.updateDriverEventStatusEndpoint)")!
            let request = self.buildRequest(
                url: url,
                method: .POST,
                body: try JSONEncoder().encode(updateRequest)
            )
            
            let (data, response) = try await self.session.data(for: request)
            let updateResponse = try self.handleResponse(data, response, type: UpdateStatusResponse.self)
            
            guard updateResponse.operationStatus == .success else {
                throw NetworkError.serverError("Failed to update passenger status")
            }
            
            print("✅ Status update sent to backend successfully:")
            print("   Record ID: \(statusUpdate.recid)")
            print("   Status: \(statusUpdate.status)")
            print("   Location: \(statusUpdate.latitude), \(statusUpdate.longitude)")
            
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
    
    // MARK: - GPS Coordinate Tracking
    
    func insertCoordinates(latitude: Double, longitude: Double) async throws {
        guard let token = authToken ?? DataService.shared.getAuthToken() else {
            throw NetworkError.unauthorized
        }
        
        return try await RetryManager.executeWithRetry {
            let coordinateData: [String: Any] = [
                "Latitude": String(latitude),
                "Longitude": String(longitude),
                "UserName": token,
                "DateTime": ISO8601DateFormatter().string(from: Date())
            ]
            
            let url = URL(string: "\(self.baseURL)\(Constants.API.insertCoordinatesEndpoint)")!
            let request = self.buildRequest(
                url: url,
                method: .POST,
                body: try JSONSerialization.data(withJSONObject: coordinateData)
            )
            
            let (_, response) = try await self.session.data(for: request)
            
            // Just check if the request was successful
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                if httpResponse.statusCode == 401 {
                    throw NetworkError.unauthorized
                }
                throw NetworkError.httpError(httpResponse.statusCode)
            }
        }
    }
    
    // MARK: - Private Helper Methods
    
    private func mapEventStatusToPassengerStatus(_ eventStatus: String) -> PassengerStatus {
        switch eventStatus.lowercased() {
        case "picked up", "picked_up", "pickedup", "completed":
            return .pickedUp
        case "dropped off", "dropped_off", "droppedoff", "finished":
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
        // Authentication Errors
        case .invalidCredentials:
            return "Invalid username or password"
        case .unauthorized:
            return "Access denied. Please log in again."
        case .tokenExpired:
            return "Your session has expired. Please log in again."
        case .sessionExpired:
            return "Your session has timed out. Please log in again."
            
        // Network Connectivity Errors
        case .networkFailure:
            return "Network connection failed"
        case .noInternetConnection:
            return "No internet connection available"
        case .timeout:
            return "Request timed out. Please try again."
        case .connectionLost:
            return "Connection was lost. Please try again."
            
        // Server Response Errors
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
            
        // Data Processing Errors
        case .decodingError:
            return "Failed to process server response"
        case .encodingError:
            return "Failed to prepare request data"
        case .invalidData:
            return "Invalid data received from server"
            
        // Location and Validation Errors
        case .locationRequired:
            return "GPS location is required for this operation"
        case .invalidLocation:
            return "Invalid GPS coordinates"
        case .locationAccuracyTooLow:
            return "GPS location is not accurate enough"
            
        // General Errors
        case .unknown(let error):
            return "An unexpected error occurred: \(error.localizedDescription)"
        case .operationCancelled:
            return "Operation was cancelled"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        // Authentication Errors
        case .invalidCredentials:
            return "Please check your username and password and try again."
        case .unauthorized, .tokenExpired, .sessionExpired:
            return "Please log in again to continue using the app."
            
        // Network Connectivity Errors
        case .networkFailure, .noInternetConnection:
            return "Please check your internet connection and try again."
        case .timeout:
            return "Please try again. If the problem persists, check your connection."
        case .connectionLost:
            return "Please try again. Your connection may be unstable."
            
        // Server Response Errors
        case .invalidResponse, .decodingError, .encodingError, .invalidData:
            return "Please try again. If the problem persists, contact support."
        case .serverError:
            return "Please try again later or contact support if the problem persists."
        case .httpError(let code):
            switch code {
            case 400:
                return "Please check your input and try again."
            case 401, 403:
                return "Please log in again to continue."
            case 404:
                return "The requested resource is not available."
            case 429:
                return "Please wait a moment before trying again."
            case 500...599:
                return "The server is experiencing issues. Please try again later."
            default:
                return "Please try again or contact support if the problem persists."
            }
        case .rateLimitExceeded:
            return "Please wait a few minutes before trying again."
            
        // Location and Validation Errors
        case .locationRequired:
            return "Please enable location services and try again."
        case .invalidLocation:
            return "Please try again to get valid GPS coordinates."
        case .locationAccuracyTooLow:
            return "Please wait for better GPS accuracy or move to an open area."
            
        // General Errors
        case .unknown:
            return "Please try again or contact support if the problem persists."
        case .operationCancelled:
            return "You can try the operation again."
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
    
    var shouldShowToUser: Bool {
        switch self {
        case .operationCancelled:
            return false
        default:
            return true
        }
    }
}

