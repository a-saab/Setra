import Foundation
import Observation

@MainActor
@Observable
final class DashboardStore {
    private let workspaceStore: WorkspaceStore

    init(workspaceStore: WorkspaceStore) {
        self.workspaceStore = workspaceStore
    }

    var workspace: UserWorkspace? { workspaceStore.workspace }
    var analytics: AnalyticsSnapshot { workspaceStore.analytics }
    var historySessions: [WorkoutSession] { workspaceStore.historySessions }

    func exercise(by id: String) -> Exercise? {
        workspaceStore.exercise(by: id)
    }

    func performanceSummary(for exerciseID: String) -> ExercisePerformanceSummary? {
        workspaceStore.performanceSummary(for: exerciseID)
    }

    func startWorkout(from day: ScheduleDayPlan) -> WorkoutSession {
        workspaceStore.startWorkout(from: day)
    }
}

@MainActor
@Observable
final class PlanningStore {
    private let workspaceStore: WorkspaceStore
    private let authController: AuthController

    init(workspaceStore: WorkspaceStore, authController: AuthController) {
        self.workspaceStore = workspaceStore
        self.authController = authController
    }

    var workspace: UserWorkspace? { workspaceStore.workspace }
    var orderedScheduleDays: [ScheduleDayPlan] { workspaceStore.workspace?.orderedScheduleDays ?? [] }
    var templates: [WorkoutTemplate] { workspaceStore.workspace?.templates ?? [] }
    var weightUnit: WeightUnit { workspaceStore.workspace?.settings.weightUnit ?? .pounds }
    var firstWeekday: Weekday { workspaceStore.workspace?.settings.firstWeekday ?? .monday }

    func exercise(by id: String) -> Exercise? {
        workspaceStore.exercise(by: id)
    }

    func performanceSummary(for exerciseID: String) -> ExercisePerformanceSummary? {
        workspaceStore.performanceSummary(for: exerciseID)
    }

    func startWorkout(from day: ScheduleDayPlan) -> WorkoutSession {
        workspaceStore.startWorkout(from: day)
    }

    func updateScheduleDay(_ day: ScheduleDayPlan) async {
        guard let user = authController.currentUser else { return }
        await workspaceStore.updateScheduleDay(day, for: user)
    }

    func saveTemplate(from day: ScheduleDayPlan) async {
        guard let user = authController.currentUser else { return }
        await workspaceStore.saveTemplate(from: day, for: user)
    }

    func copyDay(from source: Weekday, to target: Weekday) async {
        guard let user = authController.currentUser else { return }
        await workspaceStore.copyDay(from: source, to: target, for: user)
    }

    func clearDay(_ weekday: Weekday) async {
        guard let user = authController.currentUser else { return }
        await workspaceStore.clearDay(weekday, for: user)
    }
}

@MainActor
@Observable
final class ProgressStore {
    private let workspaceStore: WorkspaceStore

    init(workspaceStore: WorkspaceStore) {
        self.workspaceStore = workspaceStore
    }

    var analytics: AnalyticsSnapshot { workspaceStore.analytics }
    var historySessions: [WorkoutSession] { workspaceStore.historySessions }

    func exercise(by id: String) -> Exercise? {
        workspaceStore.exercise(by: id)
    }
}

@MainActor
@Observable
final class ProfileStore {
    private let workspaceStore: WorkspaceStore
    private let authController: AuthController

    init(workspaceStore: WorkspaceStore, authController: AuthController) {
        self.workspaceStore = workspaceStore
        self.authController = authController
    }

    var workspace: UserWorkspace? { workspaceStore.workspace }
    var currentUser: AuthUser? { authController.currentUser }
    var bodyweightLogs: [BodyweightLog] { workspaceStore.workspace?.bodyweightLogs ?? [] }
    var settings: AppSettings { workspaceStore.workspace?.settings ?? .default }

    func addBodyweightLog(_ log: BodyweightLog) async {
        guard let user = authController.currentUser else { return }
        await workspaceStore.addBodyweightLog(log, for: user)
    }

    func updateSettings(_ settings: AppSettings) async {
        guard let user = authController.currentUser else { return }
        await workspaceStore.updateSettings(settings, for: user)
    }

    func signOut() async {
        await authController.signOut()
    }
}

@MainActor
@Observable
final class ExerciseLibraryStore {
    private let workspaceStore: WorkspaceStore
    private let authController: AuthController

    init(workspaceStore: WorkspaceStore, authController: AuthController) {
        self.workspaceStore = workspaceStore
        self.authController = authController
    }

    var workspace: UserWorkspace? { workspaceStore.workspace }

    func searchExercises(query: String, filters: ExerciseSearchFilters) -> [ExerciseSearchResult] {
        workspaceStore.searchExercises(query: query, filters: filters)
    }

    func exercise(by id: String) -> Exercise? {
        workspaceStore.exercise(by: id)
    }

    func performanceSummary(for exerciseID: String) -> ExercisePerformanceSummary? {
        workspaceStore.performanceSummary(for: exerciseID)
    }

    func progressionSuggestion(for exerciseID: String) -> ProgressionRecommendation? {
        workspaceStore.progressionSuggestion(for: exerciseID)
    }

    func isFavorite(_ exerciseID: String) -> Bool {
        workspaceStore.workspace?.favoriteExerciseIDs.contains(exerciseID) ?? false
    }

    func toggleFavorite(exerciseID: String) async {
        guard let user = authController.currentUser else { return }
        await workspaceStore.toggleFavorite(exerciseID: exerciseID, for: user)
    }

    func saveCustomExercise(_ exercise: Exercise) async {
        guard let user = authController.currentUser else { return }
        await workspaceStore.saveCustomExercise(exercise, for: user)
    }
}

@MainActor
@Observable
final class WorkoutStore {
    private let workspaceStore: WorkspaceStore
    private let authController: AuthController

    init(workspaceStore: WorkspaceStore, authController: AuthController) {
        self.workspaceStore = workspaceStore
        self.authController = authController
    }

    var settings: AppSettings { workspaceStore.workspace?.settings ?? .default }

    func exercise(by id: String) -> Exercise? {
        workspaceStore.exercise(by: id)
    }

    func saveCompletedWorkout(_ session: WorkoutSession) async {
        guard let user = authController.currentUser else { return }
        await workspaceStore.saveCompletedWorkout(session, for: user)
    }
}

@MainActor
@Observable
final class OnboardingStore {
    private let workspaceStore: WorkspaceStore
    private let authController: AuthController

    init(workspaceStore: WorkspaceStore, authController: AuthController) {
        self.workspaceStore = workspaceStore
        self.authController = authController
    }

    var workspace: UserWorkspace? { workspaceStore.workspace }

    func completeOnboarding(settings: AppSettings, displayName: String) async {
        guard let user = authController.currentUser else { return }
        await workspaceStore.completeOnboarding(for: user, settings: settings, displayName: displayName)
    }
}
