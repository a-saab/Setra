import SwiftUI

struct AddExerciseSearchView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ExerciseLibraryStore.self) private var exerciseLibraryStore

    @State private var query = ""
    @State private var filters = ExerciseSearchFilters()
    @State private var isCreatePresented = false

    let onSelect: (Exercise) -> Void

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("Muscle", selection: $filters.muscleGroup) {
                        Text("All Muscles").tag(MuscleGroup?.none)
                        ForEach(MuscleGroup.allCases) { group in
                            Text(group.title).tag(MuscleGroup?.some(group))
                        }
                    }

                    Picker("Equipment", selection: $filters.equipment) {
                        Text("All Equipment").tag(EquipmentType?.none)
                        ForEach(EquipmentType.allCases) { equipment in
                            Text(equipment.title).tag(EquipmentType?.some(equipment))
                        }
                    }

                    Toggle("Favorites Only", isOn: $filters.favoritesOnly)
                }

                Section("Results") {
                    ForEach(results) { result in
                        Button {
                            onSelect(result.exercise)
                            dismiss()
                        } label: {
                            ExerciseSearchRow(result: result)
                        }
                        .buttonStyle(.plain)
                    }

                    if results.isEmpty {
                        ContentUnavailableView(
                            "No Exercises Found",
                            systemImage: "magnifyingglass",
                            description: Text("Create a custom exercise if your library doesn’t have it yet.")
                        )
                    }
                }
            }
            .searchable(text: $query, prompt: "Search exercises")
            .scrollContentBackground(.hidden)
            .background(SetraTheme.screenBackground.ignoresSafeArea())
            .navigationTitle("Add Exercise")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Custom") {
                        isCreatePresented = true
                    }
                }
            }
            .sheet(isPresented: $isCreatePresented) {
                CustomExerciseCreatorView { exercise in
                    onSelect(exercise)
                    dismiss()
                }
            }
        }
    }

    private var results: [ExerciseSearchResult] {
        exerciseLibraryStore.searchExercises(query: query, filters: filters)
    }
}

private struct ExerciseSearchRow: View {
    let result: ExerciseSearchResult

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: result.exercise.primaryMuscle.symbolName)
                    .foregroundStyle(SetraTheme.accent)
                    .frame(width: 28)
                VStack(alignment: .leading, spacing: 4) {
                    Text(result.exercise.canonicalName)
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text("\(result.exercise.primaryMuscle.title) • \(result.exercise.equipment.title)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if result.isFavorite {
                    Image(systemName: "star.fill")
                        .foregroundStyle(SetraTheme.warning)
                }
            }
            if let performance = result.previousPerformance {
                Text(performance.lastDescription)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            if let recommendation = result.recommendation {
                Text(recommendation.reason)
                    .font(.footnote)
                    .foregroundStyle(SetraTheme.accent)
            }
        }
        .padding(.vertical, 6)
    }
}
