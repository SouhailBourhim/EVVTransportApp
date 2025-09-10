import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        GeometryReader { geometry in
            Group {
                if authViewModel.isAuthenticated {
                    DashboardView()
                } else {
                    LoginView()
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .hideStatusBar()
        .ignoresSafeArea(.all)
        .edgesIgnoringSafeArea(.all)
    }
}

// Custom view modifier to ensure status bar is hidden
struct StatusBarHiddenModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .statusBarHidden()
            .background(Color.clear)
            .onAppear {
                // Force status bar update through view hierarchy
                DispatchQueue.main.async {
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.first {
                        window.rootViewController?.setNeedsStatusBarAppearanceUpdate()
                    }
                }
            }
    }
}

extension View {
    func hideStatusBar() -> some View {
        self.modifier(StatusBarHiddenModifier())
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
        .environmentObject(RouteViewModel())
}
