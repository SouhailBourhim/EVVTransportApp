import SwiftUI
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var currentRouteId: String?
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var showErrorAlert = false
    @Published var showSuccessMessage = false
    @Published var successMessage = ""
    
    private let networkService = NetworkService.shared
    private let dataService = DataService.shared
    
    func login(username: String, password: String) async {
        // Validate input
        guard !username.isEmpty && !password.isEmpty else {
            showError("Please enter both username and password")
            return
        }
        
        // Check network connectivity
        guard networkService.checkNetworkConnectivity() else {
            showError("No internet connection available")
            return
        }
        
        isLoading = true
        errorMessage = ""
        showErrorAlert = false
        showSuccessMessage = false
        
        do {
            let user = try await networkService.login(username: username, password: password)
            
            // Handle login success
            handleLoginSuccess(user)
            
        } catch let error as NetworkError {
            // Handle backend-specific error messages
            handleAuthError(error.errorDescription ?? Constants.ErrorMessages.loginFailed)
        } catch {
            // Handle generic errors
            handleAuthError(error.localizedDescription)
        }
        
        isLoading = false
    }
    
    func logout() {
        // Clear backend authentication
        networkService.clearAuthToken()
        dataService.clearAllData()
        
        // Clear local state
        currentUser = nil
        currentRouteId = nil
        isAuthenticated = false
        errorMessage = ""
        showErrorAlert = false
        showSuccessMessage = false
        successMessage = ""
        
        print("✅ User logged out successfully")
    }
    
    /// Clears session data without showing error messages (for silent cleanup)
    private func clearSessionSilently() {
        // Clear backend authentication
        networkService.clearAuthToken()
        dataService.clearAllData()
        
        // Clear local state
        currentUser = nil
        currentRouteId = nil
        isAuthenticated = false
        errorMessage = ""
        showErrorAlert = false
        showSuccessMessage = false
        successMessage = ""
        
        print("🔇 Session cleared silently")
    }
    
    func checkExistingSession() -> Bool {
        // Check if we have a valid token and user session
        guard dataService.isTokenValid(),
              let user = dataService.loadUserSession(),
              let routeId = dataService.getCurrentRouteId() else {
            // Clear any invalid session data silently (don't show error messages)
            clearSessionSilently()
            return false
        }
        
        // Restore session state
        currentUser = user
        currentRouteId = routeId
        isAuthenticated = true
        
        return true
    }
    
    // MARK: - Error and Success Handling
    
    private func showError(_ message: String) {
        errorMessage = message
        showErrorAlert = true
        print("❌ Auth error: \(message)")
    }
    
    private func showSuccess(_ message: String) {
        successMessage = message
        showSuccessMessage = true
        print("✅ Auth success: \(message)")
        
        // Hide success message after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                self.showSuccessMessage = false
            }
        }
    }
    
    func clearError() {
        errorMessage = ""
        showErrorAlert = false
    }
    
    // MARK: - Private Helper Methods
    
    private func handleLoginSuccess(_ user: User) {
        // Update local state
        currentUser = user
        currentRouteId = user.routeId
        isAuthenticated = true
        
        // Clear any previous error messages
        errorMessage = ""
        showErrorAlert = false
        
        // Show success message
        showSuccess("Welcome back, \(user.driverName ?? user.username)!")
        
        print("✅ Login successful for user: \(user.username)")
        print("   Route ID: \(user.routeId)")
        print("   Session ID: \(user.sessionId ?? "N/A")")
    }
    
    // MARK: - Session Validation
    
    func validateCurrentSession() -> Bool {
        guard isAuthenticated,
              currentUser != nil,
              currentRouteId != nil,
              dataService.isTokenValid() else {
            // Session is invalid, clear it
            logout()
            return false
        }
        
        return true
    }
    
    /// Handles authentication errors and clears invalid sessions
    func handleAuthError(_ error: String) {
        // Check if this is an access denied error
        if error.lowercased().contains("access denied") || 
           error.lowercased().contains("unauthorized") ||
           error.lowercased().contains("token") {
            // Clear the invalid session
            logout()
            showError("Session expired. Please log in again.")
        } else {
            showError(error)
        }
    }
    
    /// Handles authentication errors without showing messages (for silent handling)
    func handleAuthErrorSilently(_ error: String) {
        // Check if this is an access denied error
        if error.lowercased().contains("access denied") || 
           error.lowercased().contains("unauthorized") ||
           error.lowercased().contains("token") {
            // Clear the invalid session silently
            clearSessionSilently()
        }
        // Don't show any error messages
    }
    
    // MARK: - Route Management
    
    func getCurrentRouteId() -> String? {
        return currentRouteId ?? dataService.getCurrentRouteId()
    }
    
    func updateRouteId(_ newRouteId: String) {
        currentRouteId = newRouteId
        dataService.saveUserSession(currentUser!, routeId: newRouteId)
    }
}
