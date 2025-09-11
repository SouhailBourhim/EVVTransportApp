# EVVTransportApp - API Documentation

## 🌐 **API Overview**

The EVVTransportApp communicates with a backend API for authentication, passenger data, and status updates. This document outlines all API endpoints, request/response formats, and integration details based on the actual backend implementation.

## 🔗 **Base Configuration**

```swift
// Current Configuration (NEEDS UPDATE)
static let baseURL = "http://advantecis-csmwebservicebus.com"  // ⚠️ CHANGE TO HTTPS

// Required Configuration
static let baseURL = "https://advantecis-csmwebservicebus.com"  // ✅ SECURE
```

## 🔐 **Authentication**

### **Login Endpoint**

**Endpoint**: `POST /business/login`

**Request Format**:
```json
{
    "UserName": "string",
    "Password": "string"
}
```

**Response Format**:
```json
{
    "TennantId": 1,
    "UserId": "user_id_string",
    "RoleType": "Driver",
    "LoginStatus": "VALID",
    "UserName": "driver_username"
}
```

**Error Response** (LoginStatus = "INVALID"):
```json
{
    "TennantId": 0,
    "UserId": null,
    "RoleType": null,
    "LoginStatus": "INVALID",
    "UserName": null
}
```

**Implementation**:
```swift
// In NetworkService.swift
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
```

## 👥 **Passenger Management**

### **Get Driver Events Endpoint**

**Endpoint**: `GET /business/getdriverevents`

**Query Parameters**:
```
userName: string (driver username)
userID: string (driver user ID)
tennantId: int (tenant ID from login)
```

**Headers**:
```
Authorization: Bearer {session_token}
Content-Type: application/json
```

**Response Format**:
```json
{
    "DriverEvents": [
        {
            "CustomerAddress": "123 Main St, City, State",
            "Gender": 1,
            "City": "City",
            "FullName": "John Doe",
            "EventId": 123,
            "HomePhone": "555-1234",
            "Route": 1,
            "EventStatus": "PENDING",
            "Event": "PICKUP"
        }
    ],
    "OperationStatus": "SUCCESS"
}
```

**Implementation**:
```swift
// In NetworkService.swift
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
```

## 📍 **Status Updates**

### **Update Driver Event Status Endpoint**

**Endpoint**: `POST /business/updatedrivereventstatus`

**Headers**:
```
Authorization: Bearer {session_token}
Content-Type: application/json
```

**Request Format**:
```json
{
    "EventId": 123,
    "EventStatus": "COMPLETED",  // or "FINISHED" or "PENDING"
    "Latitude": "40.7128",
    "Longitude": "-74.0060",
    "TenantId": 1,
    "UserName": "driver_username"
}
```

**Response Format**:
```json
{
    "OperationStatus": "SUCCESS"
}
```

**Error Response**:
```json
{
    "OperationStatus": "FAILURE"
}
```

**Implementation**:
```swift
// In NetworkService.swift
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
```

## 🔄 **Additional Endpoints**

### **Insert Coordinates Endpoint**

**Endpoint**: `POST /business/insertcoordinates`

**Purpose**: Track driver location during trip

### **Update Driver Call Status Endpoint**

**Endpoint**: `POST /business/updatedrivercallstatus`

**Purpose**: Update driver call status

### **Start Trip Endpoint**

**Endpoint**: `POST /business/starttrip`

**Purpose**: Begin a new trip

### **End Trip Endpoint**

**Endpoint**: `POST /business/endtrip`

**Purpose**: End current trip

## 🔄 **Data Models**

### **Request Models**

```swift
// Login Request
struct LoginRequest: Codable {
    let userName: String
    let password: String
    
    enum CodingKeys: String, CodingKey {
        case userName = "UserName"
        case password = "Password"
    }
}

// Update Driver Event Status Request
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
```

### **Response Models**

```swift
// Login Response
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

// Get Driver Events Response
struct GetDriverEventsResponse: Codable {
    let driverEvents: [DriverEvent]
    let operationStatus: OperationStatus
    
    enum CodingKeys: String, CodingKey {
        case driverEvents = "DriverEvents"
        case operationStatus = "OperationStatus"
    }
}

// Update Status Response
struct UpdateStatusResponse: Codable {
    let operationStatus: OperationStatus
    
    enum CodingKeys: String, CodingKey {
        case operationStatus = "OperationStatus"
    }
}
```

## 🌐 **Network Configuration**

### **Request Headers**

All API requests include these headers:
```swift
let headers = [
    "Authorization": "Bearer \(token)",
    "Content-Type": "application/json",
    "Accept": "application/json"
]
```

### **Error Handling**

```swift
enum APIError: Error {
    case invalidURL
    case noData
    case decodingError
    case networkError(Error)
    case serverError(Int, String)
    case unauthorized
    case forbidden
    case notFound
    case rateLimited
    case unknown
}
```

### **Retry Logic**

```swift
// Exponential backoff retry
private func performRequestWithRetry<T: Codable>(
    endpoint: String,
    method: HTTPMethod,
    body: Codable? = nil,
    maxRetries: Int = 3
) async throws -> T {
    for attempt in 1...maxRetries {
        do {
            return try await performRequest(endpoint: endpoint, method: method, body: body)
        } catch {
            if attempt == maxRetries {
                throw error
            }
            let delay = pow(2.0, Double(attempt)) // Exponential backoff
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
    }
    throw APIError.unknown
}
```

## 🔒 **Security Considerations**

### **HTTPS Requirement**
- **Current Issue**: API uses HTTP (insecure)
- **Required Fix**: Change to HTTPS
- **Impact**: App Store will reject HTTP-only apps

### **Token Management**
- **Storage**: JWT tokens stored in Keychain
- **Expiration**: Handle token refresh
- **Validation**: Verify token before requests

### **Data Validation**
- **Input Sanitization**: Validate all user inputs
- **Response Validation**: Verify API responses
- **Error Handling**: Secure error messages

## 📊 **Status Codes**

### **HTTP Status Codes**
- `200 OK`: Request successful
- `201 Created`: Resource created
- `400 Bad Request`: Invalid request data
- `401 Unauthorized`: Invalid or missing token
- `403 Forbidden`: Insufficient permissions
- `404 Not Found`: Resource not found
- `500 Internal Server Error`: Server error

### **Event Status Values**
- `PENDING`: Passenger waiting for pickup
- `COMPLETED`: Passenger picked up
- `FINISHED`: Passenger dropped off

### **Status Mapping**
The app maps backend event statuses to passenger statuses:

```swift
// Backend Event Status → App Passenger Status
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

// App Passenger Status → Backend Event Status
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
```

## 🧪 **Testing**

### **API Testing Checklist**
- [ ] **Authentication**: Test login with valid/invalid credentials
- [ ] **Passenger Data**: Verify passenger list retrieval
- [ ] **Status Updates**: Test pickup/dropoff functionality
- [ ] **Error Handling**: Test network failures and errors
- [ ] **Security**: Verify HTTPS communication
- [ ] **Performance**: Test with large passenger lists

### **Mock Data for Development**
```swift
// Mock passengers for testing
let mockPassengers = [
    Passenger(
        recid: "mock_001",
        name: "John Doe",
        pickupAddress: "123 Main St, Anytown, USA",
        dropoffAddress: "456 Oak Ave, Anytown, USA",
        pickupTime: "08:00",
        dropoffTime: "09:00",
        status: "pending",
        wheelchair: false,
        medicalNotes: "None",
        emergencyContact: "555-1234"
    )
]
```

## 🔧 **Configuration Updates**

### **Required Changes Before Deployment**

1. **Update Base URL**:
   ```swift
   // In Constants.swift
   static let baseURL = "https://advantecis-csmwebservicebus.com"
   ```

2. **Verify Endpoints**:
   - Ensure all endpoints support HTTPS
   - Test API connectivity

3. **Update Error Handling**:
   - Add specific error cases for your API
   - Implement proper retry logic

## 📞 **Support**

For API-related issues:
- **Backend Team**: [Backend Developer Contact]
- **API Documentation**: [Backend API Docs URL]
- **Test Environment**: [Test API URL]

---

**Last Updated**: December 2024
**API Version**: 1.0
**Compatibility**: iOS 17.0+
