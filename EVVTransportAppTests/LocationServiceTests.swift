//
//  LocationServiceTests.swift
//  EVVTransportAppTests
//
//  Created by Souhail Bourhim on 23/07/2025.
//

import XCTest
import CoreLocation
@testable import EVVTransportApp

@MainActor
final class LocationServiceTests: XCTestCase {
    
    var locationService: LocationService!
    
    override func setUpWithError() throws {
        locationService = LocationService.shared
    }
    
    override func tearDownWithError() throws {
        locationService = nil
    }
    
    func testLocationServiceSingleton() throws {
        let instance1 = LocationService.shared
        let instance2 = LocationService.shared
        
        XCTAssertTrue(instance1 === instance2, "LocationService should be a singleton")
    }
    
    func testInitialAuthorizationStatus() throws {
        // Initial status should be notDetermined or the current system status
        let status = locationService.authorizationStatus
        XCTAssertTrue([
            .notDetermined,
            .denied,
            .restricted,
            .authorizedWhenInUse,
            .authorizedAlways
        ].contains(status))
    }
    
    func testGetCurrentLocationWithoutPermission() async throws {
        // When permission is not granted, should return mock location
        let location = await locationService.getCurrentLocation()
        
        XCTAssertNotNil(location)
        
        // Should return Bronx coordinates (mock location)
        if let location = location {
            XCTAssertEqualWithAccuracy(location.coordinate.latitude, 40.8448, accuracy: 0.1)
            XCTAssertEqualWithAccuracy(location.coordinate.longitude, -73.8648, accuracy: 0.1)
        }
    }
    
    func testGetCurrentLocationTimeout() async throws {
        // Test that location request doesn't hang indefinitely
        let startTime = Date()
        let location = await locationService.getCurrentLocation()
        let endTime = Date()
        
        let duration = endTime.timeIntervalSince(startTime)
        
        // Should complete within reasonable time (mock or timeout)
        XCTAssertLessThan(duration, 15.0, "Location request should complete within 15 seconds")
        XCTAssertNotNil(location, "Should return mock location on timeout")
    }
    
    func testLocationAccuracy() async throws {
        let location = await locationService.getCurrentLocation()
        
        XCTAssertNotNil(location)
        
        if let location = location {
            // Verify location has reasonable accuracy
            XCTAssertGreaterThan(location.horizontalAccuracy, -1, "Location should have valid accuracy")
            
            // Verify coordinates are within reasonable bounds (roughly NYC area)
            XCTAssertGreaterThan(location.coordinate.latitude, 40.0)
            XCTAssertLessThan(location.coordinate.latitude, 41.0)
            XCTAssertGreaterThan(location.coordinate.longitude, -75.0)
            XCTAssertLessThan(location.coordinate.longitude, -73.0)
        }
    }
    
    func testMultipleLocationRequests() async throws {
        // Test multiple concurrent location requests
        async let location1 = locationService.getCurrentLocation()
        async let location2 = locationService.getCurrentLocation()
        async let location3 = locationService.getCurrentLocation()
        
        let locations = await [location1, location2, location3]
        
        // All requests should return valid locations
        for location in locations {
            XCTAssertNotNil(location)
        }
        
        // Locations should be consistent (same mock location)
        if let first = locations[0], let second = locations[1], let third = locations[2] {
            XCTAssertEqualWithAccuracy(first.coordinate.latitude, second.coordinate.latitude, accuracy: 0.001)
            XCTAssertEqualWithAccuracy(second.coordinate.latitude, third.coordinate.latitude, accuracy: 0.001)
            XCTAssertEqualWithAccuracy(first.coordinate.longitude, second.coordinate.longitude, accuracy: 0.001)
            XCTAssertEqualWithAccuracy(second.coordinate.longitude, third.coordinate.longitude, accuracy: 0.001)
        }
    }
    
    func testLocationServicePublishedProperties() throws {
        // Test that published properties are accessible
        XCTAssertNotNil(locationService.authorizationStatus)
        
        // currentLocation might be nil initially
        // This is expected behavior
    }
    
    func testRequestLocationPermission() throws {
        // Test that requesting permission doesn't crash
        locationService.requestLocationPermission()
        
        // The actual permission dialog is handled by the system
        // We can only test that the method executes without error
    }
    
    func testLocationManagerSetup() throws {
        // Verify that the location service is properly initialized
        // This is mostly testing that initialization doesn't crash
        
        let newLocationService = LocationService()
        XCTAssertNotNil(newLocationService)
        XCTAssertNotNil(newLocationService.authorizationStatus)
    }
}