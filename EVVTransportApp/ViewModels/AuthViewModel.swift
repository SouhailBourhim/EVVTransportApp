import SwiftUI
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    private let networkService = NetworkService.shared
    
    func login(username: String, password: String) async {
        isLoading = true
        errorMessage = ""
        
        do {
            let user = try await networkService.login(username: username, password: password)
            currentUser = user
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func logout() {
        currentUser = nil
        isAuthenticated = false
        errorMessage = ""
    }
}
