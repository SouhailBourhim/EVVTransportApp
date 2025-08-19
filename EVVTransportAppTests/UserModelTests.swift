import XCTest
@testable import EVVTransportApp

final class UserModelTests: XCTestCase {
    
    func testUserModelInitialization() throws {
        let user = User(
            username: "testdriver",
            routeId: "ROUTE_123",
            driverName: "John Doe",
            sessionId: "session_abc123"
        )
        
        XCTAssertEqual(user.username, "testdriver")
        XCTAssertEqual(user.routeId, "ROUTE_123")
        XCTAssertEqual(user.driverName, "John Doe")
        XCTAssertEqual(user.sessionId, "session_abc123")
    }
    
    func testUserModelWithOptionalFields() throws {
        let user = User(
            username: "testdriver",
            routeId: "ROUTE_123",
            driverName: nil,
            sessionId: nil
        )
        
        XCTAssertEqual(user.username, "testdriver")
        XCTAssertEqual(user.routeId, "ROUTE_123")
        XCTAssertNil(user.driverName)
        XCTAssertNil(user.sessionId)
    }
    
    func testUserModelCodableEncoding() throws {
        let user = User(
            username: "testdriver",
            routeId: "ROUTE_123",
            driverName: "John Doe",
            sessionId: "session_abc123"
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(user)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        XCTAssertEqual(json?["username"] as? String, "testdriver")
        XCTAssertEqual(json?["routeId"] as? String, "ROUTE_123")
        XCTAssertEqual(json?["driverName"] as? String, "John Doe")
        XCTAssertEqual(json?["sessionId"] as? String, "session_abc123")
    }
    
    func testUserModelCodableEncodingWithNilFields() throws {
        let user = User(
            username: "testdriver",
            routeId: "ROUTE_123",
            driverName: nil,
            sessionId: nil
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(user)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        XCTAssertEqual(json?["username"] as? String, "testdriver")
        XCTAssertEqual(json?["routeId"] as? String, "ROUTE_123")
        XCTAssertNil(json?["driverName"])
        XCTAssertNil(json?["sessionId"])
    }
    
    func testUserModelCodableDecoding() throws {
        let jsonString = """
        {
            "username": "testdriver",
            "routeId": "ROUTE_123",
            "driverName": "John Doe",
            "sessionId": "session_abc123"
        }
        """
        
        let data = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        let user = try decoder.decode(User.self, from: data)
        
        XCTAssertEqual(user.username, "testdriver")
        XCTAssertEqual(user.routeId, "ROUTE_123")
        XCTAssertEqual(user.driverName, "John Doe")
        XCTAssertEqual(user.sessionId, "session_abc123")
    }
    
    func testUserModelCodableDecodingWithNilFields() throws {
        let jsonString = """
        {
            "username": "testdriver",
            "routeId": "ROUTE_123",
            "driverName": null,
            "sessionId": null
        }
        """
        
        let data = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        let user = try decoder.decode(User.self, from: data)
        
        XCTAssertEqual(user.username, "testdriver")
        XCTAssertEqual(user.routeId, "ROUTE_123")
        XCTAssertNil(user.driverName)
        XCTAssertNil(user.sessionId)
    }
    
    func testUserModelCodableDecodingWithMissingOptionalFields() throws {
        let jsonString = """
        {
            "username": "testdriver",
            "routeId": "ROUTE_123"
        }
        """
        
        let data = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        let user = try decoder.decode(User.self, from: data)
        
        XCTAssertEqual(user.username, "testdriver")
        XCTAssertEqual(user.routeId, "ROUTE_123")
        XCTAssertNil(user.driverName)
        XCTAssertNil(user.sessionId)
    }
    
    func testUserModelCodableDecodingFailsWithMissingRequiredFields() throws {
        let jsonString = """
        {
            "driverName": "John Doe",
            "sessionId": "session_abc123"
        }
        """
        
        let data = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        
        XCTAssertThrowsError(try decoder.decode(User.self, from: data)) { error in
            XCTAssertTrue(error is DecodingError)
        }
    }
}