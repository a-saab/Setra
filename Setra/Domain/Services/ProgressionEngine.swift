import Foundation

struct ProgressionEngine {
    func recommendation(
        for exerciseID: String,
        plannedExercise: PlannedExercise?,
        exercise: Exercise?,
        sessions: [WorkoutSession],
        settings: AppSettings
    ) -> ProgressionRecommendation? {
        guard let summary = lastPerformance(for: exerciseID, sessions: sessions) else { return nil }
        let repRange = plannedExercise?.targetRepRange ?? exercise?.defaultRepRange ?? RepRange(lowerBound: 8, upperBound: 10)
        let increment = incrementAmount(for: exercise, settings: settings)
        let hitTopRange = summary.reps.allSatisfy { $0 >= repRange.upperBound }
        let nextWeight = hitTopRange ? (summary.lastWeight ?? 0) + increment : summary.lastWeight

        return ProgressionRecommendation(
            suggestedWeight: nextWeight,
            unit: summary.unit,
            reason: hitTopRange
                ? "Top end of \(repRange.title) achieved on all working sets. Increase by \(increment.clean) \(summary.unit.shortLabel) next time."
                : "Repeat \(summary.lastWeight?.clean ?? "last load") \(summary.unit.shortLabel) and beat last session's reps.",
            shouldIncrease: hitTopRange
        )
    }

    func lastPerformance(for exerciseID: String, sessions: [WorkoutSession]) -> ExercisePerformanceSummary? {
        guard
            let match = sessions.sorted(by: { $0.startedAt > $1.startedAt })
                .first(where: { $0.exercises.contains(where: { $0.exerciseID == exerciseID }) }),
            let loggedExercise = match.exercises.first(where: { $0.exerciseID == exerciseID })
        else {
            return nil
        }

        let workingSets = loggedExercise.workingSets
        let reps = workingSets.compactMap(\.reps)
        let weights = workingSets.compactMap(\.load)
        let lastWeight = workingSets.last?.load ?? weights.last
        let bestWeight = weights.max()

        return ExercisePerformanceSummary(
            date: match.startedAt,
            lastWeight: lastWeight,
            bestWeight: bestWeight,
            reps: reps,
            unit: match.unit,
            bestDescription: "\(bestWeight?.clean ?? "-") \(match.unit.shortLabel) × \(reps.max() ?? 0)",
            lastDescription: "Last time: \(lastWeight?.clean ?? "-") \(match.unit.shortLabel) × " + reps.map(String.init).joined(separator: ", ")
        )
    }

    private func incrementAmount(for exercise: Exercise?, settings: AppSettings) -> Double {
        if let rule = exercise?.progressionRule {
            return rule.increment
        }

        switch exercise?.primaryMuscle {
        case .quads, .hamstrings, .glutes, .calves:
            return settings.lowerBodyIncrement
        default:
            return settings.upperBodyIncrement
        }
    }
}
