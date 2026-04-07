import Combine
import Foundation
import SwiftUI

@MainActor
final class WorkspaceStore: ObservableObject {
    private let repository: WorkspaceRepository
    private let progressionEngine: ProgressionEngine
    private let analyticsEngine: AnalyticsEngine
    private let searchEngine: ExerciseSearchEngine

    @Published var workspace: UserWorkspace?
    @Published var isBootstrapping = false
    @Published var errorMessage: String?
    @Published var bannerMessage: String?

    private var persistTask: Task<Void, Never>?
    private var bannerTask: Task<Void, Never>?

    init(
        repository: WorkspaceRepository,
        progressionEngine: ProgressionEngine,
        analyticsEngine: AnalyticsEngine,
        searchEngine: ExerciseSearchEngine
    ) {
        self.repository = repository
        self.progressionEngine = progressionEngine
        self.analyticsEngine = analyticsEngine
        self.searchEngine = searchEngine
    }

    var allExercises: [Exercise] {
        guard let workspace else { return SeedData.exerciseLibrary }
        return SeedData.exerciseLibrary + workspace.customExercises
    }

    var historySessions: [WorkoutSession] {
        workspace?.sessions.sorted(by: { $0.startedAt > $1.startedAt }) ?? []
    }

    var analytics: AnalyticsSnapshot {
        guard let workspace else { return .empty }
        return analyticsEngine.makeSnapshot(
            workspace: workspace,
            exerciseLibrary: allExercises
        )
    }

    func bootstrap(for user: AuthUser?) async {
        persistTask?.cancel()
        guard let user else {
            workspace = nil
            isBootstrapping = false
            return
        }

        isBootstrapping = true
        defer { isBootstrapping = false }

        do {
            workspace = try await repository.loadWorkspace(for: user)
        } catch {
            errorMessage = error.localizedDescription
            workspace = UserWorkspace.empty(for: user)
        }
    }

    func completeOnboarding(for user: AuthUser, settings: AppSettings, displayName: String) async {
        guard var workspace else { return }
        workspace.profile.displayName = displayName
        workspace.profile.hasCompletedOnboarding = true
        workspace.settings = settings
        await replaceWorkspace(workspace, for: user, banner: "Setra is ready")
    }

    func updateSettings(_ settings: AppSettings, for user: AuthUser) async {
        guard var workspace else { return }
        workspace.settings = settings
        await replaceWorkspace(workspace, for: user, banner: "Settings updated")
    }

    func addBodyweightLog(_ log: BodyweightLog, for user: AuthUser) async {
        guard var workspace else { return }
        workspace.bodyweightLogs.removeAll { Calendar.current.isDate($0.date, inSameDayAs: log.date) }
        workspace.bodyweightLogs.append(log)
        workspace.bodyweightLogs.sort { $0.date > $1.date }
        await replaceWorkspace(workspace, for: user, banner: "Bodyweight saved")
    }

    func updateScheduleDay(_ day: ScheduleDayPlan, for user: AuthUser) async {
        guard var workspace else { return }
        workspace.schedule.set(day)
        await replaceWorkspace(workspace, for: user, banner: "Schedule saved")
    }

    func copyDay(from source: Weekday, to target: Weekday, for user: AuthUser) async {
        guard var workspace, let sourceDay = workspace.schedule.day(for: source) else { return }
        var copy = sourceDay
        copy.id = UUID().uuidString
        copy.weekday = target
        workspace.schedule.set(copy)
        await replaceWorkspace(workspace, for: user, banner: "\(target.title) copied")
    }

    func clearDay(_ weekday: Weekday, for user: AuthUser) async {
        guard var workspace else { return }
        workspace.schedule.set(ScheduleDayPlan.restDay(for: weekday))
        await replaceWorkspace(workspace, for: user, banner: "\(weekday.title) cleared")
    }

    func saveTemplate(from day: ScheduleDayPlan, for user: AuthUser) async {
        guard var workspace else { return }
        let template = WorkoutTemplate(
            id: UUID().uuidString,
            name: day.title.isEmpty ? "\(day.weekday.title) Template" : day.title,
            subtitle: day.subtitle,
            notes: day.notes,
            exercises: day.exercises,
            createdAt: .now,
            updatedAt: .now
        )
        workspace.templates.insert(template, at: 0)
        await replaceWorkspace(workspace, for: user, banner: "Template saved")
    }

    func toggleFavorite(exerciseID: String, for user: AuthUser) async {
        guard var workspace else { return }
        if workspace.favoriteExerciseIDs.contains(exerciseID) {
            workspace.favoriteExerciseIDs.remove(exerciseID)
        } else {
            workspace.favoriteExerciseIDs.insert(exerciseID)
        }
        await replaceWorkspace(workspace, for: user, banner: "Favorites updated")
    }

    func saveCustomExercise(_ exercise: Exercise, for user: AuthUser) async {
        guard var workspace else { return }
        workspace.customExercises.removeAll { $0.id == exercise.id }
        workspace.customExercises.append(exercise)
        workspace.customExercises.sort { $0.canonicalName < $1.canonicalName }
        await replaceWorkspace(workspace, for: user, banner: "Custom exercise saved")
    }

    func startWorkout(from day: ScheduleDayPlan, on date: Date = .now) -> WorkoutSession {
        let exercises = day.exercises.map { plannedExercise in
            LoggedExercise(
                id: UUID().uuidString,
                plannedExerciseID: plannedExercise.id,
                exerciseID: plannedExercise.exerciseID,
                order: plannedExercise.order,
                targetSets: plannedExercise.targetSetCount,
                targetRepRange: plannedExercise.targetRepRange,
                warmUpSets: plannedExercise.warmUpSets,
                workingSets: Array(
                    repeating: SetLog.empty(
                        targetReps: plannedExercise.targetRepRange.upperBound,
                        unit: workspace?.settings.weightUnit ?? .pounds
                    ),
                    count: plannedExercise.targetSetCount
                ),
                notes: plannedExercise.notes,
                completedAllPrescribedWork: false,
                lastSetFailureCompleted: false,
                previousPerformance: performanceSummary(for: plannedExercise.exerciseID),
                suggestedLoad: progressionSuggestion(for: plannedExercise.exerciseID, dayExercise: plannedExercise)
            )
        }

        return WorkoutSession(
            id: UUID().uuidString,
            weekday: day.weekday,
            title: day.title,
            subtitle: day.subtitle,
            startedAt: date,
            completedAt: nil,
            notes: day.notes,
            state: .inProgress,
            exercises: exercises,
            unit: workspace?.settings.weightUnit ?? .pounds
        )
    }

    func saveCompletedWorkout(_ session: WorkoutSession, for user: AuthUser) async {
        guard var workspace else { return }
        var completed = session
        completed.completedAt = completed.completedAt ?? .now
        completed.state = .completed
        workspace.sessions.removeAll { $0.id == completed.id }
        workspace.sessions.insert(completed, at: 0)
        workspace.recentExerciseIDs = Array(
            (completed.exercises.map(\.exerciseID) + workspace.recentExerciseIDs)
                .uniqued()
                .prefix(12)
        )

        let records = analyticsEngine.personalRecords(
            from: workspace.sessions,
            exerciseLibrary: allExercises
        )
        workspace.personalRecords = records
        workspace.updatedAt = .now
        await replaceWorkspace(workspace, for: user, banner: "Workout saved")
    }

    func searchExercises(
        query: String,
        filters: ExerciseSearchFilters
    ) -> [ExerciseSearchResult] {
        searchEngine.search(
            query: query,
            filters: filters,
            exercises: allExercises,
            favorites: workspace?.favoriteExerciseIDs ?? [],
            recents: workspace?.recentExerciseIDs ?? [],
            history: historySessions
        )
    }

    func exercise(by id: String) -> Exercise? {
        allExercises.first { $0.id == id }
    }

    func performanceSummary(for exerciseID: String) -> ExercisePerformanceSummary? {
        progressionEngine.lastPerformance(for: exerciseID, sessions: historySessions)
    }

    func progressionSuggestion(
        for exerciseID: String,
        dayExercise: PlannedExercise? = nil
    ) -> ProgressionRecommendation? {
        guard let workspace else { return nil }
        let exercise = exercise(by: exerciseID)
        return progressionEngine.recommendation(
            for: exerciseID,
            plannedExercise: dayExercise,
            exercise: exercise,
            sessions: workspace.sessions,
            settings: workspace.settings
        )
    }

    private func replaceWorkspace(_ newValue: UserWorkspace, for user: AuthUser, banner: String?) async {
        workspace = newValue.touchingUpdate()
        schedulePersist(for: user)
        if let banner {
            showBanner(banner)
        }
    }

    private func schedulePersist(for user: AuthUser) {
        guard let workspace else { return }
        persistTask?.cancel()
        persistTask = Task {
            try? await Task.sleep(for: .milliseconds(250))
            try? await repository.persist(workspace: workspace, for: user)
        }
    }

    private func showBanner(_ message: String) {
        bannerTask?.cancel()
        bannerMessage = message
        bannerTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(2))
            withAnimation(.smooth(duration: 0.25)) {
                bannerMessage = nil
            }
        }
    }
}
