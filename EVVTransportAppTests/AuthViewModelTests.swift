//
//  AuthViewModelTests.swift
//  EVVTransportAppTests
//
//  Created by Souhail Bourhim on 23/07/2025.
//

import XCTest
import Combine
@testable import EVVTransportApp

@MainActor
final class AuthViewModelTests: XCTestCase {
    
    var authViewModel: AuthViewModel!
    var cancellables: Set<AnyCancellable>!
    
    override func setUpWithError() throws {
        authViewModel = AuthViewModel()
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDownWithError() throws {
        authViewModel = nil
        cancellables = nil
    }
    
    func testInitialState() throws {
        XCTAssertFalse(authViewModel.isAuthenticated)
        XCTAssertNil(authViewModel.currentUser)
        XCTAssertFalse(authViewModel.isLoading)
        XCTAssertTrue(authViewModel.errorMessage.isEmpty)
    }
    
    func testSuccessfulLogin() async throws {
        let expectation = XCTestExpectation(description: "Login success")
        
        authViewModel.$isAuthenticated
            .dropFirst()
            .sink { isAuthenticated in
                if isAuthenticated {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        await authViewModel.login(username: "testuser", password: "testpass")
        
        await fulfillment(of: [expectation], timeout: 2.0)
        
        XCTAssertTrue(authViewModel.isAuthenticated)
        XCTAssertNotNil(authViewModel.currentUser)
        XCTAssertEqual(authViewModel.currentUser?.username, "testuser")
        XCTAssertFalse(authViewModel.isLoading)
        XCTAssertTrue(authViewModel.errorMessage.isEmpty)
    }
    
    func testFailedLoginEmptyCredentials() async throws {
        await authViewModel.login(username: "", password: "")
        
        XCTAssertFalse(authViewModel.isAuthenticated)
        XCTAssertNil(authViewModel.currentUser)
        XCTAssertFalse(authViewModel.isLoading)
        XCTAssertFalse(authViewModel.errorMessage.isEmpty)
    }
    
    func testFailedLoginEmptyUsername() async throws {
        await authViewModel.login(username: "", password: "password")
        
        XCTAssertFalse(authViewModel.isAuthenticated)
        XCTAssertNil(authViewModel.currentUser)
        XCTAssertFalse(authViewModel.errorMessage.isEmpty)
    }
    
    func testFailedLoginEmptyPassword() async throws {
        await authViewModel.login(username: "username", password: "")
        
        XCTAssertFalse(authViewModel.isAuthenticated)
        XCTAssertNil(authViewModel.currentUser)
        XCTAssertFalse(authViewModel.errorMessage.isEmpty)
    }
    
    func testLogout() async throws {
        // First login
        await authViewModel.login(username: "testuser", password: "testpass")
        XCTAssertTrue(authViewModel.isAuthenticated)
        
        // Then logout
        authViewModel.logout()
        
        XCTAssertFalse(authViewModel.isAuthenticated)
        XCTAssertNil(authViewModel.currentUser)
        XCTAssertTrue(authViewModel.errorMessage.isEmpty)
    }
    
    func testLoadingState() async throws {
        let loadingExpectation = XCTestExpectation(description: "Loading state")
        let completedExpectation = XCTestExpectation(description: "Completed state")
        
        var loadingStateObserved = false
        
        authViewModel.$isLoading
            .sink { isLoading in
                if isLoading && !loadingStateObserved {
                    loadingStateObserved = true
                    loadingExpectation.fulfill()
                } else if !isLoading && loadingStateObserved {
                    completedExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        await authViewModel.login(username: "testuser", password: "testpass")
        
        await fulfillment(of: [loadingExpectation, completedExpectation], timeout: 3.0)
        
        XCTAssertFalse(authViewModel.isLoading)
    }
}