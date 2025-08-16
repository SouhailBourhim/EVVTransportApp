//
//  DataServiceTests.swift
//  EVVTransportAppTests
//
//  Created by Souhail Bourhim on 23/07/2025.
//

import XCTest
@testable import EVVTransportApp

final class DataServiceTests: XCTestCase {
    
    var dataService: DataService!
    
    override func setUpWithError() throws {
        dataService = DataService.shared
        // Clear any existing data before each test
        dataService.clearAllData()
    }
    
    override func tearDownWithError() throws {
        // Clean up after each test
        dataService.clearAllData()
        dataService = nil
    }
    
    func testSaveAndLoadUserSession() throws {
        let user = User(username: "testuser", routeId: "ROUTE_001")
        
        // Save user session
        dataService.saveUserSession(user)
        
        // Load user session
        let loadedUser = dataService.loadUserSession()
        
        XCTAssertNotNil(loadedUser)
        XCTAssertEqual(loadedUser?.username, "testuser")
        XCTAssertEqual(loadedUser?.routeId, "ROUTE_001")
    }
    
    func testLoadUserSessionWhenEmpty() throws {
        let loadedUser = dataService.loadUserSession()
        XCTAssertNil(loadedUser)
    }
    
    func testClearUserSession() throws {
        let user = User(username: "testuser", routeId: "ROUTE_001")
        
        // Save and verify
        dataService.saveUserSession(user)
        XCTAssertNotNil(dataService.loadUserSession())
        
        // Clear and verify
        dataService.clearUserSession()
        XCTAssertNil(dataService.loadUserSession())
    }
    
    func testSaveAndGetLastSyncTime() throws {
        let testDate = Date()
        
        dataService.saveLastSyncTime(testDate)
        let retrievedDate = dataService.getLastSyncTime()
        
        // Allow for small time differences due to processing
        XCTAssertEqual(testDate.timeIntervalSince1970, retrievedDate.timeIntervalSince1970, accuracy: 1.0)
    }
    
    func testGetLastSyncTimeWhenEmpty() throws {
        let retrievedDate = dataService.getLastSyncTime()
        let now = Date()
        
        // Should return current date when no sync time is saved
        XCTAssertLessThanOrEqual(abs(retrievedDate.timeIntervalSince(now)), 1.0)
    }
    
    func testSaveAndGetAuthToken() throws {
        let testToken = "test_auth_token_12345"
        
        dataService.saveAuthToken(testToken)
        let retrievedToken = dataService.getAuthToken()
        
        XCTAssertEqual(retrievedToken, testToken)
    }
    
    func testGetAuthTokenWhenEmpty() throws {
        let retrievedToken = dataService.getAuthToken()
        XCTAssertNil(retrievedToken)
    }
    
    func testDeleteAuthToken() throws {
        let testToken = "test_auth_token_12345"
        
        // Save token
        dataService.saveAuthToken(testToken)
        XCTAssertNotNil(dataService.getAuthToken())
        
        // Delete token
        dataService.deleteAuthToken()
        XCTAssertNil(dataService.getAuthToken())
    }
    
    func testUpdateAuthToken() throws {
        let firstToken = "first_token"
        let secondToken = "second_token"
        
        // Save first token
        dataService.saveAuthToken(firstToken)
        XCTAssertEqual(dataService.getAuthToken(), firstToken)
        
        // Update with second token
        dataService.saveAuthToken(secondToken)
        XCTAssertEqual(dataService.getAuthToken(), secondToken)
    }
    
    func testSaveAppSettings() throws {
        XCTAssertFalse(dataService.hasCompletedOnboarding())
        
        dataService.saveAppSettings()
        
        XCTAssertTrue(dataService.hasCompletedOnboarding())
    }
    
    func testClearAllData() throws {
        let user = User(username: "testuser", routeId: "ROUTE_001")
        let testToken = "test_token"
        let testDate = Date()
        
        // Save all types of data
        dataService.saveUserSession(user)
        dataService.saveAuthToken(testToken)
        dataService.saveLastSyncTime(testDate)
        dataService.saveAppSettings()
        
        // Verify data exists
        XCTAssertNotNil(dataService.loadUserSession())
        XCTAssertNotNil(dataService.getAuthToken())
        XCTAssertTrue(dataService.hasCompletedOnboarding())
        
        // Clear all data
        dataService.clearAllData()
        
        // Verify all data is cleared
        XCTAssertNil(dataService.loadUserSession())
        XCTAssertNil(dataService.getAuthToken())
        XCTAssertFalse(dataService.hasCompletedOnboarding())
    }
    
    func testSingletonInstance() throws {
        let instance1 = DataService.shared
        let instance2 = DataService.shared
        
        XCTAssertTrue(instance1 === instance2, "DataService should be a singleton")
    }
}