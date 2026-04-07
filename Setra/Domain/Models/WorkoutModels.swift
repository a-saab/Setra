import Foundation
import SwiftUI

enum WeightUnit: String, Codable, CaseIterable, Hashable, Identifiable {
    case pounds
    case kilograms

    nonisolated var id: String { rawValue }
    nonisolated var shortLabel: String { self == .pounds ? "lb" : "kg" }
    nonisolated var displayName: String { self == .pounds ? "Pounds" : "Kilograms" }
    nonisolated var defaultBarbellWeight: Double { self == .pounds ? 45 : 20 }
    nonisolated var defaultUpperIncrement: Double { self == .pounds ? 5 : 2.5 }
    nonisolated var defaultLowerIncrement: Double { self == .pounds ? 10 : 5 }

    nonisolated var defaultPlateInventory: [PlateInventoryItem] {
        switch self {
        case .pounds:
            [
                PlateInventoryItem(weight: 45, unit: .pounds, countPerSide: 4),
                PlateInventoryItem(weight: 35, unit: .pounds, countPerSide: 2),
                PlateInventoryItem(weight: 25, unit: .pounds, countPerSide: 2),
                PlateInventoryItem(weight: 10, unit: .pounds, countPerSide: 2),
                PlateInventoryItem(weight: 5, unit: .pounds, countPerSide: 2),
                PlateInventoryItem(weight: 2.5, unit: .pounds, countPerSide: 2),
            ]
        case .kilograms:
            [
                PlateInventoryItem(weight: 20, unit: .kilograms, countPerSide: 4),
                PlateInventoryItem(weight: 15, unit: .kilograms, countPerSide: 2),
                PlateInventoryItem(weight: 10, unit: .kilograms, countPerSide: 2),
                PlateInventoryItem(weight: 5, unit: .kilograms, countPerSide: 2),
                PlateInventoryItem(weight: 2.5, unit: .kilograms, countPerSide: 2),
                PlateInventoryItem(weight: 1.25, unit: .kilograms, countPerSide: 2),
            ]
        }
    }
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

enum BarbellEntryMode: String, Codable, CaseIterable, Hashable, Identifiable {
    case shorthandPlatesPerSide
    case perSideLoad
    case totalLoadExcludingBar
    case totalLoadIncludingBar

    var id: String { rawValue }

    nonisolated var title: String {
        switch self {
        case .shorthandPlatesPerSide:
            "Plate Shorthand"
        case .perSideLoad:
            "One Side Load"
        case .totalLoadExcludingBar:
            "Total Without Bar"
        case .totalLoadIncludingBar:
            "Total With Bar"
        }
    }

    var subtitle: String {
        switch self {
        case .shorthandPlatesPerSide:
            "Examples: 1p, 1p25, 2p10"
        case .perSideLoad:
            "A number means one side only"
        case .totalLoadExcludingBar:
            "A number means plates only"
        case .totalLoadIncludingBar:
            "A number means full system weight"
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

    nonisolated var id: Int { rawValue }
    nonisolated var title: String {
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

    nonisolated var shortTitle: String { String(title.prefix(3)) }

    nonisolated static func ordered(startingAt firstWeekday: Weekday) -> [Weekday] {
        let all = Weekday.allCases
        guard let firstIndex = all.firstIndex(of: firstWeekday) else { return all }
        return Array(all[firstIndex...]) + Array(all[..<firstIndex])
    }

    nonisolated static var today: Weekday {
        let value = Calendar.current.component(.weekday, from: .now)
        switch value {
        case 2: return .monday
        case 3: return .tuesday
        case 4: return .wednesday
        case 5: return .thursday
        case 6: return .friday
        case 7: return .saturday
        default: return .sunday
        }
    }
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

    nonisolated var symbolName: String {
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

    nonisolated static func from(exercise: Exercise, unit: WeightUnit, order: Int) -> PlannedExercise {
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

    nonisolated static func restDay(for weekday: Weekday) -> ScheduleDayPlan {
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

    nonisolated static func empty(startingAt firstWeekday: Weekday) -> WeeklySchedule {
        WeeklySchedule(
            id: UUID().uuidString,
            title: "Weekly Split",
            notes: "",
            days: Weekday.ordered(startingAt: firstWeekday).map { ScheduleDayPlan.restDay(for: $0) }
        )
    }

    func day(for weekday: Weekday) -> ScheduleDayPlan? {
        days.first { $0.weekday == weekday }
    }

    func orderedDays(startingAt firstWeekday: Weekday) -> [ScheduleDayPlan] {
        Weekday.ordered(startingAt: firstWeekday).compactMap(day(for:))
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
    var firstWeekday: Weekday
    var defaultBarbellWeight: Double
    var plateInventory: [PlateInventoryItem]
    var favoritePlateSetups: [FavoritePlateSetup]
    var preferredBarbellEntryMode: BarbellEntryMode
    var restTimerSeconds: Int
    var upperBodyIncrement: Double
    var lowerBodyIncrement: Double
    var themePreference: ThemePreference
    var showInlinePerformance: Bool
    var hapticsEnabled: Bool
    var gymEquipmentLevel: GymEquipmentLevel
    var trainingGoals: [TrainingGoal]

    enum CodingKeys: String, CodingKey {
        case weightUnit
        case firstWeekday
        case defaultBarbellWeight
        case plateInventory
        case favoritePlateSetups
        case preferredBarbellEntryMode
        case restTimerSeconds
        case upperBodyIncrement
        case lowerBodyIncrement
        case themePreference
        case showInlinePerformance
        case hapticsEnabled
        case gymEquipmentLevel
        case trainingGoals
    }

    nonisolated static let `default` = AppSettings(
        weightUnit: .pounds,
        firstWeekday: .monday,
        defaultBarbellWeight: WeightUnit.pounds.defaultBarbellWeight,
        plateInventory: WeightUnit.pounds.defaultPlateInventory,
        favoritePlateSetups: [],
        preferredBarbellEntryMode: .shorthandPlatesPerSide,
        restTimerSeconds: 120,
        upperBodyIncrement: WeightUnit.pounds.defaultUpperIncrement,
        lowerBodyIncrement: WeightUnit.pounds.defaultLowerIncrement,
        themePreference: .system,
        showInlinePerformance: true,
        hapticsEnabled: true,
        gymEquipmentLevel: .commercialGym,
        trainingGoals: [.hypertrophy]
    )

    init(
        weightUnit: WeightUnit,
        firstWeekday: Weekday,
        defaultBarbellWeight: Double,
        plateInventory: [PlateInventoryItem],
        favoritePlateSetups: [FavoritePlateSetup],
        preferredBarbellEntryMode: BarbellEntryMode,
        restTimerSeconds: Int,
        upperBodyIncrement: Double,
        lowerBodyIncrement: Double,
        themePreference: ThemePreference,
        showInlinePerformance: Bool,
        hapticsEnabled: Bool,
        gymEquipmentLevel: GymEquipmentLevel,
        trainingGoals: [TrainingGoal]
    ) {
        self.weightUnit = weightUnit
        self.firstWeekday = firstWeekday
        self.defaultBarbellWeight = defaultBarbellWeight
        self.plateInventory = plateInventory
        self.favoritePlateSetups = favoritePlateSetups
        self.preferredBarbellEntryMode = preferredBarbellEntryMode
        self.restTimerSeconds = restTimerSeconds
        self.upperBodyIncrement = upperBodyIncrement
        self.lowerBodyIncrement = lowerBodyIncrement
        self.themePreference = themePreference
        self.showInlinePerformance = showInlinePerformance
        self.hapticsEnabled = hapticsEnabled
        self.gymEquipmentLevel = gymEquipmentLevel
        self.trainingGoals = trainingGoals
    }

    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let defaultSettings = AppSettings.default
        let decodedUnit = try container.decodeIfPresent(WeightUnit.self, forKey: .weightUnit) ?? defaultSettings.weightUnit
        let unitDefaultBarbellWeight = decodedUnit.defaultBarbellWeight
        let unitDefaultPlateInventory = decodedUnit.defaultPlateInventory
        let unitDefaultUpperIncrement = decodedUnit.defaultUpperIncrement
        let unitDefaultLowerIncrement = decodedUnit.defaultLowerIncrement
        self.weightUnit = decodedUnit
        self.firstWeekday = try container.decodeIfPresent(Weekday.self, forKey: .firstWeekday) ?? defaultSettings.firstWeekday
        self.defaultBarbellWeight = try container.decodeIfPresent(Double.self, forKey: .defaultBarbellWeight) ?? unitDefaultBarbellWeight
        self.plateInventory = try container.decodeIfPresent([PlateInventoryItem].self, forKey: .plateInventory) ?? unitDefaultPlateInventory
        self.favoritePlateSetups = try container.decodeIfPresent([FavoritePlateSetup].self, forKey: .favoritePlateSetups) ?? []
        self.preferredBarbellEntryMode = try container.decodeIfPresent(BarbellEntryMode.self, forKey: .preferredBarbellEntryMode) ?? .shorthandPlatesPerSide
        self.restTimerSeconds = try container.decodeIfPresent(Int.self, forKey: .restTimerSeconds) ?? defaultSettings.restTimerSeconds
        self.upperBodyIncrement = try container.decodeIfPresent(Double.self, forKey: .upperBodyIncrement) ?? unitDefaultUpperIncrement
        self.lowerBodyIncrement = try container.decodeIfPresent(Double.self, forKey: .lowerBodyIncrement) ?? unitDefaultLowerIncrement
        self.themePreference = try container.decodeIfPresent(ThemePreference.self, forKey: .themePreference) ?? defaultSettings.themePreference
        self.showInlinePerformance = try container.decodeIfPresent(Bool.self, forKey: .showInlinePerformance) ?? defaultSettings.showInlinePerformance
        self.hapticsEnabled = try container.decodeIfPresent(Bool.self, forKey: .hapticsEnabled) ?? defaultSettings.hapticsEnabled
        self.gymEquipmentLevel = try container.decodeIfPresent(GymEquipmentLevel.self, forKey: .gymEquipmentLevel) ?? defaultSettings.gymEquipmentLevel
        self.trainingGoals = try container.decodeIfPresent([TrainingGoal].self, forKey: .trainingGoals) ?? defaultSettings.trainingGoals
    }

    mutating func applyWeightUnitDefaults() {
        defaultBarbellWeight = weightUnit.defaultBarbellWeight
        upperBodyIncrement = weightUnit.defaultUpperIncrement
        lowerBodyIncrement = weightUnit.defaultLowerIncrement
        plateInventory = weightUnit.defaultPlateInventory
    }
}

struct UserWorkspace: Codable, Hashable {
    enum CodingKeys: String, CodingKey {
        case profile
        case settings
        case schedule
        case templates
        case customExercises
        case sessions
        case bodyweightLogs
        case favoriteExerciseIDs
        case recentExerciseIDs
        case personalRecords
        case updatedAt
    }
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

    nonisolated init(
        profile: UserProfile,
        settings: AppSettings,
        schedule: WeeklySchedule,
        templates: [WorkoutTemplate],
        customExercises: [Exercise],
        sessions: [WorkoutSession],
        bodyweightLogs: [BodyweightLog],
        favoriteExerciseIDs: Set<String>,
        recentExerciseIDs: [String],
        personalRecords: [PersonalRecord],
        updatedAt: Date
    ) {
        self.profile = profile
        self.settings = settings
        self.schedule = schedule
        self.templates = templates
        self.customExercises = customExercises
        self.sessions = sessions
        self.bodyweightLogs = bodyweightLogs
        self.favoriteExerciseIDs = favoriteExerciseIDs
        self.recentExerciseIDs = recentExerciseIDs
        self.personalRecords = personalRecords
        self.updatedAt = updatedAt
    }

    nonisolated static func empty(for user: AuthUser) -> UserWorkspace {
        let settings = AppSettings.default
        return UserWorkspace(
            profile: UserProfile(
                displayName: user.displayName,
                email: user.email,
                hasCompletedOnboarding: false,
                createdAt: .now,
                updatedAt: .now
            ),
            settings: settings,
            schedule: WeeklySchedule.empty(startingAt: settings.firstWeekday),
            templates: [],
            customExercises: [],
            sessions: [],
            bodyweightLogs: [],
            favoriteExerciseIDs: [],
            recentExerciseIDs: [],
            personalRecords: [],
            updatedAt: .now
        )
    }

    nonisolated static func seeded(for user: AuthUser) -> UserWorkspace {
        let settings = AppSettings.default
        return UserWorkspace(
            profile: UserProfile(
                displayName: user.displayName,
                email: user.email,
                hasCompletedOnboarding: true,
                createdAt: .now,
                updatedAt: .now
            ),
            settings: settings,
            schedule: SeedData.defaultWeeklySchedule(unit: settings.weightUnit),
            templates: [],
            customExercises: [],
            sessions: SeedData.recentSessions(unit: settings.weightUnit),
            bodyweightLogs: SeedData.bodyweightLogs(unit: settings.weightUnit),
            favoriteExerciseIDs: ["bench-press", "lat-pulldown", "barbell-back-squat"],
            recentExerciseIDs: [],
            personalRecords: [],
            updatedAt: .now
        )
    }

    nonisolated func touchingUpdate() -> UserWorkspace {
        var copy = self
        copy.profile.updatedAt = .now
        copy.updatedAt = .now
        return copy
    }

    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.profile = try container.decode(UserProfile.self, forKey: .profile)
        self.settings = try container.decode(AppSettings.self, forKey: .settings)
        self.schedule = try container.decode(WeeklySchedule.self, forKey: .schedule)
        self.templates = try container.decode([WorkoutTemplate].self, forKey: .templates)
        self.customExercises = try container.decode([Exercise].self, forKey: .customExercises)
        self.sessions = try container.decode([WorkoutSession].self, forKey: .sessions)
        self.bodyweightLogs = try container.decode([BodyweightLog].self, forKey: .bodyweightLogs)
        self.favoriteExerciseIDs = try container.decode(Set<String>.self, forKey: .favoriteExerciseIDs)
        self.recentExerciseIDs = try container.decode([String].self, forKey: .recentExerciseIDs)
        self.personalRecords = try container.decode([PersonalRecord].self, forKey: .personalRecords)
        self.updatedAt = try container.decode(Date.self, forKey: .updatedAt)
    }

    nonisolated func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(profile, forKey: .profile)
        try container.encode(settings, forKey: .settings)
        try container.encode(schedule, forKey: .schedule)
        try container.encode(templates, forKey: .templates)
        try container.encode(customExercises, forKey: .customExercises)
        try container.encode(sessions, forKey: .sessions)
        try container.encode(bodyweightLogs, forKey: .bodyweightLogs)
        try container.encode(favoriteExerciseIDs, forKey: .favoriteExerciseIDs)
        try container.encode(recentExerciseIDs, forKey: .recentExerciseIDs)
        try container.encode(personalRecords, forKey: .personalRecords)
        try container.encode(updatedAt, forKey: .updatedAt)
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

extension UserWorkspace {
    var orderedScheduleDays: [ScheduleDayPlan] {
        schedule.orderedDays(startingAt: settings.firstWeekday)
    }
}
