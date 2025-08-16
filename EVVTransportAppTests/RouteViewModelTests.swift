//
//  RouteViewModelTests.swift
//  EVVTransportAppTests
//
//  Created by Souhail Bourhim on 23/07/2025.
//

import XCTest
import Combine
import CoreLocation
@testable import EVVTransportApp

@MainActor
final class RouteViewModelTests: XCTestCase {
    
    var routeViewModel: RouteViewModel!
    var cancellables: Set<AnyCancellable>!
    
    override func setUpWithError() throws {
        routeViewModel = RouteViewModel()
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDownWithError() throws {
        routeViewModel = nil
        cancellables = nil
    }
    
    func testInitialState() throws {
        XCTAssertTrue(routeViewModel.passengers.isEmpty)
        XCTAssertFalse(routeViewModel.isLoading)
        XCTAssertTrue(routeViewModel.errorMessage.isEmpty)
        XCTAssertFalse(routeViewModel.showStatusNotification)
        XCTAssertTrue(routeViewModel.statusNotificationMessage.isEmpty)
    }
    
    func testLoadPassengers() async throws {
        let expectation = XCTestExpectation(description: "Load passengers")
        
        routeViewModel.$passengers
            .dropFirst()
            .sink { passengers in
                if !passengers.isEmpty {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        await routeViewModel.loadPassengers()
        
        await fulfillment(of: [expectation], timeout: 2.0)
        
        XCTAssertFalse(routeViewModel.passengers.isEmpty)
        XCTAssertFalse(routeViewModel.isLoading)
        XCTAssertTrue(routeViewModel.errorMessage.isEmpty)
    }
    
    func testOnBusPassengersFilter() async throws {
        await routeViewModel.loadPassengers()
        
        let onBusPassengers = routeViewModel.onBusPassengers
        let allPickedUp = onBusPassengers.allSatisfy { $0.status == .pickedUp }
        
        XCTAssertTrue(allPickedUp)
        XCTAssertLessThanOrEqual(onBusPassengers.count, Constants.maxPassengers)
    }
    
    func testPendingPassengersFilter() async throws {
        await routeViewModel.loadPassengers()
        
        let pendingPassengers = routeViewModel.pendingPassengers
        let allPending = pendingPassengers.allSatisfy { $0.status == .pending }
        
        XCTAssertTrue(allPending)
        XCTAssertLessThanOrEqual(pendingPassengers.count, Constants.maxPassengers)
    }
    
    func testUpdatePassengerStatusToPickedUp() async throws {
        await routeViewModel.loadPassengers()
        
        guard let pendingPassenger = routeViewModel.passengers.first(where: { $0.status == .pending }) else {
            XCTFail("No pending passenger found for test")
            return
        }
        
        let originalRecid = pendingPassenger.recid
        
        await routeViewModel.updatePassengerStatus(pendingPassenger, to: .pickedUp)
        
        let updatedPassenger = routeViewModel.passengers.first { $0.recid == originalRecid }
        XCTAssertEqual(updatedPassenger?.status, .pickedUp)
        XCTAssertFalse(routeViewModel.isLoading)
    }
    
    func testUpdatePassengerStatusToDroppedOff() async throws {
        await routeViewModel.loadPassengers()
        
        guard let pickedUpPassenger = routeViewModel.passengers.first(where: { $0.status == .pickedUp }) else {
            XCTFail("No picked up passenger found for test")
            return
        }
        
        let originalRecid = pickedUpPassenger.recid
        let originalCount = routeViewModel.passengers.count
        
        await routeViewModel.updatePassengerStatus(pickedUpPassenger, to: .droppedOff)
        
        let droppedOffPassenger = routeViewModel.passengers.first { $0.recid == originalRecid }
        XCTAssertNil(droppedOffPassenger, "Dropped off passenger should be removed from list")
        XCTAssertEqual(routeViewModel.passengers.count, originalCount - 1)
    }
    
    func testStatusNotificationForPickup() async throws {
        await routeViewModel.loadPassengers()
        
        guard let pendingPassenger = routeViewModel.passengers.first(where: { $0.status == .pending }) else {
            XCTFail("No pending passenger found for test")
            return
        }
        
        let expectation = XCTestExpectation(description: "Status notification shown")
        
        routeViewModel.$showStatusNotification
            .dropFirst()
            .sink { showNotification in
                if showNotification {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        await routeViewModel.updatePassengerStatus(pendingPassenger, to: .pickedUp)
        
        await fulfillment(of: [expectation], timeout: 2.0)
        
        XCTAssertTrue(routeViewModel.showStatusNotification)
        XCTAssertTrue(routeViewModel.statusNotificationMessage.contains("Successfully picked up"))
        XCTAssertTrue(routeViewModel.statusNotificationMessage.contains(pendingPassenger.name))
    }
    
    func testStatusNotificationForDropoff() async throws {
        await routeViewModel.loadPassengers()
        
        guard let pickedUpPassenger = routeViewModel.passengers.first(where: { $0.status == .pickedUp }) else {
            XCTFail("No picked up passenger found for test")
            return
        }
        
        let expectation = XCTestExpectation(description: "Status notification shown")
        
        routeViewModel.$showStatusNotification
            .dropFirst()
            .sink { showNotification in
                if showNotification {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        await routeViewModel.updatePassengerStatus(pickedUpPassenger, to: .droppedOff)
        
        await fulfillment(of: [expectation], timeout: 2.0)
        
        XCTAssertTrue(routeViewModel.showStatusNotification)
        XCTAssertTrue(routeViewModel.statusNotificationMessage.contains("Successfully dropped off"))
        XCTAssertTrue(routeViewModel.statusNotificationMessage.contains(pickedUpPassenger.name))
    }
    
    func testForceRefresh() async throws {
        let expectation = XCTestExpectation(description: "Force refresh completed")
        
        routeViewModel.$passengers
            .dropFirst()
            .sink { passengers in
                if !passengers.isEmpty {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        await routeViewModel.forceRefresh()
        
        await fulfillment(of: [expectation], timeout: 2.0)
        
        XCTAssertFalse(routeViewModel.passengers.isEmpty)
        XCTAssertFalse(routeViewModel.isLoading)
    }
    
    func testLastSyncTimeUpdate() async throws {
        let beforeSync = Date()
        
        await routeViewModel.loadPassengers()
        
        let afterSync = Date()
        
        XCTAssertGreaterThanOrEqual(routeViewModel.lastSyncTime, beforeSync)
        XCTAssertLessThanOrEqual(routeViewModel.lastSyncTime, afterSync)
    }
}