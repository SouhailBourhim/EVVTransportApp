// API Models for EVV Transport App backend integration
import Foundation

// MARK: - Login Models

struct LoginRequest: Codable {
    let userName: String
    let password: String
    
    enum CodingKeys: String, CodingKey {
        case userName = "UserName"
        case password = "Password"
    }
}

struct LoginResponse: Codable {
    let tennantId: Int  // Note: Backend uses "TennantId" (double 'n') - this is their spelling
    let userId: String
    let roleType: String?
    let loginStatus: LoginStatus
    let userName: String?
    
    enum CodingKeys: String, CodingKey {
        case tennantId = "TennantId"  // Backend spelling with double 'n'
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

// MARK: - Driver Events Models

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

// MARK: - Status Update Models

struct UpdateDriverEventStatusRequest: Codable {
    let eventId: Int
    let eventStatus: String
    let latitude: String
    let longitude: String
    let tenantId: Int  // Note: Backend uses "TenantId" (single 'n') - different from login!
    let userName: String
    
    enum CodingKeys: String, CodingKey {
        case eventId = "EventId"
        case eventStatus = "EventStatus"
        case latitude = "Latitude"
        case longitude = "Longitude"
        case tenantId = "TenantId"  // Backend spelling with single 'n'
        case userName = "UserName"
    }
}

struct UpdateStatusResponse: Codable {
    let operationStatus: OperationStatus
    
    enum CodingKeys: String, CodingKey {
        case operationStatus = "OperationStatus"
    }
}

// MARK: - Common Models

enum OperationStatus: String, Codable {
    case success = "SUCCESS"
    case failure = "FAILURE"
    case error = "ERROR"
}

// MARK: - Error Models

struct APIError: Codable, Error {
    let message: String
    let statusCode: Int?
    
    enum CodingKeys: String, CodingKey {
        case message = "Message"
        case statusCode
    }
    
    init(message: String, statusCode: Int? = nil) {
        self.message = message
        self.statusCode = statusCode
    }
}

// MARK: - Network Error Types

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError(Error)
    case httpError(Int)
    case networkUnavailable
    case timeout
    case unauthorized
    case serverError(String)
    case unknown(Error)
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return Constants.ErrorMessages.unknownError
        case .noData:
            return Constants.ErrorMessages.invalidResponse
        case .decodingError:
            return Constants.ErrorMessages.invalidResponse
        case .httpError(let code):
            switch code {
            case 401:
                return Constants.ErrorMessages.tokenExpired
            case 500...599:
                return Constants.ErrorMessages.serverError
            default:
                return Constants.ErrorMessages.unknownError
            }
        case .networkUnavailable:
            return Constants.ErrorMessages.networkUnavailable
        case .timeout:
            return Constants.ErrorMessages.networkUnavailable
        case .unauthorized:
            return Constants.ErrorMessages.loginFailed
        case .serverError(let message):
            return message
        case .unknown:
            return Constants.ErrorMessages.unknownError
        }
    }
}