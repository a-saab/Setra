import SwiftUI

struct ExerciseDetailView: View {
    @Environment(WorkspaceStore.self) private var workspaceStore
    @Environment(AuthController.self) private var authController

    let exercise: Exercise

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                GlassCard {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: exercise.primaryMuscle.symbolName)
                                .font(.largeTitle)
                                .foregroundStyle(SetraTheme.accent)
                            Spacer()
                            Button {
                                toggleFavorite()
                            } label: {
                                Image(systemName: isFavorite ? "star.fill" : "star")
                                    .font(.title3)
                                    .foregroundStyle(isFavorite ? SetraTheme.warning : .secondary)
                            }
                        }

                        Text(exercise.canonicalName)
                            .font(.title.weight(.bold))
                            .foregroundStyle(.white)
                        Text("\(exercise.primaryMuscle.title) • \(exercise.equipment.title) • \(exercise.exerciseType.title)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        HStack(spacing: 12) {
                            StatChip(label: "Default", value: "\(exercise.defaultSetCount) × \(exercise.defaultRepRange.title)")
                            StatChip(label: "Rest", value: "\(exercise.defaultRestTime)s", accent: SetraTheme.accentSecondary)
                        }
                    }
                }

                if let last = workspaceStore.performanceSummary(for: exercise.id) {
                    GlassCard {
                        VStack(alignment: .leading, spacing: 10) {
                            SectionHeader("Previous Performance")
                            Text(last.lastDescription)
                                .font(.body)
                                .foregroundStyle(.white)
                            Text("Best: \(last.bestDescription)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            if let next = workspaceStore.progressionSuggestion(for: exercise.id) {
                                Text(next.reason)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(SetraTheme.success)
                            }
                        }
                    }
                }

                GlassCard {
                    VStack(alignment: .leading, spacing: 10) {
                        SectionHeader("Coaching Notes")
                        Text(exercise.notes)
                            .foregroundStyle(.white)
                        ForEach(exercise.cues, id: \.self) { cue in
                            Text("• \(cue)")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .padding(20)
            .padding(.bottom, 20)
        }
        .background(SetraTheme.screenBackground.ignoresSafeArea())
        .navigationTitle("Exercise")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var isFavorite: Bool {
        workspaceStore.workspace?.favoriteExerciseIDs.contains(exercise.id) ?? false
    }

    private func toggleFavorite() {
        guard let user = authController.currentUser else { return }
        Task {
            await workspaceStore.toggleFavorite(exerciseID: exercise.id, for: user)
        }
    }
}

struct ExerciseDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ExerciseDetailView(exercise: SeedData.exerciseLibrary.first!)
        }
        .setraPreviewEnvironment()
    }
}
