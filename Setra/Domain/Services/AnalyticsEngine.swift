import Foundation

struct AnalyticsEngine {
    func makeSnapshot(
        workspace: UserWorkspace,
        exerciseLibrary: [Exercise]
    ) -> AnalyticsSnapshot {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: workspace.sessions.filter { $0.state == .completed }) { session in
            let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: session.startedAt)
            return calendar.date(from: components) ?? session.startedAt
        }

        let volumeByWeek = grouped.keys.sorted().map { weekStart in
            AnalyticsPoint(
                label: weekStart.formatted(.dateTime.month(.abbreviated).day()),
                value: grouped[weekStart]?.reduce(0, { $0 + $1.totalVolume }) ?? 0
            )
        }

        let bodyweightTrend = workspace.bodyweightLogs.sorted(by: { $0.date < $1.date }).map {
            AnalyticsPoint(
                label: $0.date.formatted(.dateTime.month(.abbreviated).day()),
                value: $0.weight
            )
        }

        let weeklyConsistency = grouped.keys.sorted().map { weekStart in
            AnalyticsPoint(
                label: weekStart.formatted(.dateTime.month(.abbreviated).day()),
                value: Double(grouped[weekStart]?.count ?? 0)
            )
        }

        return AnalyticsSnapshot(
            volumeByWeek: volumeByWeek,
            bodyweightTrend: bodyweightTrend,
            weeklyConsistency: weeklyConsistency,
            streakCount: streakCount(from: workspace.sessions),
            recentPRs: personalRecords(from: workspace.sessions, exerciseLibrary: exerciseLibrary).prefix(6).map { $0 }
        )
    }

    func personalRecords(
        from sessions: [WorkoutSession],
        exerciseLibrary: [Exercise]
    ) -> [PersonalRecord] {
        var bestByExercise: [String: PersonalRecord] = [:]

        for session in sessions where session.state == .completed {
            for exercise in session.exercises {
                let sets = exercise.workingSets.compactMap { set -> PersonalRecord? in
                    guard let load = set.load, let reps = set.reps else { return nil }
                    return PersonalRecord(
                        id: "\(exercise.exerciseID)-\(Int(load))-\(reps)",
                        exerciseID: exercise.exerciseID,
                        date: session.startedAt,
                        weight: load,
                        reps: reps,
                        unit: session.unit,
                        label: "Best \(load.clean) \(session.unit.shortLabel) × \(reps)"
                    )
                }

                for record in sets {
                    let existing = bestByExercise[record.exerciseID]
                    let candidateScore = record.weight * Double(record.reps)
                    let existingScore = existing.map { $0.weight * Double($0.reps) } ?? 0
                    if candidateScore >= existingScore {
                        bestByExercise[record.exerciseID] = record
                    }
                }
            }
        }

        return bestByExercise.values.sorted { $0.date > $1.date }
    }

    private func streakCount(from sessions: [WorkoutSession]) -> Int {
        let calendar = Calendar.current
        let sessionDays = Set(sessions.filter { $0.state == .completed }.map { calendar.startOfDay(for: $0.startedAt) })
        var streak = 0
        var current = calendar.startOfDay(for: .now)

        while sessionDays.contains(current) {
            streak += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: current) else { break }
            current = previous
        }

        return streak
    }
}
