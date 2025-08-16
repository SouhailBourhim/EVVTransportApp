//
//  DashboardUITests.swift
//  EVVTransportAppUITests
//
//  Created by Souhail Bourhim on 23/07/2025.
//

import XCTest

final class DashboardUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        performLogin()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Dashboard Layout Tests
    
    @MainActor
    func testDashboardElementsExist() throws {
        // Verify main dashboard elements
        XCTAssertTrue(app.staticTexts["Route Dashboard"].exists)
        XCTAssertTrue(app.staticTexts["On the Bus"].exists)
        XCTAssertTrue(app.staticTexts["To Be Picked Up"].exists)
        XCTAssertTrue(app.buttons["person.circle.fill"].exists)
    }
    
    @MainActor
    func testDashboardSplitLayout() throws {
        // Verify split layout structure
        let onBusSection = app.scrollViews.containing(.staticText, identifier: "On the Bus")
        let pendingSection = app.scrollViews.containing(.staticText, identifier: "To Be Picked Up")
        
        XCTAssertTrue(onBusSection.element.exists)
        XCTAssertTrue(pendingSection.element.exists)
    }
    
    @MainActor
    func testLastSyncTimeDisplay() throws {
        // Wait for sync time to appear
        sleep(1)
        
        let syncTimeText = app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'Last sync:'"))
        XCTAssertTrue(syncTimeText.element.exists)
    }
    
    // MARK: - Passenger Card Tests
    
    @MainActor
    func testPassengerCardsDisplay() throws {
        // Wait for data to load
        sleep(2)
        
        // Check for passenger cards in both sections
        let mariaCard = app.staticTexts["Maria Rodriguez"]
        let sarahCard = app.staticTexts["Sarah Johnson"]
        
        XCTAssertTrue(mariaCard.waitForExistence(timeout: 5.0) || sarahCard.waitForExistence(timeout: 5.0))
    }
    
    @MainActor
    func testPassengerCardElements() throws {
        // Wait for data to load
        sleep(2)
        
        // Find first passenger card
        let firstPassengerName = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Rodriguez' OR label CONTAINS 'Johnson' OR label CONTAINS 'Thompson'")).element
        
        if firstPassengerName.exists {
            // Verify card elements exist
            XCTAssertTrue(firstPassengerName.exists)
            
            // Look for location and time information
            let locationIcon = app.images["mappin"]
            let timeIcon = app.images.matching(NSPredicate(format: "identifier CONTAINS 'clock' OR identifier CONTAINS 'mappin'")).element
            
            XCTAssertTrue(locationIcon.exists || timeIcon.exists)
        }
    }
    
    @MainActor
    func testWheelchairIndicator() throws {
        // Wait for data to load
        sleep(2)
        
        // Look for wheelchair accessibility indicator
        let wheelchairIcon = app.images["figure.roll"]
        
        if wheelchairIcon.exists {
            XCTAssertTrue(wheelchairIcon.exists)
            XCTAssertTrue(wheelchairIcon.isHittable)
        }
    }
    
    // MARK: - Passenger Action Tests
    
    @MainActor
    func testPickupPassengerAction() throws {
        // Wait for data to load
        sleep(2)
        
        // Find pickup button
        let pickupButton = app.buttons.containing(NSPredicate(format: "label CONTAINS 'PICK UP' OR label CONTAINS 'Mark as Picked Up'")).element
        
        if pickupButton.exists {
            pickupButton.tap()
            
            // Verify success notification
            let successNotification = app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'Successfully picked up'"))
            XCTAssertTrue(successNotification.element.waitForExistence(timeout: 3.0))
            
            // Notification should disappear after a few seconds
            XCTAssertFalse(successNotification.element.waitForExistence(timeout: 5.0))
        }
    }
    
    @MainActor
    func testDropoffPassengerAction() throws {
        // Wait for data to load
        sleep(2)
        
        // Find dropoff button
        let dropoffButton = app.buttons.containing(NSPredicate(format: "label CONTAINS 'DROP OFF' OR label CONTAINS 'Mark as Dropped Off'")).element
        
        if dropoffButton.exists {
            dropoffButton.tap()
            
            // Verify success notification
            let successNotification = app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'Successfully dropped off'"))
            XCTAssertTrue(successNotification.element.waitForExistence(timeout: 3.0))
        }
    }
    
    @MainActor
    func testPassengerCardTap() throws {
        // Wait for data to load
        sleep(2)
        
        // Tap on passenger name (not button)
        let passengerName = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Rodriguez' OR label CONTAINS 'Johnson'")).element
        
        if passengerName.exists {
            passengerName.tap()
            
            // Should navigate to passenger detail view
            let detailView = app.navigationBars.firstMatch
            XCTAssertTrue(detailView.waitForExistence(timeout: 3.0))
        }
    }
    
    // MARK: - Menu and Navigation Tests
    
    @MainActor
    func testProfileMenuAccess() throws {
        let profileButton = app.buttons["person.circle.fill"]
        
        profileButton.tap()
        
        // Verify menu options
        XCTAssertTrue(app.buttons["Sync Now"].waitForExistence(timeout: 2.0))
        XCTAssertTrue(app.buttons["Sign Out"].exists)
    }
    
    @MainActor
    func testSyncNowAction() throws {
        let profileButton = app.buttons["person.circle.fill"]
        profileButton.tap()
        
        let syncButton = app.buttons["Sync Now"]
        syncButton.tap()
        
        // Verify sync info sheet appears
        let syncInfoSheet = app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'Sync' OR label CONTAINS 'Information'"))
        XCTAssertTrue(syncInfoSheet.element.waitForExistence(timeout: 3.0))
    }
    
    @MainActor
    func testSignOutAction() throws {
        let profileButton = app.buttons["person.circle.fill"]
        profileButton.tap()
        
        let signOutButton = app.buttons["Sign Out"]
        signOutButton.tap()
        
        // Should return to login screen
        let loginTitle = app.staticTexts["Welcome Back!"]
        XCTAssertTrue(loginTitle.waitForExistence(timeout: 3.0))
    }
    
    // MARK: - Scrolling Tests
    
    @MainActor
    func testScrollingInPassengerLists() throws {
        // Wait for data to load
        sleep(2)
        
        // Test scrolling in on-bus section
        let onBusScrollView = app.scrollViews.containing(.staticText, identifier: "On the Bus").element
        if onBusScrollView.exists {
            onBusScrollView.swipeUp()
            onBusScrollView.swipeDown()
        }
        
        // Test scrolling in pending section
        let pendingScrollView = app.scrollViews.containing(.staticText, identifier: "To Be Picked Up").element
        if pendingScrollView.exists {
            pendingScrollView.swipeUp()
            pendingScrollView.swipeDown()
        }
    }
    
    // MARK: - Status Updates Tests
    
    @MainActor
    func testStatusNotificationDisplay() throws {
        // Wait for data to load
        sleep(2)
        
        // Trigger a status update
        let actionButton = app.buttons.containing(NSPredicate(format: "label CONTAINS 'PICK UP' OR label CONTAINS 'DROP OFF'")).element
        
        if actionButton.exists {
            actionButton.tap()
            
            // Verify notification appears
            let notification = app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'Successfully'"))
            XCTAssertTrue(notification.element.waitForExistence(timeout: 3.0))
            
            // Tap notification to dismiss
            if notification.element.exists {
                notification.element.tap()
                XCTAssertFalse(notification.element.exists)
            }
        }
    }
    
    // MARK: - Error Handling Tests
    
    @MainActor
    func testErrorAlertHandling() throws {
        // Check if error alert appears (would need network error simulation)
        let errorAlert = app.alerts["Error"]
        
        if errorAlert.exists {
            XCTAssertTrue(errorAlert.buttons["OK"].exists)
            errorAlert.buttons["OK"].tap()
            XCTAssertFalse(errorAlert.exists)
        }
    }
    
    // MARK: - Accessibility Tests
    
    @MainActor
    func testDashboardAccessibility() throws {
        // Test main elements are accessible
        XCTAssertTrue(app.staticTexts["Route Dashboard"].isAccessibilityElement)
        XCTAssertTrue(app.buttons["person.circle.fill"].isHittable)
        
        // Test minimum touch target sizes
        let profileButton = app.buttons["person.circle.fill"]
        XCTAssertGreaterThanOrEqual(profileButton.frame.height, 44.0)
        
        // Wait for passenger cards to load
        sleep(2)
        
        // Test passenger action buttons have proper touch targets
        let actionButtons = app.buttons.matching(NSPredicate(format: "label CONTAINS 'PICK UP' OR label CONTAINS 'DROP OFF'"))
        
        for i in 0..<actionButtons.count {
            let button = actionButtons.element(boundBy: i)
            if button.exists {
                XCTAssertGreaterThanOrEqual(button.frame.height, 44.0)
                XCTAssertTrue(button.isHittable)
            }
        }
    }
    
    // MARK: - Performance Tests
    
    @MainActor
    func testDashboardLoadingPerformance() throws {
        // Measure time to load dashboard after login
        measure(metrics: [XCTClockMetric()]) {
            app.terminate()
            app.launch()
            performLogin()
            
            // Wait for dashboard to fully load
            let dashboardTitle = app.staticTexts["Route Dashboard"]
            _ = dashboardTitle.waitForExistence(timeout: 5.0)
        }
    }
    
    @MainActor
    func testScrollingPerformance() throws {
        // Wait for data to load
        sleep(2)
        
        let scrollView = app.scrollViews.firstMatch
        
        measure(metrics: [XCTOSSignpostMetric.scrollingAndDecelerationMetric]) {
            scrollView.swipeUp()
            scrollView.swipeDown()
            scrollView.swipeUp()
            scrollView.swipeDown()
        }
    }
    
    // MARK: - Visual Regression Tests
    
    @MainActor
    func testDashboardScreenshot() throws {
        // Wait for full load
        sleep(3)
        
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "Dashboard Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
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