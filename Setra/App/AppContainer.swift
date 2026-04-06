import Foundation

final class AppContainer {
    let authController: AuthController
    let workspaceStore: WorkspaceStore
    let progressionEngine: ProgressionEngine
    let plateCalculator: PlateCalculator
    let analyticsEngine: AnalyticsEngine
    let exerciseSearchEngine: ExerciseSearchEngine
    let haptics: HapticsClient

    init(
        authController: AuthController,
        workspaceStore: WorkspaceStore,
        progressionEngine: ProgressionEngine,
        plateCalculator: PlateCalculator,
        analyticsEngine: AnalyticsEngine,
        exerciseSearchEngine: ExerciseSearchEngine,
        haptics: HapticsClient
    ) {
        self.authController = authController
        self.workspaceStore = workspaceStore
        self.progressionEngine = progressionEngine
        self.plateCalculator = plateCalculator
        self.analyticsEngine = analyticsEngine
        self.exerciseSearchEngine = exerciseSearchEngine
        self.haptics = haptics
    }

    static func bootstrap() -> AppContainer {
        let localStore = LocalWorkspaceStore()
        let remoteSync = FirebaseWorkspaceSyncClient()
        let repository = CompositeWorkspaceRepository(
            localStore: localStore,
            remoteSync: remoteSync
        )

        let authProvider = FirebaseAuthProvider.makeDefault()
        let authController = AuthController(provider: authProvider)
        let progressionEngine = ProgressionEngine()
        let plateCalculator = PlateCalculator()
        let analyticsEngine = AnalyticsEngine()
        let exerciseSearchEngine = ExerciseSearchEngine()
        let haptics = HapticsClient()

        let workspaceStore = WorkspaceStore(
            repository: repository,
            progressionEngine: progressionEngine,
            analyticsEngine: analyticsEngine,
            searchEngine: exerciseSearchEngine
        )

        return AppContainer(
            authController: authController,
            workspaceStore: workspaceStore,
            progressionEngine: progressionEngine,
            plateCalculator: plateCalculator,
            analyticsEngine: analyticsEngine,
            exerciseSearchEngine: exerciseSearchEngine,
            haptics: haptics
        )
    }
}
