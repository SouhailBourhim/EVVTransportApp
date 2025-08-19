//
//  TestHelpers.swift
//  EVVTransportAppTests
//
//  Created by Souhail Bourhim on 23/07/2025.
//

import Foundation
import XCTest
@testable import EVVTransportApp

// MARK: - Test Helpers

func createMockPassenger(
    recid: String = "123",
    name: String = "Test Passenger",
    address: String = "123 Test St",
    status: PassengerStatus = .pending,
    contactInfo: String? = "(555) 123-4567",
    gender: Int = 1,
    city: String = "Test City"
) -> Passenger {
    return Passenger(
        recid: recid,
        name: name,
        address: address,
        status: status,
        contactInfo: contactInfo,
        gender: gender,
        city: city
    )
}

func createMockPassengers(count: Int) -> [Passenger] {
    return (0..<count).map { index in
        Passenger(
            recid: "\(index + 1)",
            name: "Passenger \(index + 1)",
            address: "\(index + 1) Test St",
            status: index % 3 == 0 ? .pickedUp : .pending,
            contactInfo: index % 2 == 0 ? "(555) 123-\(String(format: "%04d", index))" : nil,
            gender: index % 2,
            city: "City \(index + 1)"
        )
    }
}

// MARK: - Test Expectations Helper

class TestExpectationHelper {
    
    static func waitForPublisher<T>(
        _ publisher: Published<T>.Publisher,
        timeout: TimeInterval = 2.0,
        condition: @escaping (T) -> Bool
    ) -> XCTestExpectation {
        let expectation = XCTestExpectation(description: "Publisher condition met")
        
        let cancellable = publisher
            .sink { value in
                if condition(value) {
                    expectation.fulfill()
                }
            }
        
        // Keep cancellable alive
        DispatchQueue.main.asyncAfter(deadline: .now() + timeout) {
            _ = cancellable
        }
        
        return expectation
    }
}

// MARK: - Async Test Helpers

extension XCTestCase {
    
    func waitForAsync<T>(
        timeout: TimeInterval = 2.0,
        operation: @escaping () async throws -> T
    ) async throws -> T {
        return try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                return try await operation()
            }
            
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
                throw TimeoutError()
            }
            
            let result = try await group.next()!
            group.cancelAll()
            return result
        }
    }
    
    struct TimeoutError: Error {}
}

// MARK: - Date Testing Helpers

extension Date {
    
    static func testDate(
        year: Int = 2025,
        month: Int = 1,
        day: Int = 1,
        hour: Int = 12,
        minute: Int = 0
    ) -> Date {
        let calendar = Calendar.current
        let components = DateComponents(
            year: year,
            month: month,
            day: day,
            hour: hour,
            minute: minute
        )
        return calendar.date(from: components) ?? Date()
    }
    
    func isApproximatelyEqual(to other: Date, within seconds: TimeInterval = 1.0) -> Bool {
        return abs(self.timeIntervalSince(other)) <= seconds
    }
}

// MARK: - UserDefaults Testing Helper

class TestUserDefaults: UserDefaults {
    
    private var storage: [String: Any] = [:]
    
    override func set(_ value: Any?, forKey defaultName: String) {
        storage[defaultName] = value
    }
    
    override func object(forKey defaultName: String) -> Any? {
        return storage[defaultName]
    }
    
    override func data(forKey defaultName: String) -> Data? {
        return storage[defaultName] as? Data
    }
    
    override func bool(forKey defaultName: String) -> Bool {
        return storage[defaultName] as? Bool ?? false
    }
    
    override func removeObject(forKey defaultName: String) {
        storage.removeValue(forKey: defaultName)
    }
    
    func clearAll() {
        storage.removeAll()
    }
}

// MARK: - Network Testing Helpers

class MockNetworkService: NetworkService {
    
    var shouldFailLogin = false
    var shouldFailFetchPassengers = false
    var shouldFailStatusUpdate = false
    var mockPassengers: [Passenger] = []
    
    override func login(username: String, password: String) async throws -> User {
        if shouldFailLogin {
            throw NetworkError.invalidCredentials
        }
        
        if username.isEmpty || password.isEmpty {
            throw NetworkError.invalidCredentials
        }
        
        return User(username: username, routeId: "ROUTE_001", driverName: "Test Driver", sessionId: "session_test")
    }
    
    override func fetchPassengers(routeId: String) async throws -> [Passenger] {
        if shouldFailFetchPassengers {
            throw NetworkError.networkFailure
        }
        
        return mockPassengers.isEmpty ? createMockPassengers(count: 5) : mockPassengers
    }
    
    override func updatePassengerStatus(_ statusUpdate: StatusUpdate) async throws -> Bool {
        if shouldFailStatusUpdate {
            throw NetworkError.networkFailure
        }
        
        // Simulate successful update
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        return true
    }
}

// MARK: - Location Testing Helpers

import CoreLocation

class MockLocationService: LocationService {
    
    var mockLocation: CLLocation?
    var shouldFailLocation = false
    
    override func getCurrentLocation() async -> CLLocation? {
        if shouldFailLocation {
            return nil
        }
        
        return mockLocation ?? CLLocation(latitude: 40.7128, longitude: -74.0060)
    }
}

// MARK: - Test Assertions

extension XCTestCase {
    
    func XCTAssertEqualWithAccuracy<T: FloatingPoint>(
        _ expression1: T,
        _ expression2: T,
        accuracy: T,
        _ message: String = "",
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let difference = abs(expression1 - expression2)
        XCTAssertLessThanOrEqual(
            difference,
            accuracy,
            message.isEmpty ? "Values \(expression1) and \(expression2) are not equal within accuracy \(accuracy)" : message,
            file: file,
            line: line
        )
    }
    
    func XCTAssertNotEmpty<T: Collection>(
        _ collection: T,
        _ message: String = "Collection should not be empty",
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertFalse(collection.isEmpty, message, file: file, line: line)
    }
    
    func XCTAssertContains<T: Collection>(
        _ collection: T,
        _ element: T.Element,
        _ message: String = "",
        file: StaticString = #filePath,
        line: UInt = #line
    ) where T.Element: Equatable {
        XCTAssertTrue(
            collection.contains(element),
            message.isEmpty ? "Collection does not contain \(element)" : message,
            file: file,
            line: line
        )
    }
}