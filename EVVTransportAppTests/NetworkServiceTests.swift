//
//  NetworkServiceTests.swift
//  EVVTransportAppTests
//
//  Created by Souhail Bourhim on 23/07/2025.
//

import XCTest
@testable import EVVTransportApp

final class NetworkServiceTests: XCTestCase {
    
    var networkService: NetworkService!
    
    override func setUpWithError() throws {
        networkService = NetworkService.shared
    }
    
    override func tearDownWithError() throws {
        networkService = nil
    }
    
    func testLoginWithValidCredentials() async throws {
        let user = try await networkService.login(username: "testuser", password: "testpass")
        
        XCTAssertEqual(user.username, "testuser")
        XCTAssertEqual(user.routeId, "ROUTE_TESTUSER")
        XCTAssertEqual(user.driverName, "Driver Testuser")
        XCTAssertNotNil(user.sessionId)
        XCTAssertTrue(user.sessionId?.hasPrefix("session_") == true)
    }
    
    func testLoginWithEmptyCredentials() async throws {
        do {
            _ = try await networkService.login(username: "", password: "")
            XCTFail("Expected NetworkError.invalidCredentials")
        } catch NetworkError.invalidCredentials {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testLoginWithEmptyUsername() async throws {
        do {
            _ = try await networkService.login(username: "", password: "password")
            XCTFail("Expected NetworkError.invalidCredentials")
        } catch NetworkError.invalidCredentials {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testLoginWithEmptyPassword() async throws {
        do {
            _ = try await networkService.login(username: "username", password: "")
            XCTFail("Expected NetworkError.invalidCredentials")
        } catch NetworkError.invalidCredentials {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testFetchPassengers() async throws {
        let passengers = try await networkService.fetchPassengers(routeId: "ROUTE_001")
        
        XCTAssertFalse(passengers.isEmpty)
        XCTAssertGreaterThan(passengers.count, 0)
        
        // Verify passenger data structure
        let firstPassenger = passengers[0]
        XCTAssertFalse(firstPassenger.recid.isEmpty)
        XCTAssertFalse(firstPassenger.name.isEmpty)
        XCTAssertFalse(firstPassenger.pickupLocation.isEmpty)
        XCTAssertFalse(firstPassenger.dropoffLocation.isEmpty)
        XCTAssertEqual(firstPassenger.scheduledPickup, "N/A")
        XCTAssertEqual(firstPassenger.scheduledDropoff, "N/A")
    }
    
    func testFetchPassengersContainsExpectedData() async throws {
        let passengers = try await networkService.fetchPassengers(routeId: "ROUTE_001")
        
        // Check for specific mock data
        let mariaRodriguez = passengers.first { $0.name == "Maria Rodriguez" }
        XCTAssertNotNil(mariaRodriguez)
        XCTAssertEqual(mariaRodriguez?.recid, "001")
        XCTAssertEqual(mariaRodriguez?.gender, 1)
        XCTAssertEqual(mariaRodriguez?.status, .pending)
        
        let sarahJohnson = passengers.first { $0.name == "Sarah Johnson" }
        XCTAssertNotNil(sarahJohnson)
        XCTAssertEqual(sarahJohnson?.status, .pickedUp)
    }
    
    func testUpdatePassengerStatus() async throws {
        let statusUpdate = StatusUpdate(
            recid: "001",
            status: "picked up",
            latitude: 40.7128,
            longitude: -74.0060
        )
        
        // This should not throw an error
        try await networkService.updatePassengerStatus(statusUpdate)
    }
    
    func testNetworkErrorDescriptions() throws {
        XCTAssertEqual(NetworkError.invalidCredentials.errorDescription, "Invalid username or password")
        XCTAssertEqual(NetworkError.networkFailure.errorDescription, "Network connection failed. Please check your internet connection.")
        XCTAssertEqual(NetworkError.invalidResponse.errorDescription, "Invalid server response")
        XCTAssertEqual(NetworkError.unauthorized.errorDescription, "Session expired. Please log in again.")
        XCTAssertEqual(NetworkError.serverError("Test error").errorDescription, "Test error")
    }
    
    func testSingletonInstance() throws {
        let instance1 = NetworkService.shared
        let instance2 = NetworkService.shared
        
        XCTAssertTrue(instance1 === instance2, "NetworkService should be a singleton")
    }
}