//
//  ExtensionsTests.swift
//  EVVTransportAppTests
//
//  Created by Souhail Bourhim on 23/07/2025.
//

import XCTest
import SwiftUI
@testable import EVVTransportApp

final class ExtensionsTests: XCTestCase {
    
    func testDateTimeAgoDisplay() throws {
        let now = Date()
        let oneHourAgo = now.addingTimeInterval(-3600)
        
        let timeAgoString = oneHourAgo.timeAgoDisplay()
        XCTAssertTrue(timeAgoString.contains("hr") || timeAgoString.contains("hour"))
    }
    
    func testDateFormattedTime() throws {
        let calendar = Calendar.current
        let components = DateComponents(year: 2025, month: 1, day: 1, hour: 14, minute: 30)
        let testDate = calendar.date(from: components)!
        
        let formattedTime = testDate.formattedTime()
        XCTAssertTrue(formattedTime.contains("2:30") || formattedTime.contains("14:30"))
    }
    
    func testDateFormattedDateTime() throws {
        let calendar = Calendar.current
        let components = DateComponents(year: 2025, month: 1, day: 1, hour: 14, minute: 30)
        let testDate = calendar.date(from: components)!
        
        let formattedDateTime = testDate.formattedDateTime()
        XCTAssertFalse(formattedDateTime.isEmpty)
        XCTAssertTrue(formattedDateTime.contains("1/1") || formattedDateTime.contains("2025"))
    }
    
    func testStringIsValidEmail() throws {
        XCTAssertTrue("test@example.com".isValidEmail())
        XCTAssertTrue("user.name+tag@domain.co.uk".isValidEmail())
        XCTAssertFalse("invalid-email".isValidEmail())
        XCTAssertFalse("@domain.com".isValidEmail())
        XCTAssertFalse("user@".isValidEmail())
        XCTAssertFalse("".isValidEmail())
    }
    
    func testStringIsValidPhoneNumber() throws {
        XCTAssertTrue("1234567890".isValidPhoneNumber())
        XCTAssertTrue("+1234567890".isValidPhoneNumber())
        XCTAssertTrue("5551234567".isValidPhoneNumber())
        XCTAssertFalse("123".isValidPhoneNumber())
        XCTAssertFalse("abc123".isValidPhoneNumber())
        XCTAssertFalse("".isValidPhoneNumber())
        XCTAssertFalse("+".isValidPhoneNumber())
    }
    
    func testStringTruncated() throws {
        let longString = "This is a very long string that should be truncated"
        let truncated = longString.truncated(to: 10)
        
        XCTAssertEqual(truncated, "This is a ...")
        XCTAssertEqual(truncated.count, 13) // 10 characters + "..."
        
        let shortString = "Short"
        let notTruncated = shortString.truncated(to: 10)
        XCTAssertEqual(notTruncated, "Short")
    }
    
    func testPassengerStatusDisplayName() throws {
        XCTAssertEqual(PassengerStatus.pending.displayName, "Pending Pickup")
        XCTAssertEqual(PassengerStatus.pickedUp.displayName, "On Bus")
        XCTAssertEqual(PassengerStatus.droppedOff.displayName, "Dropped Off")
    }
    
    func testPassengerStatusIcon() throws {
        XCTAssertEqual(PassengerStatus.pending.icon, "clock")
        XCTAssertEqual(PassengerStatus.pickedUp.icon, "figure.walk")
        XCTAssertEqual(PassengerStatus.droppedOff.icon, "checkmark.circle.fill")
    }
    
    func testPassengerStatusColor() throws {
        XCTAssertEqual(PassengerStatus.pending.color, .appOrange)
        XCTAssertEqual(PassengerStatus.pickedUp.color, .appBlue)
        XCTAssertEqual(PassengerStatus.droppedOff.color, .appGreen)
    }
    
    func testArrayLimitedTo() throws {
        let passengers = createMockPassengers(count: 25)
        let limited = passengers.limitedTo(20)
        
        XCTAssertEqual(limited.count, 20)
        XCTAssertEqual(limited.first?.recid, passengers.first?.recid)
    }
    
    func testArrayLimitedToWithSmallerArray() throws {
        let passengers = createMockPassengers(count: 5)
        let limited = passengers.limitedTo(20)
        
        XCTAssertEqual(limited.count, 5)
    }
    
    func testArraySortedByScheduledTime() throws {
        let passengers = [
            createMockPassenger(recid: "1"),
            createMockPassenger(recid: "2"),
            createMockPassenger(recid: "3")
        ]
        
        let sorted = passengers.sortedByScheduledTime()
        
        // Since backend doesn't provide scheduled times, all should be "N/A"
        XCTAssertEqual(sorted[0].scheduledPickup, "N/A")
        XCTAssertEqual(sorted[1].scheduledPickup, "N/A")
        XCTAssertEqual(sorted[2].scheduledPickup, "N/A")
    }
    
    func testBundleAppVersion() throws {
        let version = Bundle.main.appVersion
        XCTAssertFalse(version.isEmpty)
    }
    
    func testBundleBuildNumber() throws {
        let buildNumber = Bundle.main.buildNumber
        XCTAssertFalse(buildNumber.isEmpty)
    }
    
    func testBundleDisplayName() throws {
        let displayName = Bundle.main.displayName
        XCTAssertFalse(displayName.isEmpty)
    }
    
    // MARK: - Helper Methods
    
    private func createMockPassengers(count: Int) -> [Passenger] {
        return (1...count).map { index in
            createMockPassenger(recid: String(format: "%03d", index))
        }
    }
    
    private func createMockPassenger(recid: String) -> Passenger {
        return Passenger(
            recid: recid,
            name: "Test Passenger \(recid)",
            address: "Test Address",
            status: .pending,
            contactInfo: nil,
            gender: 1,
            city: "Test City"
        )
    }
}