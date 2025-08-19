# Implementation Plan

- [x] 1. Update Constants and Base Configuration

  - Update Constants.swift to use the actual backend URL (http://advantecis-csmwebservicebus.com)
  - Add proper API endpoint paths and configuration values
  - Remove placeholder comments and set production-ready values
  - _Requirements: 1.1, 7.1_

- [ ] 2. Enhance Data Models for Backend Integration

  - [x] 2.1 Create API Response Models

    - Implement LoginResponse, StatusUpdateResponse, and APIError models
    - Add proper Codable conformance with correct JSON key mapping
    - Write unit tests for model serialization/deserialization
    - _Requirements: 1.1, 1.2, 2.1_

  - [x] 2.2 Update User Model for Backend Data

    - Extend User model to include additional fields from backend (driverName, sessionId)
    - Ensure Codable conformance matches backend API response format
    - Write unit tests for User model updates
    - _Requirements: 1.2, 1.5_

  - [x] 2.3 Enhance Passenger Model with Backend Fields
    - Add homeAddress field and other backend-specific properties
    - Implement computed properties for UI display (displayPickupTime, displayDropoffTime, hasSpecialNeeds)
    - Add validation methods for data integrity
    - Write unit tests for enhanced Passenger model
    - _Requirements: 2.2, 2.4, 5.2_

- [x] 3. Implement Enhanced DataService for Token Management

  - [x] 3.1 Add Secure Token Storage Methods

    - Implement saveAuthToken with expiration date support
    - Create getAuthToken method that returns token and expiration
    - Add isTokenValid method to check token expiration
    - Write unit tests for token management functionality
    - _Requirements: 1.3, 7.2_

  - [x] 3.2 Enhance Session Management
    - Update saveUserSession to include routeId
    - Add getCurrentRouteId method for route-specific operations
    - Implement session validation and cleanup methods
    - Write unit tests for enhanced session management
    - _Requirements: 1.5, 1.6_

- [x] 4. Implement Real NetworkService API Integration

  - [x] 4.1 Create HTTP Request Infrastructure

    - Implement buildRequest method for creating URLRequest objects with proper headers
    - Add handleResponse method for parsing API responses and handling errors
    - Create RetryManager class for handling network failures with exponential backoff
    - Write unit tests for request building and response handling
    - _Requirements: 7.1, 8.1, 8.2_

  - [x] 4.2 Implement Authentication API Integration

    - Replace mock login method with real HTTP POST to /business/login
    - Handle LoginResponse parsing and token extraction
    - Implement proper error handling for authentication failures
    - Add token storage integration with DataService
    - Write unit tests for authentication flow
    - _Requirements: 1.1, 1.2, 1.3, 1.4_

  - [x] 4.3 Implement Passenger Data Fetching

    - Replace mock fetchPassengers with real HTTP GET to /business/getdriverevents
    - Add route-based passenger filtering using tenantId parameter
    - Implement proper error handling and response validation
    - Add 20-passenger limit enforcement as specified
    - Write unit tests for passenger data retrieval
    - _Requirements: 2.1, 2.2, 2.3_

  - [x] 4.4 Implement Status Update API Integration
    - Replace mock updatePassengerStatus with real HTTP POST to /business/updatedrivereventstatus
    - Ensure proper StatusUpdate JSON serialization with GPS coordinates
    - Add response validation and error handling
    - Implement success/failure feedback mechanisms
    - Write unit tests for status update functionality
    - _Requirements: 3.1, 3.2, 3.4_

- [x] 5. Update ViewModels for Backend Integration

  - [x] 5.1 Enhance AuthViewModel for Real Authentication

    - Update login method to handle LoginResponse and extract routeId
    - Implement session persistence using enhanced DataService methods
    - Add checkExistingSession method for app startup authentication
    - Update error handling to display backend-specific error messages
    - Write unit tests for enhanced AuthViewModel
    - _Requirements: 1.1, 1.2, 1.5, 1.6_

  - [x] 5.2 Update RouteViewModel for Real Data Operations
    - Modify loadPassengers to use routeId from authentication
    - Update updatePassengerStatus to handle real API responses and GPS validation
    - Implement forceRefresh functionality with backend data re-fetching
    - Add proper loading states and error handling for all operations
    - Write unit tests for enhanced RouteViewModel
    - _Requirements: 2.1, 2.6, 3.1, 3.3, 3.6_

- [x] 6. Implement GPS Location Validation

  - [x] 6.1 Add Location Requirement Validation

    - Update LocationService to provide location availability checking
    - Implement GPS validation before allowing status updates
    - Add user-friendly error messages when location is unavailable
    - Create location permission handling and user guidance
    - Write unit tests for location validation logic
    - _Requirements: 3.3, 8.5_

  - [x] 6.2 Integrate Location Validation with Status Updates
    - Update RouteViewModel to check GPS availability before status updates
    - Implement error handling and user feedback for location failures
    - Add retry mechanisms when location becomes available
    - Ensure status updates are blocked without valid GPS coordinates
    - Write integration tests for location-dependent status updates
    - _Requirements: 3.3, 8.5_

- [x] 7. Implement Data Synchronization and Refresh

  - [x] 7.1 Add Force Refresh Functionality

    - Implement backend data re-fetching in NetworkService
    - Update RouteViewModel to handle force refresh operations
    - Add loading indicators and user feedback for refresh operations
    - Ensure UI updates properly after data refresh
    - Write unit tests for force refresh functionality
    - _Requirements: 2.6, 6.3_

  - [x] 7.2 Implement Auto-Sync After Status Updates
    - Update status update flow to automatically re-fetch passenger data
    - Ensure UI sections update correctly after backend synchronization
    - Add proper error handling if sync fails after status update
    - Implement optimistic UI updates with rollback on failure
    - Write integration tests for status update and sync flow
    - _Requirements: 3.4, 4.4, 4.5_

- [x] 8. Add Comprehensive Error Handling and User Feedback

  - [x] 8.1 Implement Network Error Handling

    - Create comprehensive NetworkError enum with user-friendly messages
    - Add retry logic with exponential backoff for failed requests
    - Implement timeout handling and recovery strategies
    - Add network connectivity monitoring and user feedback
    - Write unit tests for error handling scenarios
    - _Requirements: 8.1, 8.2, 8.3_

  - [x] 8.2 Add User Interface Error Feedback
    - Update all ViewModels to display appropriate error messages
    - Implement loading indicators for all network operations
    - Add success notifications for completed operations
    - Create retry buttons and user-actionable error recovery
    - Write UI tests for error handling and user feedback
    - _Requirements: 8.2, 8.4_

- [x] 9. Update UI Components for Backend Integration

  - [x] 9.1 Update Dashboard Sections for Real Data

    - Ensure "On the Bus" and "To Be Picked Up" sections work with backend data
    - Implement proper passenger movement between sections after status updates
    - Add visual feedback for successful status changes
    - Ensure passenger removal works correctly for dropped-off passengers
    - Write UI tests for dashboard section updates
    - _Requirements: 4.1, 4.2, 4.4, 4.5_

  - [x] 9.2 Update Passenger Detail View for Backend Data
    - Ensure passenger detail view displays all backend fields correctly
    - Add proper handling for optional fields (medical notes, contact info)
    - Implement wheelchair flag and special needs indicators
    - Ensure contact information is displayed when available
    - Write UI tests for passenger detail view with real data
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_

- [x] 10. Update Sync/Info Page for Backend Integration

  - [x] 10.1 Implement Real Sync Status Display

    - Update sync status to show actual last sync time from backend operations
    - Implement force refresh button functionality with backend integration
    - Add proper loading indicators during sync operations
    - Display app version and connection status information
    - Write unit tests for sync status functionality
    - _Requirements: 6.1, 6.2, 6.3, 6.4_

  - [x] 10.2 Implement Logout Functionality
    - Update logout button to clear backend authentication tokens
    - Ensure proper session cleanup and return to login screen
    - Clear all cached data and reset app state
    - Add confirmation dialog for logout action
    - Write integration tests for complete logout flow
    - _Requirements: 6.5, 1.6_

- [ ] 11. Write Integration Tests for Complete Backend Flow

  - [ ] 11.1 Create End-to-End Authentication Tests

    - Write tests for complete login flow with backend integration
    - Test session persistence and automatic re-authentication
    - Verify proper error handling for authentication failures
    - Test logout and session cleanup functionality
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6_

  - [ ] 11.2 Create End-to-End Data Flow Tests
    - Write tests for passenger data loading and display
    - Test complete status update flow with GPS and backend sync
    - Verify force refresh functionality works end-to-end
    - Test error scenarios and recovery mechanisms
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 3.1, 3.2, 3.3, 3.4, 3.5, 3.6_

- [ ] 12. Final Integration and Testing

  - [ ] 12.1 Remove All Mock Data and Placeholder Code

    - Remove all TODO comments and mock implementations
    - Ensure all NetworkService methods use real API calls
    - Clean up any development-only code or logging
    - Verify no mock data is displayed in production build
    - _Requirements: All requirements_

  - [ ] 12.2 Perform Complete System Testing
    - Test complete app workflow from login to passenger management
    - Verify all backend integrations work correctly
    - Test error scenarios and edge cases
    - Ensure app meets all client specifications
    - Perform final code review and cleanup
    - _Requirements: All requirements_
