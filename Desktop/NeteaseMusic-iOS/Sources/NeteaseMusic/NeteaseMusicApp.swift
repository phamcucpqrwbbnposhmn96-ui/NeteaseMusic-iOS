import SwiftUI

@main
struct NeteaseMusicApp: App {
    @StateObject private var authViewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            Group {
                if authViewModel.isLoggedIn, authViewModel.currentUser != nil {
                    MainTabView()
                        .environmentObject(authViewModel)
                        .environmentObject(PlayerManager.shared)
                } else {
                    LoginView()
                        .environmentObject(authViewModel)
                }
            }
        }
    }
}
