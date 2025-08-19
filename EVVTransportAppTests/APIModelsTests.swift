// Unit tests for API Models
import XCTest
@testable import EVVTransportApp

final class APIModelsTests: XCTestCase {
    
    // MARK: - LoginRequest Tests
    
    func testLoginRequestEncoding() throws {
        let loginRequest = LoginRequest(userName: "testuser", password: "testpass")
        let data = try JSONEncoder().encode(loginRequest)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        XCTAssertEqual(json?["UserName"] as? String, "testuser")
        XCTAssertEqual(json?["Password"] as? String, "testpass")
    }
    
    // MARK: - LoginResponse Tests
    
    func testLoginResponseDecoding() throws {
        let jsonString = """
        {
            "TennantId": 1,
            "UserId": "ff95c528-9dc2-4eaf-b06b-465a0e6dbee8",
            "RoleType": "Driver",
            "LoginStatus": "VALID",
            "UserName": "testuser"
        }
        """
        
        let data = jsonString.data(using: .utf8)!
        let response = try JSONDecoder().decode(LoginResponse.self, from: data)
        
        XCTAssertEqual(response.tennantId, 1)  // Note: Backend uses "TennantId" with double 'n'
        XCTAssertEqual(response.userId, "ff95c528-9dc2-4eaf-b06b-465a0e6dbee8")
        XCTAssertEqual(response.roleType, "Driver")
        XCTAssertEqual(response.loginStatus, .valid)
        XCTAssertEqual(response.userName, "testuser")
    }
    
    func testLoginResponseDecodingInvalid() throws {
        let jsonString = """
        {
            "TennantId": 0,
            "UserId": "00000000-0000-0000-0000-000000000000",
            "RoleType": null,
            "LoginStatus": "INVALID",
            "UserName": null
        }
        """
        
        let data = jsonString.data(using: .utf8)!
        let response = try JSONDecoder().decode(LoginResponse.self, from: data)
        
        XCTAssertEqual(response.tennantId, 0)
        XCTAssertEqual(response.userId, "00000000-0000-0000-0000-000000000000")
        XCTAssertNil(response.roleType)
        XCTAssertEqual(response.loginStatus, .invalid)
        XCTAssertNil(response.userName)
    }
    
    // MARK: - GetDriverEventsResponse Tests
    
    func testGetDriverEventsResponseDecoding() throws {
        let jsonString = """
        {
            "DriverEvents": [
                {
                    "CustomerAddress": "123 Main St",
                    "Gender": 1,
                    "City": "Springfield",
                    "FullName": "John Doe",
                    "EventId": 101,
                    "HomePhone": "555-1234",
                    "Route": 5,
                    "EventStatus": "PENDING",
                    "Event": "PICKUP"
                }
            ],
            "OperationStatus": "SUCCESS"
        }
        """
        
        let data = jsonString.data(using: .utf8)!
        let response = try JSONDecoder().decode(GetDriverEventsResponse.self, from: data)
        
        XCTAssertEqual(response.operationStatus, .success)
        XCTAssertEqual(response.driverEvents.count, 1)
        
        let event = response.driverEvents[0]
        XCTAssertEqual(event.customerAddress, "123 Main St")
        XCTAssertEqual(event.gender, 1)
        XCTAssertEqual(event.city, "Springfield")
        XCTAssertEqual(event.fullName, "John Doe")
        XCTAssertEqual(event.eventId, 101)
        XCTAssertEqual(event.homePhone, "555-1234")
        XCTAssertEqual(event.route, 5)
        XCTAssertEqual(event.eventStatus, "PENDING")
        XCTAssertEqual(event.event, "PICKUP")
    }
    
    func testGetDriverEventsResponseEmptyArray() throws {
        let jsonString = """
        {
            "DriverEvents": [],
            "OperationStatus": "SUCCESS"
        }
        """
        
        let data = jsonString.data(using: .utf8)!
        let response = try JSONDecoder().decode(GetDriverEventsResponse.self, from: data)
        
        XCTAssertEqual(response.operationStatus, .success)
        XCTAssertEqual(response.driverEvents.count, 0)
    }
    
    // MARK: - UpdateDriverEventStatusRequest Tests
    
    func testUpdateDriverEventStatusRequestEncoding() throws {
        let request = UpdateDriverEventStatusRequest(
            eventId: 101,
            eventStatus: "PICKED_UP",
            latitude: "40.7128",
            longitude: "-74.0060",
            tenantId: 1,
            userName: "testdriver"
        )
        
        let data = try JSONEncoder().encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        XCTAssertEqual(json?["EventId"] as? Int, 101)
        XCTAssertEqual(json?["EventStatus"] as? String, "PICKED_UP")
        XCTAssertEqual(json?["Latitude"] as? String, "40.7128")
        XCTAssertEqual(json?["Longitude"] as? String, "-74.0060")
        XCTAssertEqual(json?["TenantId"] as? Int, 1)  // Note: Backend uses "TenantId" with single 'n'
        XCTAssertEqual(json?["UserName"] as? String, "testdriver")
    }
    
    // MARK: - UpdateStatusResponse Tests
    
    func testUpdateStatusResponseDecoding() throws {
        let jsonString = """
        {
            "OperationStatus": "SUCCESS"
        }
        """
        
        let data = jsonString.data(using: .utf8)!
        let response = try JSONDecoder().decode(UpdateStatusResponse.self, from: data)
        
        XCTAssertEqual(response.operationStatus, .success)
    }
    
    // MARK: - APIError Tests (Removed - APIError type doesn't exist)
    
    func testAPIErrorDecoding() throws {
        // APIError type has been removed from the codebase
        // This test is no longer relevant
    }
    
    func testAPIErrorInit() {
        // APIError type has been removed from the codebase
        // This test is no longer relevant
    }
    
    // MARK: - NetworkError Tests
    
    func testNetworkErrorLocalizedDescriptions() {
        // Test existing NetworkError cases
        XCTAssertEqual(NetworkError.timeout.localizedDescription, "Request timed out. Please try again.")
        XCTAssertEqual(NetworkError.unauthorized.localizedDescription, "Access denied. Please log in again.")
        
        XCTAssertEqual(NetworkError.httpError(401).localizedDescription, "Authentication required. Please log in again.")
        XCTAssertEqual(NetworkError.httpError(500).localizedDescription, "Server error. Please try again later.")
        XCTAssertEqual(NetworkError.httpError(404).localizedDescription, "Resource not found.")
        
        XCTAssertEqual(NetworkError.serverError("Custom error").localizedDescription, "Custom error")
    }
    
    // MARK: - Enum Tests
    
    func testLoginStatusEnum() {
        XCTAssertEqual(LoginStatus.valid.rawValue, "VALID")
        XCTAssertEqual(LoginStatus.invalid.rawValue, "INVALID")
    }
    
    func testOperationStatusEnum() {
        XCTAssertEqual(OperationStatus.success.rawValue, "SUCCESS")
        XCTAssertEqual(OperationStatus.failure.rawValue, "FAILURE")
        XCTAssertEqual(OperationStatus.error.rawValue, "ERROR")
    }
}