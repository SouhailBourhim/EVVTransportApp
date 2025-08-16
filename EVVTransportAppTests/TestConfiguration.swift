//
//  TestConfiguration.swift
//  EVVTransportAppTests
//
//  Created by Souhail Bourhim on 23/07/2025.
//

import Foundation
import XCTest

// MARK: - Test Configuration

struct TestConfiguration {
    
    // MARK: - Test Timeouts
    static let shortTimeout: TimeInterval = 1.0
    static let mediumTimeout: TimeInterval = 3.0
    static let longTimeout: TimeInterval = 10.0
    static let networkTimeout: TimeInterval = 15.0
    
    // MARK: - Test Data
    static let validUsername = "testdriver"
    static let validPassword = "password123"
    static let invalidUsername = "invalid"
    static let invalidPassword = "wrong"
    
    // MARK: - Mock Coordinates
    static let bronxLatitude = 40.8448
    static let bronxLongitude = -73.8648
    static let manhattanLatitude = 40.7128
    static let manhattanLongitude = -74.0060
    
    // MARK: - Test Environment Setup
    static func setupTestEnvironment() {
        // Clear UserDefaults for testing
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: Constants.UserDefaultsKeys.currentUser)
        defaults.removeObject(forKey: Constants.UserDefaultsKeys.lastSyncTime)
        defaults.removeObject(forKey: Constants.UserDefaultsKeys.hasCompletedOnboarding)
        
        // Set test-specific configurations
        defaults.set(true, forKey: "isTestEnvironment")
    }
    
    static func tearDownTestEnvironment() {
        // Clean up test data
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "isTestEnvironment")
        defaults.removeObject(forKey: Constants.UserDefaultsKeys.currentUser)
        defaults.removeObject(forKey: Constants.UserDefaultsKeys.lastSyncTime)
        defaults.removeObject(forKey: Constants.UserDefaultsKeys.hasCompletedOnboarding)
    }
}

// MARK: - Test Base Class

class EVVTransportBaseTestCase: XCTestCase {
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        TestConfiguration.setupTestEnvironment()
    }
    
    override func tearDownWithError() throws {
        TestConfiguration.tearDownTestEnvironment()
        try super.tearDownWithError()
    }
}

// MARK: - UI Test Base Class

class EVVTransportBaseUITestCase: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launchEnvironment["isUITesting"] = "true"
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Common UI Test Helpers
    
    func performLogin(
        username: String = TestConfiguration.validUsername,
        password: String = TestConfiguration.validPassword
    ) {
        let usernameField = app.textFields["Enter your username"]
        let passwordField = app.secureTextFields["Enter your password"]
        let loginButton = app.buttons["Log In"]
        
        usernameField.tap()
        usernameField.typeText(username)
        
        passwordField.tap()
        passwordField.typeText(password)
        
        loginButton.tap()
        
        // Wait for dashboard to load
        let dashboardTitle = app.staticTexts["Route Dashboard"]
        _ = dashboardTitle.waitForExistence(timeout: TestConfiguration.mediumTimeout)
    }
    
    func waitForElement(
        _ element: XCUIElement,
        timeout: TimeInterval = TestConfiguration.mediumTimeout
    ) -> Bool {
        return element.waitForExistence(timeout: timeout)
    }
    
    func takeScreenshot(name: String) {
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}

// MARK: - Performance Test Configuration

extension XCTestCase {
    
    func measurePerformance(
        name: String,
        iterations: Int = 5,
        operation: () throws -> Void
    ) rethrows {
        measure(metrics: [XCTClockMetric()]) {
            try! operation()
        }
    }
    
    func measureAsyncPerformance(
        name: String,
        iterations: Int = 5,
        operation: () async throws -> Void
    ) async rethrows {
        let options = XCTMeasureOptions()
        options.iterationCount = iterations
        
        measure(metrics: [XCTClockMetric()], options: options) {
            let expectation = XCTestExpectation(description: name)
            
            Task {
                try await operation()
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: TestConfiguration.longTimeout)
        }
    }
}

// MARK: - Test Data Generators

extension TestConfiguration {
    
    static func generateRandomPassengers(count: Int) -> [Passenger] {
        let names = [
            "John Smith", "Maria Garcia", "David Johnson", "Sarah Wilson",
            "Michael Brown", "Lisa Davis", "Robert Miller", "Jennifer Taylor",
            "William Anderson", "Jessica Thomas", "James Jackson", "Ashley White"
        ]
        
        let locations = [
            "123 Main St, Bronx NY 10451",
            "456 Grand Concourse, Bronx NY 10458",
            "789 Webster Ave, Bronx NY 10456",
            "321 E 149th St, Bronx NY 10451",
            "555 Jerome Ave, Bronx NY 10452",
            "888 Third Ave, Bronx NY 10456"
        ]
        
        let times = [
            "08:00 AM", "08:30 AM", "09:00 AM", "09:30 AM",
            "10:00 AM", "10:30 AM", "11:00 AM", "11:30 AM"
        ]
        
        return (1...count).map { index in
            let randomName = names.randomElement() ?? "Test User \(index)"
            let randomPickup = locations.randomElement() ?? "Test Location"
            let randomDropoff = locations.randomElement() ?? "Test Destination"
            let randomPickupTime = times.randomElement() ?? "09:00 AM"
            let randomDropoffTime = times.randomElement() ?? "10:00 AM"
            let randomStatus = PassengerStatus.allCases.randomElement() ?? .pending
            
            return Passenger(
                recid: String(format: "%03d", index),
                name: randomName,
                pickupLocation: randomPickup,
                dropoffLocation: randomDropoff,
                scheduledPickup: randomPickupTime,
                scheduledDropoff: randomDropoffTime,
                status: randomStatus,
                medicalNotes: index % 4 == 0 ? "Special medical requirements" : nil,
                contactInfo: "(555) \(String(format: "%03d", Int.random(in: 100...999)))-\(String(format: "%04d", Int.random(in: 1000...9999)))",
                wheelchairFlag: index % 5 == 0
            )
        }
    }
}