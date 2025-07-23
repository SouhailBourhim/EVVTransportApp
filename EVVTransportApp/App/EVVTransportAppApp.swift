// EVVTransportAppApp main entry point placeholder
import SwiftUI

@main
struct EVVTransportAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(AuthViewModel())
                .environmentObject(RouteViewModel())
        }
    }
}
