import XCTest
@testable import EVVTransportApp

final class PassengerModelTests: XCTestCase {
    
    func testPassengerInitialization() throws {
        let passenger = Passenger(
            recid: "12345",
            name: "John Doe",
            address: "123 Main St, Anytown, USA",
            status: .pending,
            contactInfo: "(555) 123-4567",
            gender: 1,
            city: "Anytown"
        )
        
        XCTAssertEqual(passenger.recid, "12345")
        XCTAssertEqual(passenger.name, "John Doe")
        XCTAssertEqual(passenger.address, "123 Main St, Anytown, USA")
        XCTAssertEqual(passenger.status, .pending)
        XCTAssertEqual(passenger.contactInfo, "(555) 123-4567")
        XCTAssertEqual(passenger.gender, 1)
        XCTAssertEqual(passenger.city, "Anytown")
    }
    
    func testPassengerWithOptionalFields() throws {
        let passenger = Passenger(
            recid: "12345",
            name: "Jane Smith",
            address: "456 Oak Ave, Somewhere, USA",
            status: .pickedUp,
            contactInfo: nil,
            gender: 0,
            city: "Somewhere"
        )
        
        XCTAssertEqual(passenger.recid, "12345")
        XCTAssertEqual(passenger.name, "Jane Smith")
        XCTAssertEqual(passenger.address, "456 Oak Ave, Somewhere, USA")
        XCTAssertEqual(passenger.status, .pickedUp)
        XCTAssertNil(passenger.contactInfo)
        XCTAssertEqual(passenger.gender, 0)
        XCTAssertEqual(passenger.city, "Somewhere")
    }
    
    func testComputedProperties() throws {
        let passenger = Passenger(
            recid: "12345",
            name: "Test Passenger",
            address: "123 Test St",
            status: .pending,
            contactInfo: "(555) 123-4567",
            gender: 1,
            city: "Test City"
        )
        
        // Test computed properties
        XCTAssertEqual(passenger.pickupLocation, "123 Test St")
        XCTAssertEqual(passenger.dropoffLocation, "123 Test St")
        XCTAssertEqual(passenger.scheduledPickup, "N/A")
        XCTAssertEqual(passenger.scheduledDropoff, "N/A")
        XCTAssertEqual(passenger.homeAddress, "123 Test St")
        XCTAssertEqual(passenger.displayPickupTime, "N/A")
        XCTAssertEqual(passenger.displayDropoffTime, "N/A")
        XCTAssertFalse(passenger.hasSpecialNeeds)
    }
    
    func testValidationMethods() throws {
        let validPassenger = Passenger(
            recid: "12345",
            name: "Valid Passenger",
            address: "123 Valid St",
            status: .pending,
            contactInfo: "(555) 123-4567",
            gender: 1,
            city: "Valid City"
        )
        
        XCTAssertTrue(validPassenger.isValid())
        XCTAssertTrue(validPassenger.hasValidContactInfo())
        XCTAssertTrue(validPassenger.hasValidHomeAddress())
        
        let invalidPassenger = Passenger(
            recid: "",
            name: "",
            address: "",
            status: .pending,
            contactInfo: nil,
            gender: 0,
            city: ""
        )
        
        XCTAssertFalse(invalidPassenger.isValid())
        XCTAssertFalse(invalidPassenger.hasValidContactInfo())
        XCTAssertFalse(invalidPassenger.hasValidHomeAddress())
    }
    
    func testPassengerStatusEnum() throws {
        XCTAssertEqual(PassengerStatus.pending.rawValue, "pending")
        XCTAssertEqual(PassengerStatus.pickedUp.rawValue, "picked up")
        XCTAssertEqual(PassengerStatus.droppedOff.rawValue, "dropped off")
        
        XCTAssertEqual(PassengerStatus.allCases.count, 3)
    }
    
    func testCodableConformance() throws {
        let originalPassenger = Passenger(
            recid: "12345",
            name: "Test Passenger",
            address: "123 Test St",
            status: .pending,
            contactInfo: "(555) 123-4567",
            gender: 1,
            city: "Test City"
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalPassenger)
        
        let decoder = JSONDecoder()
        let decodedPassenger = try decoder.decode(Passenger.self, from: data)
        
        XCTAssertEqual(originalPassenger.recid, decodedPassenger.recid)
        XCTAssertEqual(originalPassenger.name, decodedPassenger.name)
        XCTAssertEqual(originalPassenger.address, decodedPassenger.address)
        XCTAssertEqual(originalPassenger.status, decodedPassenger.status)
        XCTAssertEqual(originalPassenger.contactInfo, decodedPassenger.contactInfo)
        XCTAssertEqual(originalPassenger.gender, decodedPassenger.gender)
        XCTAssertEqual(originalPassenger.city, decodedPassenger.city)
    }
}