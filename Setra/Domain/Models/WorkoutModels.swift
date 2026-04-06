import Foundation
import SwiftUI

enum WeightUnit: String, Codable, CaseIterable, Hashable, Identifiable {
    case pounds
    case kilograms

    var id: String { rawValue }
    var shortLabel: String { self == .pounds ? "lb" : "kg" }
    var displayName: String { self == .pounds ? "Pounds" : "Kilograms" }
}

enum ThemePreference: String, Codable, CaseIterable, Identifiable {
    case system
    case dark
    case light

    var id: String { rawValue }

    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            nil
        case .dark:
            .dark
        case .light:
            .light
        }
    }
}

enum GymEquipmentLevel: String, Codable, CaseIterable, Hashable, Identifiable {
    case fullGym
    case commercialGym
    case homeGym
    case minimal

    var id: String { rawValue }
    var title: String {
        switch self {
        case .fullGym:
            "Full Gym"
        case .commercialGym:
            "Commercial Gym"
        case .homeGym:
            "Home Gym"
        case .minimal:
            "Minimal"
        }
    }
}

enum TrainingGoal: String, Codable, CaseIterable, Hashable, Identifiable {
    case hypertrophy
    case strength
    case generalFitness

    var id: String { rawValue }
    var title: String {
        switch self {
        case .hypertrophy:
            "Hypertrophy"
        case .strength:
            "Strength"
        case .generalFitness:
            "General Fitness"
        }
    }
}

enum Weekday: Int, Codable, CaseIterable, Hashable, Identifiable {
    case monday = 1
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday

    var id: Int { rawValue }
    var title: String {
        switch self {
        case .monday: "Monday"
        case .tuesday: "Tuesday"
        case .wednesday: "Wednesday"
        case .thursday: "Thursday"
        case .friday: "Friday"
        case .saturday: "Saturday"
        case .sunday: "Sunday"
        }
    }

    var shortTitle: String { String(title.prefix(3)) }
}

enum DayPlanKind: String, Codable, CaseIterable, Hashable, Identifiable {
    case workout
    case rest

    var id: String { rawValue }
}

enum MuscleGroup: String, Codable, CaseIterable, Hashable, Identifiable {
    case chest
    case back
    case shoulders
    case biceps
    case triceps
    case forearms
    case quads
    case hamstrings
    case glutes
    case calves
    case abs
    case core
    case fullBody
    case conditioning

    var id: String { rawValue }

    var title: String {
        rawValue.replacingOccurrences(of: "abs", with: "Abs")
            .replacingOccurrences(of: "core", with: "Core")
            .replacingOccurrences(of: "fullBody", with: "Full Body")
            .replacingOccurrences(of: "conditioning", with: "Conditioning")
            .capitalized
    }

    var symbolName: String {
        switch self {
        case .chest: "figure.strengthtraining.traditional"
        case .back: "figure.run"
        case .shoulders: "figure.mixed.cardio"
        case .biceps: "bolt.heart"
        case .triceps: "figure.cooldown"
        case .forearms: "hand.raised.fill"
        case .quads: "figure.walk"
        case .hamstrings: "figure.step.training"
        case .glutes: "figure.strengthtraining.functional"
        case .calves: "figure.walk.motion"
        case .abs, .core: "circle.grid.cross"
        case .fullBody: "figure.strengthtraining.functional"
        case .conditioning: "heart.circle"
        }
    }
}

enum EquipmentType: String, Codable, CaseIterable, Hashable, Identifiable {
    case barbell
    case dumbbell
    case machine
    case cable
    case bodyweight
    case assisted
    case cardio
    case kettlebell
    case smithMachine
    case bands
    case other

    var id: String { rawValue }

    var title: String {
        switch self {
        case .smithMachine:
            "Smith Machine"
        case .bodyweight:
            "Bodyweight"
        default:
            rawValue.capitalized
        }
    }
}

enum MovementPattern: String, Codable, CaseIterable, Hashable, Identifiable {
    case squat
    case hinge
    case push
    case pull
    case lunge
    case carry
    case curl
    case extensionPattern = "extension"
    case raise
    case press
    case row
    case cardio
    case core
    case isolation

    var id: String { rawValue }
    var title: String { rawValue.capitalized }
}

enum ExerciseType: String, Codable, CaseIterable, Hashable, Identifiable {
    case barbell
    case dumbbell
    case machine
    case cable
    case bodyweight
    case assisted
    case cardioConditioning
    case other

    var id: String { rawValue }

    var title: String {
        switch self {
        case .cardioConditioning:
            "Cardio"
        default:
            rawValue.capitalized
        }
    }
}

enum IntensityStyle: String, Codable, CaseIterable, Hashable, Identifiable {
    case none
    case failure
    case rirOneToTwo

    var id: String { rawValue }

    var title: String {
        switch self {
        case .none:
            "None"
        case .failure:
            "Failure"
        case .rirOneToTwo:
            "RIR 1-2"
        }
    }
}

enum ExerciseSource: String, Codable, CaseIterable, Hashable {
    case builtIn
    case custom
}

enum ProgressionStyle: String, Codable, CaseIterable, Hashable {
    case load
    case reps
    case assistance
}

enum SetLogKind: String, Codable, CaseIterable, Hashable {
    case warmUp
    case working
    case drop
}

enum WorkoutSessionState: String, Codable, CaseIterable, Hashable {
    case inProgress
    case completed
}

struct AuthUser: Identifiable, Codable, Hashable {
    let id: String
    let email: String
    var displayName: String
    var usesFirebase: Bool
}

struct RepRange: Codable, Hashable {
    var lowerBound: Int
    var upperBound: Int

    var title: String {
        lowerBound == upperBound ? "\(lowerBound)" : "\(lowerBound)-\(upperBound)"
    }
}

struct WeightValue: Codable, Hashable {
    var amount: Double
    var unit: WeightUnit
    var isPerHand: Bool = false

    var title: String {
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        return "\(amount.clean) \(unit.shortLabel)\(isPerHand ? " / hand" : "")"
    }
}

struct PlateInventoryItem: Identifiable, Codable, Hashable {
    var id: String { "\(weight.clean)-\(unit.rawValue)" }
    var weight: Double
    var unit: WeightUnit
    var countPerSide: Int?

    var displayWeight: String { "\(weight.clean) \(unit.shortLabel)" }
}

struct FavoritePlateSetup: Identifiable, Codable, Hashable {
    let id: String
    var name: String
    var totalWeight: Double
    var unit: WeightUnit
    var customBarWeight: Double?
}

struct ProgressionRule: Codable, Hashable {
    var style: ProgressionStyle
    var increment: Double
    var notes: String

    static let upperBodyDefault = ProgressionRule(
        style: .load,
        increment: 5,
        notes: "Increase after top-end reps on all working sets."
    )

    static let lowerBodyDefault = ProgressionRule(
        style: .load,
        increment: 10,
        notes: "Increase after top-end reps on all working sets."
    )
}

struct ExerciseMedia: Codable, Hashable {
    var localSymbolName: String?
    var remoteURL: String?
    var userImagePath: String?
}

struct Exercise: Identifiable, Codable, Hashable {
    let id: String
    var source: ExerciseSource
    var canonicalName: String
    var aliases: [String]
    var primaryMuscle: MuscleGroup
    var secondaryMuscles: [MuscleGroup]
    var equipment: EquipmentType
    var movementPattern: MovementPattern
    var exerciseType: ExerciseType
    var defaultRepRange: RepRange
    var defaultSetCount: Int
    var defaultRestTime: Int
    var notes: String
    var cues: [String]
    var lastSetToFailure: Bool
    var intensityStyle: IntensityStyle
    var keywords: [String]
    var progressionRule: ProgressionRule
    var media: ExerciseMedia?

    var searchTerms: [String] {
        ([canonicalName] + aliases + keywords).map { $0.lowercased() }
    }
}

struct PlannedWarmUpSet: Identifiable, Codable, Hashable {
    let id: String
    var reps: Int
    var loadFactor: Double
}

struct PlannedExercise: Identifiable, Codable, Hashable {
    var id: String
    var exerciseID: String
    var order: Int
    var targetSetCount: Int
    var targetRepRange: RepRange
    var targetWeight: WeightValue?
    var defaultRestTime: Int
    var notes: String
    var lastSetIntensity: IntensityStyle
    var warmUpSets: [PlannedWarmUpSet]
    var supersetTag: String?

    static func from(exercise: Exercise, unit: WeightUnit, order: Int) -> PlannedExercise {
        PlannedExercise(
            id: UUID().uuidString,
            exerciseID: exercise.id,
            order: order,
            targetSetCount: exercise.defaultSetCount,
            targetRepRange: exercise.defaultRepRange,
            targetWeight: nil,
            defaultRestTime: exercise.defaultRestTime,
            notes: exercise.notes,
            lastSetIntensity: exercise.intensityStyle,
            warmUpSets: [
                PlannedWarmUpSet(id: UUID().uuidString, reps: 10, loadFactor: 0.4),
                PlannedWarmUpSet(id: UUID().uuidString, reps: 6, loadFactor: 0.65),
            ],
            supersetTag: nil
        )
    }
}

struct ScheduleDayPlan: Identifiable, Codable, Hashable {
    var id: String
    var weekday: Weekday
    var kind: DayPlanKind
    var title: String
    var subtitle: String
    var notes: String
    var exercises: [PlannedExercise]

    static func restDay(for weekday: Weekday) -> ScheduleDayPlan {
        ScheduleDayPlan(
            id: UUID().uuidString,
            weekday: weekday,
            kind: .rest,
            title: "Rest Day",
            subtitle: "Recovery and mobility",
            notes: "",
            exercises: []
        )
    }
}

struct WeeklySchedule: Identifiable, Codable, Hashable {
    var id: String
    var title: String
    var notes: String
    var days: [ScheduleDayPlan]

    func day(for weekday: Weekday) -> ScheduleDayPlan? {
        days.first { $0.weekday == weekday }
    }

    mutating func set(_ day: ScheduleDayPlan) {
        days.removeAll { $0.weekday == day.weekday }
        days.append(day)
        days.sort { $0.weekday.rawValue < $1.weekday.rawValue }
    }
}

struct WorkoutTemplate: Identifiable, Codable, Hashable {
    let id: String
    var name: String
    var subtitle: String
    var notes: String
    var exercises: [PlannedExercise]
    var createdAt: Date
    var updatedAt: Date
}

struct SetLog: Identifiable, Codable, Hashable {
    let id: String
    var kind: SetLogKind
    var targetReps: Int?
    var reps: Int?
    var load: Double?
    var unit: WeightUnit
    var isPerHand: Bool
    var didReachFailure: Bool
    var note: String

    static func empty(targetReps: Int?, unit: WeightUnit) -> SetLog {
        SetLog(
            id: UUID().uuidString,
            kind: .working,
            targetReps: targetReps,
            reps: targetReps,
            load: nil,
            unit: unit,
            isPerHand: false,
            didReachFailure: false,
            note: ""
        )
    }
}

struct ExercisePerformanceSummary: Codable, Hashable {
    var date: Date
    var lastWeight: Double?
    var bestWeight: Double?
    var reps: [Int]
    var unit: WeightUnit
    var bestDescription: String
    var lastDescription: String
}

struct ProgressionRecommendation: Codable, Hashable {
    var suggestedWeight: Double?
    var unit: WeightUnit
    var reason: String
    var shouldIncrease: Bool
}

struct LoggedExercise: Identifiable, Codable, Hashable {
    let id: String
    var plannedExerciseID: String?
    var exerciseID: String
    var order: Int
    var targetSets: Int
    var targetRepRange: RepRange
    var warmUpSets: [PlannedWarmUpSet]
    var workingSets: [SetLog]
    var notes: String
    var completedAllPrescribedWork: Bool
    var lastSetFailureCompleted: Bool
    var previousPerformance: ExercisePerformanceSummary?
    var suggestedLoad: ProgressionRecommendation?
}

struct WorkoutSession: Identifiable, Codable, Hashable {
    let id: String
    var weekday: Weekday
    var title: String
    var subtitle: String
    var startedAt: Date
    var completedAt: Date?
    var notes: String
    var state: WorkoutSessionState
    var exercises: [LoggedExercise]
    var unit: WeightUnit

    var totalVolume: Double {
        exercises.flatMap(\.workingSets).reduce(0) { partial, set in
            partial + (Double(set.reps ?? 0) * (set.load ?? 0))
        }
    }
}

struct PersonalRecord: Identifiable, Codable, Hashable {
    let id: String
    var exerciseID: String
    var date: Date
    var weight: Double
    var reps: Int
    var unit: WeightUnit
    var label: String
}

struct BodyweightLog: Identifiable, Codable, Hashable {
    let id: String
    var date: Date
    var weight: Double
    var unit: WeightUnit
    var note: String
}

struct UserProfile: Codable, Hashable {
    var displayName: String
    var email: String
    var hasCompletedOnboarding: Bool
    var createdAt: Date
    var updatedAt: Date
}

struct AppSettings: Codable, Hashable {
    var weightUnit: WeightUnit
    var defaultBarbellWeight: Double
    var plateInventory: [PlateInventoryItem]
    var favoritePlateSetups: [FavoritePlateSetup]
    var restTimerSeconds: Int
    var upperBodyIncrement: Double
    var lowerBodyIncrement: Double
    var themePreference: ThemePreference
    var showInlinePerformance: Bool
    var hapticsEnabled: Bool
    var gymEquipmentLevel: GymEquipmentLevel
    var trainingGoals: [TrainingGoal]

    static let `default` = AppSettings(
        weightUnit: .pounds,
        defaultBarbellWeight: 45,
        plateInventory: [
            PlateInventoryItem(weight: 45, unit: .pounds, countPerSide: 4),
            PlateInventoryItem(weight: 25, unit: .pounds, countPerSide: 2),
            PlateInventoryItem(weight: 10, unit: .pounds, countPerSide: 2),
            PlateInventoryItem(weight: 5, unit: .pounds, countPerSide: 2),
            PlateInventoryItem(weight: 2.5, unit: .pounds, countPerSide: 2),
        ],
        favoritePlateSetups: [],
        restTimerSeconds: 120,
        upperBodyIncrement: 5,
        lowerBodyIncrement: 10,
        themePreference: .system,
        showInlinePerformance: true,
        hapticsEnabled: true,
        gymEquipmentLevel: .commercialGym,
        trainingGoals: [.hypertrophy]
    )
}

struct UserWorkspace: Codable, Hashable {
    var profile: UserProfile
    var settings: AppSettings
    var schedule: WeeklySchedule
    var templates: [WorkoutTemplate]
    var customExercises: [Exercise]
    var sessions: [WorkoutSession]
    var bodyweightLogs: [BodyweightLog]
    var favoriteExerciseIDs: Set<String>
    var recentExerciseIDs: [String]
    var personalRecords: [PersonalRecord]
    var updatedAt: Date

    static func seeded(for user: AuthUser) -> UserWorkspace {
        let starter = SeedData.defaultWeeklySchedule(unit: .pounds)
        return UserWorkspace(
            profile: UserProfile(
                displayName: user.displayName,
                email: user.email,
                hasCompletedOnboarding: false,
                createdAt: .now,
                updatedAt: .now
            ),
            settings: .default,
            schedule: starter,
            templates: [],
            customExercises: [],
            sessions: SeedData.recentSessions(unit: .pounds),
            bodyweightLogs: SeedData.bodyweightLogs(unit: .pounds),
            favoriteExerciseIDs: ["bench-press", "lat-pulldown", "barbell-back-squat"],
            recentExerciseIDs: [],
            personalRecords: [],
            updatedAt: .now
        )
    }

    func touchingUpdate() -> UserWorkspace {
        var copy = self
        copy.profile.updatedAt = .now
        copy.updatedAt = .now
        return copy
    }
}

struct ExerciseSearchFilters: Hashable {
    var muscleGroup: MuscleGroup?
    var equipment: EquipmentType?
    var movementPattern: MovementPattern?
    var favoritesOnly = false
}

struct ExerciseSearchResult: Identifiable, Hashable {
    var id: String { exercise.id }
    var exercise: Exercise
    var score: Int
    var previousPerformance: ExercisePerformanceSummary?
    var recommendation: ProgressionRecommendation?
    var isFavorite: Bool
}

struct DashboardSnapshot: Hashable {
    var todayPlan: ScheduleDayPlan?
    var adherenceSummary: String
    var recentPR: PersonalRecord?
    var bodyweightDeltaText: String
    var upcomingDays: [ScheduleDayPlan]
}

struct AnalyticsPoint: Identifiable, Hashable {
    let id = UUID()
    var label: String
    var value: Double
}

struct AnalyticsSnapshot: Hashable {
    var volumeByWeek: [AnalyticsPoint]
    var bodyweightTrend: [AnalyticsPoint]
    var weeklyConsistency: [AnalyticsPoint]
    var streakCount: Int
    var recentPRs: [PersonalRecord]

    static let empty = AnalyticsSnapshot(
        volumeByWeek: [],
        bodyweightTrend: [],
        weeklyConsistency: [],
        streakCount: 0,
        recentPRs: []
    )
}

extension Array where Element: Hashable {
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}

extension Double {
    var clean: String {
        truncatingRemainder(dividingBy: 1) == 0 ? String(Int(self)) : String(format: "%.1f", self)
    }
}
