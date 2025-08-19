# Requirements Document

## Introduction

This feature involves integrating the existing iOS EVV Transport App with an ASP.NET backend server running on IIS with Microsoft SQL Server. The app currently uses mock data and needs to be connected to real REST API endpoints for authentication, route assignment, passenger data retrieval, and real-time status updates. The integration must support the complete driver workflow from login through passenger pickup and drop-off with GPS tracking and timestamp logging.

## Requirements

### Requirement 1

**User Story:** As a driver, I want to authenticate with the backend system using my username and password, so that I can be automatically assigned a route and access my passenger data securely.

#### Acceptance Criteria

1. WHEN a driver enters valid credentials THEN the system SHALL authenticate against the ASP.NET backend REST API
2. WHEN authentication is successful THEN the system SHALL automatically assign a route to the driver for the current session
3. WHEN authentication is successful THEN the system SHALL store the authentication token securely in the iOS keychain
4. WHEN authentication fails THEN the system SHALL display clear error messages to the user
5. IF the driver logs out and logs in again THEN the system SHALL assign a new route dynamically
6. WHEN the user logs out THEN the system SHALL clear all stored authentication data and return to login screen

### Requirement 2

**User Story:** As a driver, I want to retrieve my assigned passengers from the backend system after login, so that I can see real-time passenger information with pickup locations, destinations, and scheduled times.

#### Acceptance Criteria

1. WHEN authentication is successful THEN the system SHALL fetch passenger data from the backend REST API
2. WHEN passenger data is retrieved THEN the system SHALL replace mock data with real passenger information
3. WHEN passenger data is fetched THEN the system SHALL never display more than 20 passengers total
4. WHEN passenger data includes medical notes, wheelchair flags, and contact info THEN the system SHALL display this information in passenger details
5. IF the network request fails THEN the system SHALL display appropriate error messages with retry options
6. WHEN the Force Refresh button is pressed THEN the system SHALL re-fetch all route and passenger data from the backend

### Requirement 3

**User Story:** As a driver, I want to send passenger status updates to the backend system with GPS coordinates and timestamps, so that the dispatch office can track pickup and drop-off status in real-time.

#### Acceptance Criteria

1. WHEN a driver marks a passenger as "picked up" THEN the system SHALL send a status update to the backend with recid, status="picked up", datetime (ISO format), latitude, and longitude
2. WHEN a driver marks a passenger as "dropped off" THEN the system SHALL send a status update to the backend with recid, status="dropped off", datetime (ISO format), latitude, and longitude
3. WHEN GPS location is unavailable THEN the system SHALL display an error prompt and prevent the status update
4. WHEN a status update is successfully sent THEN the system SHALL re-fetch passenger data to keep UI in sync
5. WHEN a passenger is marked as picked up THEN the system SHALL move them from "To Be Picked Up" section to "On the Bus" section
6. WHEN a passenger is marked as dropped off THEN the system SHALL remove them entirely from both sections

### Requirement 4

**User Story:** As a driver, I want the main dashboard to clearly separate passengers into "On the Bus" and "To Be Picked Up" sections, so that I can easily manage my route workflow.

#### Acceptance Criteria

1. WHEN the dashboard loads THEN the system SHALL display passengers in two vertical sections
2. WHEN displaying "On the Bus" passengers THEN the system SHALL show client name, destination, scheduled drop-off time, and "Mark as Dropped Off" button
3. WHEN displaying "To Be Picked Up" passengers THEN the system SHALL show client name, pickup location, scheduled pickup time, and "Mark as Picked Up" button
4. WHEN either section has many passengers THEN the system SHALL handle scrolling gracefully with large text and touch targets
5. WHEN passengers change status THEN the system SHALL update the UI sections instantly with visual feedback

### Requirement 5

**User Story:** As a driver, I want to access detailed passenger information, so that I can view medical notes, contact information, and accessibility requirements.

#### Acceptance Criteria

1. WHEN a driver taps on a passenger name THEN the system SHALL open a passenger detail view
2. WHEN the passenger detail view opens THEN the system SHALL display full name, home address, drop-off location, medical/emergency notes, wheelchair flag, and contact info
3. WHEN medical notes are available THEN the system SHALL prominently display them for driver awareness
4. WHEN wheelchair accessibility is required THEN the system SHALL clearly indicate this with appropriate visual indicators
5. WHEN contact information is available THEN the system SHALL display it for emergency communication

### Requirement 6

**User Story:** As a driver, I want to access a sync/info page to monitor app status and force data refresh, so that I can ensure my data is current and troubleshoot connectivity issues.

#### Acceptance Criteria

1. WHEN the sync/info page is accessed THEN the system SHALL display app version number
2. WHEN the sync/info page is accessed THEN the system SHALL show sync status indicator with "Last Synced at [time]"
3. WHEN the "Force Refresh" button is pressed THEN the system SHALL re-fetch all route and passenger data from the backend
4. WHEN the logout button is pressed THEN the system SHALL end the current session and return to login screen
5. WHEN sync operations are in progress THEN the system SHALL display appropriate loading indicators

### Requirement 7

**User Story:** As a system administrator, I want the app to communicate securely with the ASP.NET backend using HTTPS and proper authentication, so that passenger data and driver information are protected.

#### Acceptance Criteria

1. WHEN making API requests THEN the system SHALL use HTTPS for all communications with the IIS backend
2. WHEN sending authentication tokens THEN the system SHALL include them in secure HTTP headers
3. WHEN storing sensitive data THEN the system SHALL use iOS keychain for secure token storage
4. WHEN handling API responses THEN the system SHALL validate response integrity and format
5. WHEN session expires THEN the system SHALL prompt for re-authentication and clear stored credentials

### Requirement 8

**User Story:** As a driver, I want the app to handle network connectivity issues gracefully with proper error handling and retry mechanisms, so that I can continue working with intermittent internet connection.

#### Acceptance Criteria

1. WHEN network requests timeout THEN the system SHALL retry with appropriate backoff strategies
2. WHEN network errors occur THEN the system SHALL provide clear, actionable error messages to the user
3. WHEN API calls fail THEN the system SHALL offer retry options to the driver
4. WHEN connectivity issues persist THEN the system SHALL maintain app functionality using cached data where possible
5. WHEN location services are unavailable THEN the system SHALL prevent status updates and display appropriate error messages