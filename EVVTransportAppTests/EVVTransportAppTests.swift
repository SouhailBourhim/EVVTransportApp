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
            pickupLocation: "123 Test St",
            dropoffLocation: "456 Test Ave",
            scheduledPickup: "09:00 AM",
            scheduledDropoff: "10:00 AM",
            status: .pending,
            medicalNotes: "Test notes",
            contactInfo: "555-1234",
            wheelchairFlag: true
        )
        
        XCTAssertEqual(passenger.recid, "001")
        XCTAssertEqual(passenger.name, "Test User")
        XCTAssertEqual(passenger.status, .pending)
        XCTAssertTrue(passenger.wheelchairFlag)
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
            datetime: "2025-01-01T10:00:00Z",
            latitude: 40.7128,
            longitude: -74.0060
        )
        
        XCTAssertEqual(statusUpdate.recid, "001")
        XCTAssertEqual(statusUpdate.status, "picked up")
        XCTAssertEqual(statusUpdate.latitude, 40.7128, accuracy: 0.0001)
        XCTAssertEqual(statusUpdate.longitude, -74.0060, accuracy: 0.0001)
    }
    
    func testUserModel() throws {
        let user = User(username: "testdriver", routeId: "ROUTE_001")
        
        XCTAssertEqual(user.username, "testdriver")
        XCTAssertEqual(user.routeId, "ROUTE_001")
    }
}
