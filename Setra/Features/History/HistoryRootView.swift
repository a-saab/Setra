import Charts
import SwiftUI

struct HistoryRootView: View {
    @Environment(ProgressStore.self) private var progressStore

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 18) {
                summaryCard
                volumeCard
                recordsCard
                recentSessionsCard
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .padding(.bottom, 20)
        }
        .scrollIndicators(.hidden)
        .background(
            SetraTheme.screenBackground
                .overlay(SetraTheme.ambientGlow)
                .ignoresSafeArea()
        )
        .navigationTitle("Progress")
    }

    private var summaryCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader("Progress Summary", subtitle: "History and analytics should feel like one coherent story")

                HStack(spacing: 12) {
                    StatChip(label: "Sessions", value: "\(progressStore.historySessions.count)")
                    StatChip(label: "Records", value: "\(progressStore.analytics.recentPRs.count)", accent: SetraTheme.success)
                    StatChip(label: "Streak", value: "\(progressStore.analytics.streakCount)d", accent: SetraTheme.accentSecondary)
                }
            }
        }
    }

    private var volumeCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader("Volume Trend", subtitle: "Weekly work should be visible without opening a separate mode")

                if progressStore.analytics.volumeByWeek.isEmpty {
                    Text("Volume appears after completed workouts. The redesign goal is to make low-data states feel calm, not barren.")
                        .font(.footnote)
                        .foregroundStyle(SetraTheme.secondaryText)
                } else {
                    Chart(progressStore.analytics.volumeByWeek) { point in
                        BarMark(
                            x: .value("Week", point.label),
                            y: .value("Volume", point.value)
                        )
                        .foregroundStyle(SetraTheme.accentGradient)
                        .clipShape(.rect(cornerRadius: 8))
                    }
                    .frame(height: 190)
                    .chartXAxis {
                        AxisMarks(values: .automatic(desiredCount: 4))
                    }
                    .chartYAxis(.hidden)
                }
            }
        }
    }

    private var recordsCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionHeader("Recent Bests", subtitle: "The moments that create emotional payoff after training")

                if progressStore.analytics.recentPRs.isEmpty {
                    Text("No records yet. Your first sessions are still valuable because they define the baseline.")
                        .font(.footnote)
                        .foregroundStyle(SetraTheme.secondaryText)
                } else {
                    ForEach(progressStore.analytics.recentPRs.prefix(5)) { record in
                        HStack(spacing: 14) {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(SetraTheme.mutedFill)
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Image(systemName: "sparkles")
                                        .foregroundStyle(SetraTheme.success)
                                )

                            VStack(alignment: .leading, spacing: 4) {
                                Text(exerciseName(for: record.exerciseID))
                                    .font(.headline.weight(.semibold))
                                    .foregroundStyle(SetraTheme.primaryText)
                                Text(record.label)
                                    .font(.subheadline)
                                    .foregroundStyle(SetraTheme.secondaryText)
                            }

                            Spacer()
                        }
                    }
                }
            }
        }
    }

    private var recentSessionsCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionHeader("Recent Sessions", subtitle: "The latest training history should stay close to the summary")

                if progressStore.historySessions.isEmpty {
                    Text("No workouts logged yet.")
                        .font(.footnote)
                        .foregroundStyle(SetraTheme.secondaryText)
                } else {
                    ForEach(progressStore.historySessions.prefix(8)) { session in
                        NavigationLink {
                            WorkoutSummaryView(session: session)
                        } label: {
                            HStack(spacing: 14) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(session.title)
                                        .font(.headline.weight(.semibold))
                                        .foregroundStyle(SetraTheme.primaryText)
                                    Text(session.startedAt.formatted(.dateTime.month(.abbreviated).day().hour().minute()))
                                        .font(.subheadline)
                                        .foregroundStyle(SetraTheme.secondaryText)
                                }

                                Spacer()

                                Text(session.totalVolume.clean)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(SetraTheme.accent)
                            }
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func exerciseName(for id: String) -> String {
        progressStore.exercise(by: id)?.canonicalName ?? "Exercise"
    }
}

private struct WorkoutSummaryView: View {
    @Environment(ProgressStore.self) private var progressStore

    let session: WorkoutSession

    var body: some View {
        List {
            ForEach(session.exercises) { exercise in
                Section(workspaceExerciseName(exercise.exerciseID)) {
                    ForEach(exercise.workingSets) { set in
                        HStack {
                            Text("\(set.load?.clean ?? "-") \(session.unit.shortLabel)")
                            Spacer()
                            Text("\(set.reps ?? 0) reps")
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(session.title)
    }

    private func workspaceExerciseName(_ id: String) -> String {
        progressStore.exercise(by: id)?.canonicalName ?? "Exercise"
    }
}

struct HistoryRootView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HistoryRootView()
        }
        .setraPreviewEnvironment()
    }
}
