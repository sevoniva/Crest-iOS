import SwiftUI

@main
struct CrestIOSApp: App {
    @State private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if appState.isLoggedIn {
                    DashboardListView(token: appState.token ?? "")
                        .transition(.opacity)
                } else {
                    LoginView()
                        .transition(.opacity)
                }
            }
            .environment(appState)
            .animation(.easeInOut(duration: 0.3), value: appState.isLoggedIn)
        }
    }
}
