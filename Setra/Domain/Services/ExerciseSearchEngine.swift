import Foundation

struct ExerciseSearchEngine {
    func search(
        query: String,
        filters: ExerciseSearchFilters,
        exercises: [Exercise],
        favorites: Set<String>,
        recents: [String],
        history: [WorkoutSession]
    ) -> [ExerciseSearchResult] {
        let normalizedQuery = normalize(query)

        let filtered = exercises.filter { exercise in
            let muscleMatch = filters.muscleGroup.map { exercise.primaryMuscle == $0 || exercise.secondaryMuscles.contains($0) } ?? true
            let equipmentMatch = filters.equipment.map { exercise.equipment == $0 } ?? true
            let movementMatch = filters.movementPattern.map { exercise.movementPattern == $0 } ?? true
            let favoriteMatch = !filters.favoritesOnly || favorites.contains(exercise.id)
            return muscleMatch && equipmentMatch && movementMatch && favoriteMatch
        }

        return filtered.map { exercise in
            let score = rankingScore(
                query: normalizedQuery,
                exercise: exercise,
                favorites: favorites,
                recents: recents
            )
            let summary = ProgressionEngine().lastPerformance(for: exercise.id, sessions: history)
            let recommendation = summary.map { _ in
                ProgressionEngine().recommendation(
                    for: exercise.id,
                    plannedExercise: nil,
                    exercise: exercise,
                    sessions: history,
                    settings: .default
                )
            } ?? nil
            return ExerciseSearchResult(
                exercise: exercise,
                score: score,
                previousPerformance: summary,
                recommendation: recommendation,
                isFavorite: favorites.contains(exercise.id)
            )
        }
        .filter { normalizedQuery.isEmpty || $0.score > 0 }
        .sorted { lhs, rhs in
            if lhs.score == rhs.score {
                return lhs.exercise.canonicalName < rhs.exercise.canonicalName
            }
            return lhs.score > rhs.score
        }
    }

    private func rankingScore(
        query: String,
        exercise: Exercise,
        favorites: Set<String>,
        recents: [String]
    ) -> Int {
        var score = 0
        let canonical = normalize(exercise.canonicalName)
        let aliases = exercise.searchTerms.map(normalize)

        if query.isEmpty {
            score += favorites.contains(exercise.id) ? 32 : 0
            score += recents.firstIndex(of: exercise.id).map { max(0, 24 - ($0 * 4)) } ?? 0
            return score + 1
        }

        if canonical == query { score += 120 }
        if aliases.contains(query) { score += 96 }
        if canonical.hasPrefix(query) { score += 84 }
        if aliases.contains(where: { $0.hasPrefix(query) }) { score += 70 }
        if aliases.contains(where: { $0.contains(query) }) { score += 58 }

        let tokens = query.split(separator: " ").map(String.init)
        if tokens.allSatisfy({ token in
            canonical.contains(token) || aliases.contains(where: { $0.contains(token) })
        }) {
            score += 44
        }

        let distances = aliases.map { levenshteinDistance($0, query) }
        if let bestDistance = distances.min() {
            score += max(0, 36 - (bestDistance * 4))
        }

        if favorites.contains(exercise.id) { score += 18 }
        if let index = recents.firstIndex(of: exercise.id) {
            score += max(0, 12 - (index * 2))
        }
        return score
    }

    private func normalize(_ value: String) -> String {
        value
            .lowercased()
            .replacingOccurrences(of: "-", with: " ")
            .replacingOccurrences(of: "_", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func levenshteinDistance(_ lhs: String, _ rhs: String) -> Int {
        let lhsChars = Array(lhs)
        let rhsChars = Array(rhs)
        var dist = Array(
            repeating: Array(repeating: 0, count: rhsChars.count + 1),
            count: lhsChars.count + 1
        )

        for i in 0...lhsChars.count { dist[i][0] = i }
        for j in 0...rhsChars.count { dist[0][j] = j }

        for i in 1...lhsChars.count {
            for j in 1...rhsChars.count {
                if lhsChars[i - 1] == rhsChars[j - 1] {
                    dist[i][j] = dist[i - 1][j - 1]
                } else {
                    dist[i][j] = min(
                        dist[i - 1][j] + 1,
                        dist[i][j - 1] + 1,
                        dist[i - 1][j - 1] + 1
                    )
                }
            }
        }

        return dist[lhsChars.count][rhsChars.count]
    }
}
