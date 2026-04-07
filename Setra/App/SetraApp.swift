import SwiftUI
#if canImport(FirebaseCore)
import FirebaseCore
#endif

@main
struct SetraApp: App {
    private let container: AppContainer
    @State private var authController: AuthController
    @State private var workspaceStore: WorkspaceStore
    @State private var dashboardStore: DashboardStore
    @State private var planningStore: PlanningStore
    @State private var progressStore: ProgressStore
    @State private var profileStore: ProfileStore
    @State private var exerciseLibraryStore: ExerciseLibraryStore
    @State private var workoutStore: WorkoutStore
    @State private var onboardingStore: OnboardingStore

    init() {
#if canImport(FirebaseCore)
        if FirebaseApp.app() == nil,
           Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil {
            FirebaseApp.configure()
        }
#endif

        let container = AppContainer.bootstrap()
        self.container = container
        _authController = State(initialValue: container.authController)
        _workspaceStore = State(initialValue: container.workspaceStore)
        _dashboardStore = State(initialValue: container.dashboardStore)
        _planningStore = State(initialValue: container.planningStore)
        _progressStore = State(initialValue: container.progressStore)
        _profileStore = State(initialValue: container.profileStore)
        _exerciseLibraryStore = State(initialValue: container.exerciseLibraryStore)
        _workoutStore = State(initialValue: container.workoutStore)
        _onboardingStore = State(initialValue: container.onboardingStore)
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environment(authController)
                .environment(workspaceStore)
                .environment(dashboardStore)
                .environment(planningStore)
                .environment(progressStore)
                .environment(profileStore)
                .environment(exerciseLibraryStore)
                .environment(workoutStore)
                .environment(onboardingStore)
                .preferredColorScheme(workspaceStore.workspace?.settings.themePreference.colorScheme)
                .task(id: authController.currentUser?.id) {
                    await workspaceStore.bootstrap(for: authController.currentUser)
                }
        }
    }
}
