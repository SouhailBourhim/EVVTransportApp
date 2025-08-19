//
//  EVVTransportAppTests.swift
//  EVVTransportAppTests
//
//  Created by Souhail Bourhim on 23/07/2025.
//

import XCTest
import Combine
@testable import EVVTransportApp

final class EVVTransportAppTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    // MARK: - Model Tests
    
    func testPassengerModel() throws {
        let passenger = Passenger(
            recid: "001",
            name: "Test User",
            address: "123 Test St",
            status: .pending,
            contactInfo: "555-1234",
            gender: 1,
            city: "Test City"
        )
        
        XCTAssertEqual(passenger.recid, "001")
        XCTAssertEqual(passenger.name, "Test User")
        XCTAssertEqual(passenger.status, .pending)
        XCTAssertEqual(passenger.gender, 1)
        XCTAssertEqual(passenger.city, "Test City")
    }
    
    func testPassengerStatusEnum() throws {
        XCTAssertEqual(PassengerStatus.pending.displayName, "Pending Pickup")
        XCTAssertEqual(PassengerStatus.pickedUp.displayName, "On Bus")
        XCTAssertEqual(PassengerStatus.droppedOff.displayName, "Dropped Off")
        
        XCTAssertEqual(PassengerStatus.pending.icon, "clock")
        XCTAssertEqual(PassengerStatus.pickedUp.icon, "figure.walk")
        XCTAssertEqual(PassengerStatus.droppedOff.icon, "checkmark.circle.fill")
    }
    
    func testStatusUpdateModel() throws {
        let statusUpdate = StatusUpdate(
            recid: "001",
            status: "picked up",
            latitude: 40.7128,
            longitude: -74.0060
        )
        
        XCTAssertEqual(statusUpdate.recid, "001")
        XCTAssertEqual(statusUpdate.status, "picked up")
        XCTAssertEqual(statusUpdate.latitude, 40.7128, accuracy: 0.0001)
        XCTAssertEqual(statusUpdate.longitude, -74.0060, accuracy: 0.0001)
    }
    
    func testUserModel() throws {
        let user = User(username: "testdriver", routeId: "ROUTE_001", driverName: "Test Driver", sessionId: "session_test")
        
        XCTAssertEqual(user.username, "testdriver")
        XCTAssertEqual(user.routeId, "ROUTE_001")
    }
}
