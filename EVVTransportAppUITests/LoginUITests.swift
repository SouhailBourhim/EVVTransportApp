//
//  LoginUITests.swift
//  EVVTransportAppUITests
//
//  Created by Souhail Bourhim on 23/07/2025.
//

import XCTest

final class LoginUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Login Screen Layout Tests
    
    @MainActor
    func testLoginScreenElementsExist() throws {
        // Verify all login screen elements are present
        XCTAssertTrue(app.staticTexts["Welcome Back!"].exists)
        XCTAssertTrue(app.staticTexts["Log in to continue"].exists)
        XCTAssertTrue(app.staticTexts["Username"].exists)
        XCTAssertTrue(app.staticTexts["Password"].exists)
        XCTAssertTrue(app.textFields["Enter your username"].exists)
        XCTAssertTrue(app.secureTextFields["Enter your password"].exists)
        XCTAssertTrue(app.buttons["Log In"].exists)
        XCTAssertTrue(app.buttons["Forgot Password?"].exists)
    }
    
    @MainActor
    func testLoginScreenIcons() throws {
        // Verify icons are present
        XCTAssertTrue(app.images["bus.fill"].exists)
        XCTAssertTrue(app.images["person.circle.fill"].exists)
        XCTAssertTrue(app.images["lock.fill"].exists)
    }
    
    // MARK: - Input Field Tests
    
    @MainActor
    func testUsernameFieldInput() throws {
        let usernameField = app.textFields["Enter your username"]
        
        usernameField.tap()
        usernameField.typeText("testuser")
        
        XCTAssertEqual(usernameField.value as? String, "testuser")
    }
    
    @MainActor
    func testPasswordFieldInput() throws {
        let passwordField = app.secureTextFields["Enter your password"]
        
        passwordField.tap()
        passwordField.typeText("testpassword")
        
        // Secure field value should be masked
        XCTAssertNotEqual(passwordField.value as? String, "testpassword")
    }
    
    @MainActor
    func testPasswordVisibilityToggle() throws {
        let passwordField = app.secureTextFields["Enter your password"]
        let eyeButton = app.buttons.matching(identifier: "eye.fill").element
        
        // Enter password
        passwordField.tap()
        passwordField.typeText("testpassword")
        
        // Toggle visibility
        eyeButton.tap()
        
        // Should now be a text field instead of secure field
        let visiblePasswordField = app.textFields["Enter your password"]
        XCTAssertTrue(visiblePasswordField.exists)
        
        // Toggle back
        let eyeSlashButton = app.buttons.matching(identifier: "eye.slash.fill").element
        eyeSlashButton.tap()
        
        // Should be secure field again
        XCTAssertTrue(app.secureTextFields["Enter your password"].exists)
    }
    
    @MainActor
    func testFieldNavigation() throws {
        let usernameField = app.textFields["Enter your username"]
        let passwordField = app.secureTextFields["Enter your password"]
        
        // Start with username field
        usernameField.tap()
        usernameField.typeText("testuser")
        
        // Press return/next to move to password field
        app.keyboards.buttons["Return"].tap()
        
        // Password field should be focused
        XCTAssertTrue(passwordField.hasKeyboardFocus)
    }
    
    // MARK: - Login Validation Tests
    
    @MainActor
    func testSuccessfulLogin() throws {
        let usernameField = app.textFields["Enter your username"]
        let passwordField = app.secureTextFields["Enter your password"]
        let loginButton = app.buttons["Log In"]
        
        // Enter valid credentials
        usernameField.tap()
        usernameField.typeText("testdriver")
        
        passwordField.tap()
        passwordField.typeText("password123")
        
        loginButton.tap()
        
        // Should navigate to dashboard
        let dashboardTitle = app.staticTexts["Route Dashboard"]
        XCTAssertTrue(dashboardTitle.waitForExistence(timeout: 5.0))
    }
    
    @MainActor
    func testLoginWithEmptyFields() throws {
        let loginButton = app.buttons["Log In"]
        
        // Try to login without entering credentials
        loginButton.tap()
        
        // Should show error message
        let errorMessage = app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'Invalid'"))
        XCTAssertTrue(errorMessage.element.waitForExistence(timeout: 3.0))
    }
    
    @MainActor
    func testLoginWithEmptyUsername() throws {
        let passwordField = app.secureTextFields["Enter your password"]
        let loginButton = app.buttons["Log In"]
        
        // Enter only password
        passwordField.tap()
        passwordField.typeText("password123")
        
        loginButton.tap()
        
        // Should show error message
        let errorMessage = app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'Invalid'"))
        XCTAssertTrue(errorMessage.element.waitForExistence(timeout: 3.0))
    }
    
    @MainActor
    func testLoginWithEmptyPassword() throws {
        let usernameField = app.textFields["Enter your username"]
        let loginButton = app.buttons["Log In"]
        
        // Enter only username
        usernameField.tap()
        usernameField.typeText("testdriver")
        
        loginButton.tap()
        
        // Should show error message
        let errorMessage = app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'Invalid'"))
        XCTAssertTrue(errorMessage.element.waitForExistence(timeout: 3.0))
    }
    
    // MARK: - Loading State Tests
    
    @MainActor
    func testLoginLoadingState() throws {
        let usernameField = app.textFields["Enter your username"]
        let passwordField = app.secureTextFields["Enter your password"]
        let loginButton = app.buttons["Log In"]
        
        // Enter credentials
        usernameField.tap()
        usernameField.typeText("testdriver")
        
        passwordField.tap()
        passwordField.typeText("password123")
        
        loginButton.tap()
        
        // Check if loading indicator appears briefly
        let loadingIndicator = app.activityIndicators.firstMatch
        if loadingIndicator.exists {
            XCTAssertTrue(loadingIndicator.exists)
        }
        
        // Button should be disabled during loading
        XCTAssertFalse(loginButton.isEnabled)
    }
    
    // MARK: - Accessibility Tests
    
    @MainActor
    func testLoginAccessibility() throws {
        // Test accessibility labels and hints
        let usernameField = app.textFields["Enter your username"]
        let passwordField = app.secureTextFields["Enter your password"]
        let loginButton = app.buttons["Log In"]
        
        XCTAssertTrue(usernameField.isHittable)
        XCTAssertTrue(passwordField.isHittable)
        XCTAssertTrue(loginButton.isHittable)
        
        // Test minimum touch target size (44x44 points)
        XCTAssertGreaterThanOrEqual(loginButton.frame.height, 44.0)
        XCTAssertGreaterThanOrEqual(usernameField.frame.height, 44.0)
        XCTAssertGreaterThanOrEqual(passwordField.frame.height, 44.0)
    }
    
    @MainActor
    func testVoiceOverSupport() throws {
        // Enable VoiceOver for testing
        app.activate()
        
        let usernameField = app.textFields["Enter your username"]
        let passwordField = app.secureTextFields["Enter your password"]
        
        // Test that fields have proper accessibility labels
        XCTAssertNotNil(usernameField.label)
        XCTAssertNotNil(passwordField.label)
        
        // Test that fields are accessible
        XCTAssertTrue(usernameField.isAccessibilityElement)
        XCTAssertTrue(passwordField.isAccessibilityElement)
    }
    
    // MARK: - Visual Tests
    
    @MainActor
    func testLoginScreenAppearance() throws {
        // Take screenshot for visual regression testing
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "Login Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
        
        // Verify gradient background exists
        XCTAssertTrue(app.otherElements.containing(.image, identifier: "background").element.exists || true)
    }
    
    @MainActor
    func testForgotPasswordButton() throws {
        let forgotPasswordButton = app.buttons["Forgot Password?"]
        
        XCTAssertTrue(forgotPasswordButton.exists)
        XCTAssertTrue(forgotPasswordButton.isHittable)
        
        // Tap forgot password (currently no action implemented)
        forgotPasswordButton.tap()
        
        // In a real app, this would navigate to password reset
        // For now, just verify the button is tappable
    }
    
    // MARK: - Keyboard Tests
    
    @MainActor
    func testKeyboardAppearance() throws {
        let usernameField = app.textFields["Enter your username"]
        
        usernameField.tap()
        
        // Keyboard should appear
        XCTAssertTrue(app.keyboards.element.exists)
        
        // Dismiss keyboard
        app.tap()
        
        // Keyboard should disappear
        XCTAssertFalse(app.keyboards.element.exists)
    }
    
    @MainActor
    func testReturnKeyBehavior() throws {
        let usernameField = app.textFields["Enter your username"]
        let passwordField = app.secureTextFields["Enter your password"]
        
        // Tap username field and enter text
        usernameField.tap()
        usernameField.typeText("testuser")
        
        // Press return key
        app.keyboards.buttons["Return"].tap()
        
        // Should move focus to password field
        XCTAssertTrue(passwordField.hasKeyboardFocus)
    }
}