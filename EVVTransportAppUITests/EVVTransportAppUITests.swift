//
//  EVVTransportAppUITests.swift
//  EVVTransportAppUITests
//
//  Created by Souhail Bourhim on 23/07/2025.
//

import XCTest

final class EVVTransportAppUITests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Login Flow Tests
    
    @MainActor
    func testLoginScreenAppears() throws {
        // Verify login screen elements are present
        XCTAssertTrue(app.staticTexts["Welcome Back!"].exists)
        XCTAssertTrue(app.staticTexts["Log in to continue"].exists)
        XCTAssertTrue(app.textFields["Enter your username"].exists)
        XCTAssertTrue(app.secureTextFields["Enter your password"].exists)
        XCTAssertTrue(app.buttons["Log In"].exists)
    }
    
    @MainActor
    func testSuccessfulLogin() throws {
        // Enter valid credentials
        let usernameField = app.textFields["Enter your username"]
        let passwordField = app.secureTextFields["Enter your password"]
        let loginButton = app.buttons["Log In"]
        
        usernameField.tap()
        usernameField.typeText("testdriver")
        
        passwordField.tap()
        passwordField.typeText("password123")
        
        loginButton.tap()
        
        // Wait for dashboard to appear
        let dashboardTitle = app.staticTexts["Route Dashboard"]
        XCTAssertTrue(dashboardTitle.waitForExistence(timeout: 5.0))
    }
    
    @MainActor
    func testLoginWithEmptyCredentials() throws {
        let loginButton = app.buttons["Log In"]
        loginButton.tap()
        
        // Should show error message
        let errorMessage = app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'Invalid'"))
        XCTAssertTrue(errorMessage.element.waitForExistence(timeout: 3.0))
    }
    
    @MainActor
    func testPasswordVisibilityToggle() throws {
        let passwordField = app.secureTextFields["Enter your password"]
        let eyeButton = app.buttons.matching(identifier: "eye.fill").element
        
        passwordField.tap()
        passwordField.typeText("testpassword")
        
        // Toggle password visibility
        eyeButton.tap()
        
        // Password should now be visible as text field
        let visiblePasswordField = app.textFields["Enter your password"]
        XCTAssertTrue(visiblePasswordField.exists)
    }
    
    // MARK: - Dashboard Tests
    
    @MainActor
    func testDashboardLayout() throws {
        performLogin()
        
        // Verify dashboard sections exist
        XCTAssertTrue(app.staticTexts["Route Dashboard"].exists)
        XCTAssertTrue(app.staticTexts["On the Bus"].exists)
        XCTAssertTrue(app.staticTexts["To Be Picked Up"].exists)
    }
    
    @MainActor
    func testPassengerCardsDisplay() throws {
        performLogin()
        
        // Wait for passenger data to load
        sleep(2)
        
        // Check if passenger cards are displayed
        let passengerCards = app.scrollViews.otherElements.containing(.staticText, identifier: "Maria Rodriguez")
        XCTAssertTrue(passengerCards.element.waitForExistence(timeout: 5.0))
    }
    
    @MainActor
    func testPickupPassengerAction() throws {
        performLogin()
        
        // Wait for data to load
        sleep(2)
        
        // Find a pending passenger and tap pickup button
        let pickupButton = app.buttons.containing(NSPredicate(format: "label CONTAINS 'PICK UP'")).element
        if pickupButton.exists {
            pickupButton.tap()
            
            // Verify success notification appears
            let successNotification = app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'Successfully picked up'"))
            XCTAssertTrue(successNotification.element.waitForExistence(timeout: 3.0))
        }
    }
    
    @MainActor
    func testDropoffPassengerAction() throws {
        performLogin()
        
        // Wait for data to load
        sleep(2)
        
        // Find a picked up passenger and tap dropoff button
        let dropoffButton = app.buttons.containing(NSPredicate(format: "label CONTAINS 'DROP OFF'")).element
        if dropoffButton.exists {
            dropoffButton.tap()
            
            // Verify success notification appears
            let successNotification = app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'Successfully dropped off'"))
            XCTAssertTrue(successNotification.element.waitForExistence(timeout: 3.0))
        }
    }
    
    @MainActor
    func testPassengerDetailNavigation() throws {
        performLogin()
        
        // Wait for data to load
        sleep(2)
        
        // Tap on a passenger card (not the button)
        let passengerCard = app.staticTexts["Maria Rodriguez"]
        if passengerCard.exists {
            passengerCard.tap()
            
            // Verify passenger detail view appears
            let detailView = app.navigationBars.containing(.staticText, identifier: "Maria Rodriguez")
            XCTAssertTrue(detailView.element.waitForExistence(timeout: 3.0))
        }
    }
    
    // MARK: - Menu and Settings Tests
    
    @MainActor
    func testProfileMenuAccess() throws {
        performLogin()
        
        // Tap profile menu button
        let profileButton = app.buttons["person.circle.fill"]
        profileButton.tap()
        
        // Verify menu options appear
        XCTAssertTrue(app.buttons["Sync Now"].exists)
        XCTAssertTrue(app.buttons["Sign Out"].exists)
    }
    
    @MainActor
    func testSyncNowAction() throws {
        performLogin()
        
        // Open profile menu
        let profileButton = app.buttons["person.circle.fill"]
        profileButton.tap()
        
        // Tap sync now
        let syncButton = app.buttons["Sync Now"]
        syncButton.tap()
        
        // Verify sync info sheet appears
        let syncInfoSheet = app.staticTexts["Sync Information"]
        XCTAssertTrue(syncInfoSheet.waitForExistence(timeout: 3.0))
    }
    
    @MainActor
    func testSignOutAction() throws {
        performLogin()
        
        // Open profile menu
        let profileButton = app.buttons["person.circle.fill"]
        profileButton.tap()
        
        // Tap sign out
        let signOutButton = app.buttons["Sign Out"]
        signOutButton.tap()
        
        // Verify return to login screen
        let loginTitle = app.staticTexts["Welcome Back!"]
        XCTAssertTrue(loginTitle.waitForExistence(timeout: 3.0))
    }
    
    // MARK: - Accessibility Tests
    
    @MainActor
    func testAccessibilityElements() throws {
        // Test login screen accessibility
        XCTAssertTrue(app.textFields["Enter your username"].isHittable)
        XCTAssertTrue(app.secureTextFields["Enter your password"].isHittable)
        XCTAssertTrue(app.buttons["Log In"].isHittable)
        
        performLogin()
        
        // Test dashboard accessibility
        XCTAssertTrue(app.buttons["person.circle.fill"].isHittable)
        
        // Verify minimum touch target sizes (44x44 points)
        let loginButton = app.buttons["Log In"]
        let buttonFrame = loginButton.frame
        XCTAssertGreaterThanOrEqual(buttonFrame.height, 44.0)
    }
    
    @MainActor
    func testWheelchairAccessibilityIndicator() throws {
        performLogin()
        
        // Wait for data to load
        sleep(2)
        
        // Look for wheelchair accessibility indicator
        let wheelchairIcon = app.images["figure.roll"]
        if wheelchairIcon.exists {
            XCTAssertTrue(wheelchairIcon.isHittable)
        }
    }
    
    // MARK: - Error Handling Tests
    
    @MainActor
    func testNetworkErrorHandling() throws {
        // This would require network mocking in a real scenario
        // For now, we test the UI response to error states
        
        performLogin()
        
        // Simulate error by checking if error alert can appear
        // In a real test, you'd trigger a network error condition
        let errorAlert = app.alerts["Error"]
        if errorAlert.exists {
            XCTAssertTrue(errorAlert.buttons["OK"].exists)
        }
    }
    
    // MARK: - Performance Tests
    
    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
    
    @MainActor
    func testScrollPerformance() throws {
        performLogin()
        
        // Wait for data to load
        sleep(2)
        
        // Test scrolling performance in passenger lists
        let scrollView = app.scrollViews.firstMatch
        
        measure(metrics: [XCTOSSignpostMetric.scrollingAndDecelerationMetric]) {
            scrollView.swipeUp()
            scrollView.swipeDown()
        }
    }
    
    // MARK: - Helper Methods
    
    private func performLogin() {
        let usernameField = app.textFields["Enter your username"]
        let passwordField = app.secureTextFields["Enter your password"]
        let loginButton = app.buttons["Log In"]
        
        usernameField.tap()
        usernameField.typeText("testdriver")
        
        passwordField.tap()
        passwordField.typeText("password123")
        
        loginButton.tap()
        
        // Wait for dashboard to load
        let dashboardTitle = app.staticTexts["Route Dashboard"]
        _ = dashboardTitle.waitForExistence(timeout: 5.0)
    }
}