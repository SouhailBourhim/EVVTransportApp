// DataService placeholder 
import Foundation
import Security

class DataService: ObservableObject {
    static let shared = DataService()
    
    private let userDefaults = UserDefaults.standard
    
    private init() {}
    
    // MARK: - Session Management
    func saveUserSession(_ user: User) {
        if let encoded = try? JSONEncoder().encode(user) {
            userDefaults.set(encoded, forKey: "currentUser")
        }
    }
    
    func loadUserSession() -> User? {
        if let data = userDefaults.data(forKey: "currentUser"),
           let user = try? JSONDecoder().decode(User.self, from: data) {
            return user
        }
        return nil
    }
    
    func clearUserSession() {
        userDefaults.removeObject(forKey: "currentUser")
    }
    
    // MARK: - App Preferences
    func saveLastSyncTime(_ date: Date) {
        userDefaults.set(date, forKey: "lastSyncTime")
    }
    
    func getLastSyncTime() -> Date {
        return userDefaults.object(forKey: "lastSyncTime") as? Date ?? Date()
    }
    
    // MARK: - Secure Token Storage (Keychain)
    func saveAuthToken(_ token: String) {
        let data = token.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "authToken",
            kSecValueData as String: data
        ]
        
        // Delete existing token
        SecItemDelete(query as CFDictionary)
        
        // Save new token
        SecItemAdd(query as CFDictionary, nil)
    }
    
    func getAuthToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "authToken",
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == noErr {
            if let data = dataTypeRef as? Data {
                return String(data: data, encoding: .utf8)
            }
        }
        return nil
    }
    
    func deleteAuthToken() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "authToken"
        ]
        SecItemDelete(query as CFDictionary)
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
