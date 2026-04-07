import Foundation

final class AppContainer {
    let authController: AuthController
    let workspaceStore: WorkspaceStore
    let dashboardStore: DashboardStore
    let planningStore: PlanningStore
    let progressStore: ProgressStore
    let profileStore: ProfileStore
    let exerciseLibraryStore: ExerciseLibraryStore
    let workoutStore: WorkoutStore
    let onboardingStore: OnboardingStore
    let progressionEngine: ProgressionEngine
    let plateCalculator: PlateCalculator
    let analyticsEngine: AnalyticsEngine
    let exerciseSearchEngine: ExerciseSearchEngine
    let haptics: HapticsClient

    init(
        authController: AuthController,
        workspaceStore: WorkspaceStore,
        dashboardStore: DashboardStore,
        planningStore: PlanningStore,
        progressStore: ProgressStore,
        profileStore: ProfileStore,
        exerciseLibraryStore: ExerciseLibraryStore,
        workoutStore: WorkoutStore,
        onboardingStore: OnboardingStore,
        progressionEngine: ProgressionEngine,
        plateCalculator: PlateCalculator,
        analyticsEngine: AnalyticsEngine,
        exerciseSearchEngine: ExerciseSearchEngine,
        haptics: HapticsClient
    ) {
        self.authController = authController
        self.workspaceStore = workspaceStore
        self.dashboardStore = dashboardStore
        self.planningStore = planningStore
        self.progressStore = progressStore
        self.profileStore = profileStore
        self.exerciseLibraryStore = exerciseLibraryStore
        self.workoutStore = workoutStore
        self.onboardingStore = onboardingStore
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
        let dashboardStore = DashboardStore(workspaceStore: workspaceStore)
        let planningStore = PlanningStore(workspaceStore: workspaceStore, authController: authController)
        let progressStore = ProgressStore(workspaceStore: workspaceStore)
        let profileStore = ProfileStore(workspaceStore: workspaceStore, authController: authController)
        let exerciseLibraryStore = ExerciseLibraryStore(workspaceStore: workspaceStore, authController: authController)
        let workoutStore = WorkoutStore(workspaceStore: workspaceStore, authController: authController)
        let onboardingStore = OnboardingStore(workspaceStore: workspaceStore, authController: authController)

        return AppContainer(
            authController: authController,
            workspaceStore: workspaceStore,
            dashboardStore: dashboardStore,
            planningStore: planningStore,
            progressStore: progressStore,
            profileStore: profileStore,
            exerciseLibraryStore: exerciseLibraryStore,
            workoutStore: workoutStore,
            onboardingStore: onboardingStore,
            progressionEngine: progressionEngine,
            plateCalculator: plateCalculator,
            analyticsEngine: analyticsEngine,
            exerciseSearchEngine: exerciseSearchEngine,
            haptics: haptics
        )
    }
}
