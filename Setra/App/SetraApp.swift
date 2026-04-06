import SwiftUI

@main
struct SetraApp: App {
    private let container: AppContainer
    @StateObject private var authController: AuthController
    @StateObject private var workspaceStore: WorkspaceStore

    init() {
        let container = AppContainer.bootstrap()
        self.container = container
        _authController = StateObject(wrappedValue: container.authController)
        _workspaceStore = StateObject(wrappedValue: container.workspaceStore)
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environmentObject(authController)
                .environmentObject(workspaceStore)
                .preferredColorScheme(workspaceStore.workspace?.settings.themePreference.colorScheme)
                .task(id: authController.currentUser?.id) {
                    await workspaceStore.bootstrap(for: authController.currentUser)
                }
        }
    }
}
