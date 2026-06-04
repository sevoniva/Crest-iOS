import SwiftUI

@main
struct CrestIOSApp: App {
    @State private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if appState.isLoggedIn {
                    DashboardListView(token: appState.token ?? "")
                } else {
                    LoginView()
                }
            }
            .environment(appState)
        }
    }
}
