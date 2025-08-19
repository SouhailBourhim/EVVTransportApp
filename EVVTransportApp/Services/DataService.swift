// DataService placeholder 
import Foundation
import Security

class DataService: ObservableObject {
    static let shared = DataService()
    
    private let userDefaults = UserDefaults.standard
    
    private init() {}
    
    // MARK: - Enhanced Session Management
    
    /// Saves user session with route ID and validation
    /// - Parameters:
    ///   - user: The user object to save
    ///   - routeId: The route ID associated with the user
    func saveUserSession(_ user: User, routeId: String) {
        // Validate input
        guard !routeId.isEmpty else {
            print("❌ Cannot save session: routeId is empty")
            return
        }
        
        // Encode and save user data
        if let encoded = try? JSONEncoder().encode(user) {
            userDefaults.set(encoded, forKey: Constants.UserDefaultsKeys.currentUser)
        } else {
            print("❌ Failed to encode user data")
            return
        }
        
        // Save route and session information
        userDefaults.set(routeId, forKey: Constants.UserDefaultsKeys.currentRouteId)
        userDefaults.set(user.sessionId, forKey: Constants.UserDefaultsKeys.sessionId)
        
        // Save session creation timestamp
        userDefaults.set(Date(), forKey: "sessionCreatedAt")
        
        print("✅ User session saved successfully for route: \(routeId)")
    }
    
    /// Loads user session with validation
    /// - Returns: User object if valid session exists, nil otherwise
    func loadUserSession() -> User? {
        guard let data = userDefaults.data(forKey: Constants.UserDefaultsKeys.currentUser),
              let user = try? JSONDecoder().decode(User.self, from: data) else {
            print("❌ No valid user session found")
            return nil
        }
        
        // Validate session
        guard isSessionValid() else {
            print("❌ Session validation failed, clearing session")
            clearUserSession()
            return nil
        }
        
        return user
    }
    
    /// Gets current route ID with validation
    /// - Returns: Route ID if valid session exists, nil otherwise
    func getCurrentRouteId() -> String? {
        guard isSessionValid() else {
            print("❌ Session invalid, cannot get route ID")
            return nil
        }
        
        return userDefaults.string(forKey: Constants.UserDefaultsKeys.currentRouteId)
    }
    
    /// Gets current session ID
    /// - Returns: Session ID if available, nil otherwise
    func getCurrentSessionId() -> String? {
        return userDefaults.string(forKey: Constants.UserDefaultsKeys.sessionId)
    }
    
    /// Validates current session integrity
    /// - Returns: True if session is valid and complete
    func isSessionValid() -> Bool {
        // Check if user data exists
        guard let userData = userDefaults.data(forKey: Constants.UserDefaultsKeys.currentUser),
              let _ = try? JSONDecoder().decode(User.self, from: userData) else {
            return false
        }
        
        // Check if route ID exists
        guard let routeId = userDefaults.string(forKey: Constants.UserDefaultsKeys.currentRouteId),
              !routeId.isEmpty else {
            return false
        }
        
        // Check if session ID exists
        guard let sessionId = userDefaults.string(forKey: Constants.UserDefaultsKeys.sessionId),
              !sessionId.isEmpty else {
            return false
        }
        
        // Check if token is valid
        guard isTokenValid() else {
            return false
        }
        
        return true
    }
    
    /// Gets session metadata for debugging/analytics
    /// - Returns: Dictionary with session information
    func getSessionMetadata() -> [String: Any] {
        var metadata: [String: Any] = [:]
        
        metadata["hasUser"] = loadUserSession() != nil
        metadata["hasRouteId"] = getCurrentRouteId() != nil
        metadata["hasSessionId"] = getCurrentSessionId() != nil
        metadata["isValid"] = isSessionValid()
        metadata["hasValidToken"] = isTokenValid()
        
        if let user = loadUserSession() {
            metadata["username"] = user.username
            metadata["driverName"] = user.driverName
        }
        
        if let routeId = getCurrentRouteId() {
            metadata["routeId"] = routeId
        }
        
        if let sessionId = getCurrentSessionId() {
            metadata["sessionId"] = sessionId
        }
        
        if let createdAt = userDefaults.object(forKey: "sessionCreatedAt") as? Date {
            metadata["sessionCreatedAt"] = createdAt
            metadata["sessionAge"] = Date().timeIntervalSince(createdAt)
        }
        
        return metadata
    }
    
    /// Clears user session and related data
    func clearUserSession() {
        userDefaults.removeObject(forKey: Constants.UserDefaultsKeys.currentUser)
        userDefaults.removeObject(forKey: Constants.UserDefaultsKeys.currentRouteId)
        userDefaults.removeObject(forKey: Constants.UserDefaultsKeys.sessionId)
        userDefaults.removeObject(forKey: "sessionCreatedAt")
        
        print("✅ User session cleared successfully")
    }
    
    /// Updates route ID for current session
    /// - Parameter newRouteId: New route ID to set
    func updateRouteId(_ newRouteId: String) {
        guard !newRouteId.isEmpty else {
            print("❌ Cannot update route ID: new route ID is empty")
            return
        }
        
        guard isSessionValid() else {
            print("❌ Cannot update route ID: session is not valid")
            return
        }
        
        userDefaults.set(newRouteId, forKey: Constants.UserDefaultsKeys.currentRouteId)
        print("✅ Route ID updated to: \(newRouteId)")
    }
    
    /// Validates and cleans up expired sessions
    func validateAndCleanupSessions() {
        if !isSessionValid() {
            print("⚠️ Invalid session detected, cleaning up...")
            clearUserSession()
            deleteAuthToken()
        }
    }
    
    // MARK: - App Preferences
    func saveLastSyncTime(_ date: Date) {
        userDefaults.set(date, forKey: "lastSyncTime")
    }
    
    func getLastSyncTime() -> Date {
        return userDefaults.object(forKey: "lastSyncTime") as? Date ?? Date()
    }
    
    // MARK: - Enhanced Secure Token Storage (Keychain)
    
    /// Saves authentication token to Keychain with expiration date support
    /// - Parameters:
    ///   - token: The authentication token to store
    ///   - expiresAt: Optional expiration date (defaults to 24 hours from now)
    ///   - userId: Optional user ID for token association
    func saveAuthToken(_ token: String, expiresAt: Date? = nil, userId: String? = nil) {
        let expirationDate = expiresAt ?? Date().addingTimeInterval(86400) // 24 hours default
        
        // Prepare token data with metadata
        var tokenData = token.data(using: .utf8)!
        
        // Create token info dictionary for additional metadata
        let tokenInfo: [String: Any] = [
            "token": token,
            "expiresAt": expirationDate.timeIntervalSince1970,
            "createdAt": Date().timeIntervalSince1970,
            "userId": userId ?? ""
        ]
        
        if let infoData = try? JSONSerialization.data(withJSONObject: tokenInfo) {
            tokenData = infoData
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: Constants.UserDefaultsKeys.authToken,
            kSecValueData as String: tokenData,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        // Delete existing token first
        SecItemDelete(query as CFDictionary)
        
        // Save new token
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecSuccess {
            // Save expiration date in UserDefaults for quick access
            userDefaults.set(expirationDate, forKey: Constants.UserDefaultsKeys.tokenExpiration)
            userDefaults.set(userId, forKey: "tokenUserId")
            print("✅ Auth token saved successfully")
        } else {
            print("❌ Failed to save auth token: \(status)")
        }
    }
    
    /// Retrieves authentication token from Keychain with validation
    /// - Returns: The authentication token if valid, nil otherwise
    func getAuthToken() -> String? {
        // Check if token is expired first
        if isTokenExpired() {
            print("⚠️ Token is expired, deleting...")
            deleteAuthToken()
            return nil
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: Constants.UserDefaultsKeys.authToken,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == noErr {
            if let data = dataTypeRef as? Data {
                // Try to parse as token info first
                if let tokenInfo = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let token = tokenInfo["token"] as? String {
                    return token
                }
                
                // Fallback to direct token data
                if let token = String(data: data, encoding: .utf8) {
                    return token
                }
            }
        } else {
            print("❌ Failed to retrieve auth token: \(status)")
        }
        
        return nil
    }
    
    /// Gets token with expiration information
    /// - Returns: Tuple containing token and expiration date, or nil if not found
    func getAuthTokenWithExpiration() -> (token: String, expiresAt: Date)? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: Constants.UserDefaultsKeys.authToken,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == noErr {
            if let data = dataTypeRef as? Data {
                // Try to parse as token info
                if let tokenInfo = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let token = tokenInfo["token"] as? String,
                   let expiresAtInterval = tokenInfo["expiresAt"] as? TimeInterval {
                    let expiresAt = Date(timeIntervalSince1970: expiresAtInterval)
                    return (token: token, expiresAt: expiresAt)
                }
                
                // Fallback to UserDefaults expiration
                if let token = String(data: data, encoding: .utf8),
                   let expirationDate = userDefaults.object(forKey: Constants.UserDefaultsKeys.tokenExpiration) as? Date {
                    return (token: token, expiresAt: expirationDate)
                }
            }
        }
        
        return nil
    }
    
    /// Checks if the current authentication token is valid and not expired
    /// - Returns: True if token exists and is not expired
    func isTokenValid() -> Bool {
        guard let token = getAuthToken(), !token.isEmpty else {
            return false
        }
        
        return !isTokenExpired()
    }
    
    /// Checks if the token will expire within the buffer time
    /// - Returns: True if token will expire soon
    func isTokenExpiringSoon() -> Bool {
        guard let expirationDate = getTokenExpirationDate() else {
            return true
        }
        
        let bufferTime = Constants.API.tokenExpirationBuffer
        return Date().addingTimeInterval(bufferTime) >= expirationDate
    }
    
    /// Gets the token expiration date
    /// - Returns: The expiration date if available, nil otherwise
    func getTokenExpirationDate() -> Date? {
        // First try to get from token info
        if let (_, expiresAt) = getAuthTokenWithExpiration() {
            return expiresAt
        }
        
        // Fallback to UserDefaults
        return userDefaults.object(forKey: Constants.UserDefaultsKeys.tokenExpiration) as? Date
    }
    
    /// Gets time remaining until token expiration
    /// - Returns: Time interval remaining, or 0 if expired/not found
    func getTokenTimeRemaining() -> TimeInterval {
        guard let expirationDate = getTokenExpirationDate() else {
            return 0
        }
        
        let remaining = expirationDate.timeIntervalSince(Date())
        return max(0, remaining)
    }
    
    /// Private method to check if token is expired
    private func isTokenExpired() -> Bool {
        guard let expirationDate = getTokenExpirationDate() else {
            return true
        }
        
        return Date() >= expirationDate
    }
    
    /// Deletes the authentication token from Keychain
    func deleteAuthToken() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: Constants.UserDefaultsKeys.authToken
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        if status == errSecSuccess || status == errSecItemNotFound {
            // Clean up UserDefaults
            userDefaults.removeObject(forKey: Constants.UserDefaultsKeys.tokenExpiration)
            userDefaults.removeObject(forKey: "tokenUserId")
            print("✅ Auth token deleted successfully")
        } else {
            print("❌ Failed to delete auth token: \(status)")
        }
    }
    
    /// Refreshes token expiration (useful for extending session)
    /// - Parameter newExpirationDate: New expiration date
    func refreshTokenExpiration(_ newExpirationDate: Date) {
        guard let currentToken = getAuthToken() else {
            print("❌ No token to refresh")
            return
        }
        
        let userId = userDefaults.string(forKey: "tokenUserId")
        saveAuthToken(currentToken, expiresAt: newExpirationDate, userId: userId)
        print("✅ Token expiration refreshed to: \(newExpirationDate)")
    }
    
    /// Gets token metadata for debugging/analytics
    /// - Returns: Dictionary with token metadata
    func getTokenMetadata() -> [String: Any] {
        var metadata: [String: Any] = [:]
        
        metadata["hasToken"] = getAuthToken() != nil
        metadata["isValid"] = isTokenValid()
        metadata["isExpiringSoon"] = isTokenExpiringSoon()
        
        if let expirationDate = getTokenExpirationDate() {
            metadata["expiresAt"] = expirationDate
            metadata["timeRemaining"] = getTokenTimeRemaining()
        }
        
        metadata["userId"] = userDefaults.string(forKey: "tokenUserId")
        
        return metadata
    }
    
    // MARK: - App Settings
    func saveAppSettings() {
        // Save any app-specific settings here
        userDefaults.set(true, forKey: "hasCompletedOnboarding")
    }
    
    func hasCompletedOnboarding() -> Bool {
        return userDefaults.bool(forKey: "hasCompletedOnboarding")
    }
    
    // MARK: - Clear All Data
    func clearAllData() {
        clearUserSession()
        deleteAuthToken()
        userDefaults.removeObject(forKey: "lastSyncTime")
        userDefaults.removeObject(forKey: "hasCompletedOnboarding")
    }
}
