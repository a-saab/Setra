import Foundation

enum SeedData {
    nonisolated static let exerciseLibrary: [Exercise] = [
        exercise("barbell-back-squat", "Barbell Back Squat", aliases: ["squat", "back squat"], primary: .quads, secondary: [.glutes, .hamstrings], equipment: .barbell, pattern: .squat, type: .barbell, reps: RepRange(lowerBound: 5, upperBound: 8), sets: 4, rest: 180, notes: "Brace hard and keep the bar stacked over mid-foot.", keywords: ["legs", "compound"], progression: .lowerBodyDefault),
        exercise("romanian-deadlift", "Romanian Deadlift", aliases: ["rdl"], primary: .hamstrings, secondary: [.glutes, .back], equipment: .barbell, pattern: .hinge, type: .barbell, reps: RepRange(lowerBound: 6, upperBound: 10), sets: 3, rest: 150, notes: "Push hips back and keep lats engaged.", keywords: ["posterior chain"], progression: .lowerBodyDefault),
        exercise("leg-press", "Leg Press", aliases: ["sled press"], primary: .quads, secondary: [.glutes], equipment: .machine, pattern: .squat, type: .machine, reps: RepRange(lowerBound: 10, upperBound: 15), sets: 3, rest: 120, notes: "Control the eccentric and avoid lifting hips.", keywords: ["machine legs"], progression: .lowerBodyDefault),
        exercise("lying-leg-curl", "Lying Leg Curl", aliases: ["ham curl"], primary: .hamstrings, secondary: [.calves], equipment: .machine, pattern: .curl, type: .machine, reps: RepRange(lowerBound: 10, upperBound: 15), sets: 3, rest: 90, notes: "Curl through the heel and control the return.", keywords: ["hamstring"], progression: .lowerBodyDefault),
        exercise("standing-calf-raise", "Standing Calf Raise", aliases: ["calf raise"], primary: .calves, secondary: [], equipment: .machine, pattern: .extensionPattern, type: .machine, reps: RepRange(lowerBound: 12, upperBound: 20), sets: 4, rest: 60, notes: "Pause at the top and stretch the bottom.", keywords: ["calves"], progression: .lowerBodyDefault),
        exercise("bench-press", "Barbell Bench Press", aliases: ["bench", "flat bench"], primary: .chest, secondary: [.triceps, .shoulders], equipment: .barbell, pattern: .press, type: .barbell, reps: RepRange(lowerBound: 5, upperBound: 8), sets: 4, rest: 150, notes: "Keep your upper back tight and drive feet into the floor.", keywords: ["push", "compound"], progression: .upperBodyDefault),
        exercise("incline-dumbbell-press", "Incline Dumbbell Press", aliases: ["incline db press"], primary: .chest, secondary: [.shoulders, .triceps], equipment: .dumbbell, pattern: .press, type: .dumbbell, reps: RepRange(lowerBound: 8, upperBound: 12), sets: 3, rest: 120, notes: "Drive elbows slightly inward and keep a soft arch.", keywords: ["upper chest"], progression: .upperBodyDefault),
        exercise("machine-chest-press", "Machine Chest Press", aliases: ["chest press"], primary: .chest, secondary: [.triceps], equipment: .machine, pattern: .press, type: .machine, reps: RepRange(lowerBound: 8, upperBound: 12), sets: 3, rest: 90, notes: "Keep tension at lockout instead of resting.", keywords: ["machine chest"], progression: .upperBodyDefault),
        exercise("cable-fly", "Cable Fly", aliases: ["pec fly"], primary: .chest, secondary: [.shoulders], equipment: .cable, pattern: .isolation, type: .cable, reps: RepRange(lowerBound: 12, upperBound: 15), sets: 3, rest: 75, notes: "Reach across slightly and keep tension in the chest.", keywords: ["isolation"], progression: .upperBodyDefault),
        exercise("lat-pulldown", "Lat Pulldown", aliases: ["pulldown"], primary: .back, secondary: [.biceps], equipment: .cable, pattern: .pull, type: .cable, reps: RepRange(lowerBound: 8, upperBound: 12), sets: 3, rest: 90, notes: "Lead with elbows and keep ribs stacked.", keywords: ["lats", "vertical pull"], progression: .upperBodyDefault),
        exercise("chest-supported-row", "Chest-Supported Row", aliases: ["machine row"], primary: .back, secondary: [.biceps, .shoulders], equipment: .machine, pattern: .row, type: .machine, reps: RepRange(lowerBound: 8, upperBound: 12), sets: 3, rest: 90, notes: "Pull through your elbows and pause on the contraction.", keywords: ["rowing"], progression: .upperBodyDefault),
        exercise("one-arm-dumbbell-row", "One-Arm Dumbbell Row", aliases: ["db row"], primary: .back, secondary: [.biceps], equipment: .dumbbell, pattern: .row, type: .dumbbell, reps: RepRange(lowerBound: 8, upperBound: 12), sets: 3, rest: 90, notes: "Keep hips stable and let the shoulder blade travel.", keywords: ["dumbbell back"], progression: .upperBodyDefault),
        exercise("seated-cable-row", "Seated Cable Row", aliases: ["cable row"], primary: .back, secondary: [.biceps], equipment: .cable, pattern: .row, type: .cable, reps: RepRange(lowerBound: 10, upperBound: 14), sets: 3, rest: 75, notes: "Stay tall and finish with shoulder blades tucked.", keywords: ["middle back"], progression: .upperBodyDefault),
        exercise("overhead-press", "Standing Overhead Press", aliases: ["ohp", "military press"], primary: .shoulders, secondary: [.triceps, .chest], equipment: .barbell, pattern: .press, type: .barbell, reps: RepRange(lowerBound: 5, upperBound: 8), sets: 3, rest: 150, notes: "Squeeze glutes and keep the bar close to your face.", keywords: ["delts"], progression: .upperBodyDefault),
        exercise("dumbbell-lateral-raise", "Dumbbell Lateral Raise", aliases: ["lat raise"], primary: .shoulders, secondary: [], equipment: .dumbbell, pattern: .raise, type: .dumbbell, reps: RepRange(lowerBound: 12, upperBound: 18), sets: 3, rest: 60, notes: "Raise elbows wide and keep traps relaxed.", keywords: ["side delts"], progression: .upperBodyDefault),
        exercise("rear-delt-fly", "Rear Delt Fly", aliases: ["reverse fly"], primary: .shoulders, secondary: [.back], equipment: .machine, pattern: .raise, type: .machine, reps: RepRange(lowerBound: 12, upperBound: 18), sets: 3, rest: 60, notes: "Think wide, not back.", keywords: ["rear delt"], progression: .upperBodyDefault),
        exercise("barbell-curl", "Barbell Curl", aliases: ["curl"], primary: .biceps, secondary: [.forearms], equipment: .barbell, pattern: .curl, type: .barbell, reps: RepRange(lowerBound: 8, upperBound: 12), sets: 3, rest: 60, notes: "Keep elbows quiet and fully lengthen at the bottom.", keywords: ["arms"], progression: .upperBodyDefault),
        exercise("incline-dumbbell-curl", "Incline Dumbbell Curl", aliases: ["incline curl"], primary: .biceps, secondary: [.forearms], equipment: .dumbbell, pattern: .curl, type: .dumbbell, reps: RepRange(lowerBound: 10, upperBound: 14), sets: 3, rest: 60, notes: "Supinate hard and keep shoulders pinned.", keywords: ["biceps"], progression: .upperBodyDefault),
        exercise("hammer-curl", "Hammer Curl", aliases: ["db hammer curl"], primary: .forearms, secondary: [.biceps], equipment: .dumbbell, pattern: .curl, type: .dumbbell, reps: RepRange(lowerBound: 10, upperBound: 14), sets: 3, rest: 60, notes: "Keep palms neutral and squeeze high.", keywords: ["brachialis"], progression: .upperBodyDefault),
        exercise("cable-pushdown", "Cable Pushdown", aliases: ["triceps pushdown"], primary: .triceps, secondary: [], equipment: .cable, pattern: .extensionPattern, type: .cable, reps: RepRange(lowerBound: 10, upperBound: 15), sets: 3, rest: 60, notes: "Keep upper arms pinned and finish with a hard lockout.", keywords: ["triceps"], progression: .upperBodyDefault),
        exercise("overhead-triceps-extension", "Overhead Cable Triceps Extension", aliases: ["overhead extension"], primary: .triceps, secondary: [], equipment: .cable, pattern: .extensionPattern, type: .cable, reps: RepRange(lowerBound: 10, upperBound: 15), sets: 3, rest: 60, notes: "Reach long and let the elbows bend fully.", keywords: ["long head"], progression: .upperBodyDefault),
        exercise("close-grip-bench", "Close-Grip Bench Press", aliases: ["cgbp"], primary: .triceps, secondary: [.chest], equipment: .barbell, pattern: .press, type: .barbell, reps: RepRange(lowerBound: 6, upperBound: 10), sets: 3, rest: 120, notes: "Tuck elbows slightly and keep wrists stacked.", keywords: ["press"], progression: .upperBodyDefault),
        exercise("wrist-curl", "Wrist Curl", aliases: ["forearm curl"], primary: .forearms, secondary: [], equipment: .barbell, pattern: .curl, type: .barbell, reps: RepRange(lowerBound: 12, upperBound: 18), sets: 2, rest: 45, notes: "Move only through the wrist and pause at peak contraction.", keywords: ["forearms"], progression: .upperBodyDefault),
        exercise("hanging-leg-raise", "Hanging Leg Raise", aliases: ["leg raise"], primary: .abs, secondary: [.core], equipment: .bodyweight, pattern: .core, type: .bodyweight, reps: RepRange(lowerBound: 8, upperBound: 15), sets: 3, rest: 60, notes: "Posteriorly tilt the pelvis at the top.", keywords: ["core"], progression: .upperBodyDefault),
        exercise("ab-wheel-rollout", "Ab Wheel Rollout", aliases: ["rollout"], primary: .core, secondary: [.abs], equipment: .bodyweight, pattern: .core, type: .bodyweight, reps: RepRange(lowerBound: 8, upperBound: 12), sets: 3, rest: 60, notes: "Keep ribs down and move as one unit.", keywords: ["trunk"], progression: .upperBodyDefault),
        exercise("plank", "Weighted Plank", aliases: ["plank"], primary: .core, secondary: [.abs], equipment: .bodyweight, pattern: .core, type: .bodyweight, reps: RepRange(lowerBound: 30, upperBound: 60), sets: 3, rest: 45, notes: "Brace hard and avoid drifting into extension.", keywords: ["stability"], progression: .upperBodyDefault),
    ]

    nonisolated static func defaultWeeklySchedule(unit: WeightUnit) -> WeeklySchedule {
        WeeklySchedule(
            id: UUID().uuidString,
            title: "Setra Default Split",
            notes: "Premium base template optimized for repeatable progression.",
            days: [
                ScheduleDayPlan(
                    id: UUID().uuidString,
                    weekday: .monday,
                    kind: .workout,
                    title: "Upper A",
                    subtitle: "Horizontal push + pull",
                    notes: "Push main work, pull hard, keep 1-2 reps in reserve.",
                    exercises: [
                        PlannedExercise.from(exercise: find("bench-press"), unit: unit, order: 0),
                        PlannedExercise.from(exercise: find("chest-supported-row"), unit: unit, order: 1),
                        PlannedExercise.from(exercise: find("incline-dumbbell-press"), unit: unit, order: 2),
                        PlannedExercise.from(exercise: find("dumbbell-lateral-raise"), unit: unit, order: 3),
                        PlannedExercise.from(exercise: find("cable-pushdown"), unit: unit, order: 4),
                    ]
                ),
                ScheduleDayPlan(
                    id: UUID().uuidString,
                    weekday: .tuesday,
                    kind: .workout,
                    title: "Lower A",
                    subtitle: "Squat dominant",
                    notes: "Control eccentrics and own the top end of the rep range.",
                    exercises: [
                        PlannedExercise.from(exercise: find("barbell-back-squat"), unit: unit, order: 0),
                        PlannedExercise.from(exercise: find("romanian-deadlift"), unit: unit, order: 1),
                        PlannedExercise.from(exercise: find("leg-press"), unit: unit, order: 2),
                        PlannedExercise.from(exercise: find("standing-calf-raise"), unit: unit, order: 3),
                        PlannedExercise.from(exercise: find("ab-wheel-rollout"), unit: unit, order: 4),
                    ]
                ),
                ScheduleDayPlan.restDay(for: .wednesday),
                ScheduleDayPlan(
                    id: UUID().uuidString,
                    weekday: .thursday,
                    kind: .workout,
                    title: "Upper B",
                    subtitle: "Vertical push + pull",
                    notes: "Chase clean reps and leave the gym with energy left.",
                    exercises: [
                        PlannedExercise.from(exercise: find("overhead-press"), unit: unit, order: 0),
                        PlannedExercise.from(exercise: find("lat-pulldown"), unit: unit, order: 1),
                        PlannedExercise.from(exercise: find("seated-cable-row"), unit: unit, order: 2),
                        PlannedExercise.from(exercise: find("incline-dumbbell-curl"), unit: unit, order: 3),
                        PlannedExercise.from(exercise: find("overhead-triceps-extension"), unit: unit, order: 4),
                    ]
                ),
                ScheduleDayPlan(
                    id: UUID().uuidString,
                    weekday: .friday,
                    kind: .workout,
                    title: "Lower B",
                    subtitle: "Hinge + unilateral",
                    notes: "Push performance but keep positions crisp.",
                    exercises: [
                        PlannedExercise.from(exercise: find("romanian-deadlift"), unit: unit, order: 0),
                        PlannedExercise.from(exercise: find("leg-press"), unit: unit, order: 1),
                        PlannedExercise.from(exercise: find("lying-leg-curl"), unit: unit, order: 2),
                        PlannedExercise.from(exercise: find("standing-calf-raise"), unit: unit, order: 3),
                        PlannedExercise.from(exercise: find("hanging-leg-raise"), unit: unit, order: 4),
                    ]
                ),
                ScheduleDayPlan.restDay(for: .saturday),
                ScheduleDayPlan.restDay(for: .sunday),
            ]
        )
    }

    nonisolated static func recentSessions(unit: WeightUnit) -> [WorkoutSession] {
        [
            WorkoutSession(
                id: UUID().uuidString,
                weekday: .thursday,
                title: "Upper B",
                subtitle: "Vertical push + pull",
                startedAt: Calendar.current.date(byAdding: .day, value: -3, to: .now) ?? .now,
                completedAt: Calendar.current.date(byAdding: .day, value: -3, to: .now) ?? .now,
                notes: "",
                state: .completed,
                exercises: [
                    logged("overhead-press", unit: unit, weight: 95, reps: [8, 8, 7]),
                    logged("lat-pulldown", unit: unit, weight: 140, reps: [12, 11, 10]),
                    logged("incline-dumbbell-curl", unit: unit, weight: 30, reps: [12, 11, 10]),
                ],
                unit: unit
            ),
            WorkoutSession(
                id: UUID().uuidString,
                weekday: .monday,
                title: "Upper A",
                subtitle: "Horizontal push + pull",
                startedAt: Calendar.current.date(byAdding: .day, value: -7, to: .now) ?? .now,
                completedAt: Calendar.current.date(byAdding: .day, value: -7, to: .now) ?? .now,
                notes: "",
                state: .completed,
                exercises: [
                    logged("bench-press", unit: unit, weight: 185, reps: [10, 10, 9]),
                    logged("chest-supported-row", unit: unit, weight: 100, reps: [12, 12, 11]),
                    logged("cable-pushdown", unit: unit, weight: 60, reps: [15, 14, 13]),
                ],
                unit: unit
            ),
            WorkoutSession(
                id: UUID().uuidString,
                weekday: .tuesday,
                title: "Lower A",
                subtitle: "Squat dominant",
                startedAt: Calendar.current.date(byAdding: .day, value: -8, to: .now) ?? .now,
                completedAt: Calendar.current.date(byAdding: .day, value: -8, to: .now) ?? .now,
                notes: "",
                state: .completed,
                exercises: [
                    logged("barbell-back-squat", unit: unit, weight: 225, reps: [8, 8, 8]),
                    logged("romanian-deadlift", unit: unit, weight: 185, reps: [10, 10, 10]),
                    logged("standing-calf-raise", unit: unit, weight: 180, reps: [18, 16, 15]),
                ],
                unit: unit
            ),
        ]
    }

    nonisolated static func bodyweightLogs(unit: WeightUnit) -> [BodyweightLog] {
        (0..<8).map { index in
            BodyweightLog(
                id: UUID().uuidString,
                date: Calendar.current.date(byAdding: .day, value: -(index * 7), to: .now) ?? .now,
                weight: 183.4 - Double(index) * 0.4,
                unit: unit,
                note: ""
            )
        }
    }

    private nonisolated static func exercise(
        _ id: String,
        _ name: String,
        aliases: [String],
        primary: MuscleGroup,
        secondary: [MuscleGroup],
        equipment: EquipmentType,
        pattern: MovementPattern,
        type: ExerciseType,
        reps: RepRange,
        sets: Int,
        rest: Int,
        notes: String,
        keywords: [String],
        progression: ProgressionRule
    ) -> Exercise {
        Exercise(
            id: id,
            source: .builtIn,
            canonicalName: name,
            aliases: aliases,
            primaryMuscle: primary,
            secondaryMuscles: secondary,
            equipment: equipment,
            movementPattern: pattern,
            exerciseType: type,
            defaultRepRange: reps,
            defaultSetCount: sets,
            defaultRestTime: rest,
            notes: notes,
            cues: keywords,
            lastSetToFailure: false,
            intensityStyle: .none,
            keywords: keywords,
            progressionRule: progression,
            media: ExerciseMedia(localSymbolName: primary.symbolName, remoteURL: nil, userImagePath: nil)
        )
    }

    private nonisolated static func find(_ id: String) -> Exercise {
        exerciseLibrary.first { $0.id == id }!
    }

    private nonisolated static func logged(_ exerciseID: String, unit: WeightUnit, weight: Double, reps: [Int]) -> LoggedExercise {
        LoggedExercise(
            id: UUID().uuidString,
            plannedExerciseID: nil,
            exerciseID: exerciseID,
            order: 0,
            targetSets: reps.count,
            targetRepRange: RepRange(lowerBound: reps.min() ?? 8, upperBound: reps.max() ?? 10),
            warmUpSets: [],
            workingSets: reps.map {
                SetLog(
                    id: UUID().uuidString,
                    kind: .working,
                    targetReps: $0,
                    reps: $0,
                    load: weight,
                    unit: unit,
                    isPerHand: false,
                    didReachFailure: false,
                    note: ""
                )
            },
            notes: "",
            completedAllPrescribedWork: true,
            lastSetFailureCompleted: false,
            previousPerformance: nil,
            suggestedLoad: nil
        )
    }
}
