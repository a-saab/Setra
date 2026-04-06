import Charts
import SwiftUI

struct HistoryRootView: View {
    @State private var selection = 0

    var body: some View {
        VStack(spacing: 16) {
            Picker("Mode", selection: $selection) {
                Text("History").tag(0)
                Text("Analytics").tag(1)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 20)
            .padding(.top, 12)

            if selection == 0 {
                WorkoutHistoryView()
            } else {
                AnalyticsView()
            }
        }
        .background(SetraTheme.screenBackground.ignoresSafeArea())
        .navigationTitle("History")
    }
}

private struct WorkoutHistoryView: View {
    @EnvironmentObject private var workspaceStore: WorkspaceStore

    var body: some View {
        List {
            ForEach(workspaceStore.historySessions) { session in
                NavigationLink {
                    WorkoutSummaryView(session: session)
                } label: {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(session.title)
                            .font(.headline)
                        Text(session.startedAt.formatted(.dateTime.month(.abbreviated).day().hour().minute()))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text("Volume \(session.totalVolume.clean)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 6)
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(SetraTheme.screenBackground.ignoresSafeArea())
    }
}

private struct WorkoutSummaryView: View {
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
        SeedData.exerciseLibrary.first(where: { $0.id == id })?.canonicalName ?? "Exercise"
    }
}

private struct AnalyticsView: View {
    @EnvironmentObject private var workspaceStore: WorkspaceStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                GlassCard {
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader("Volume", subtitle: "Weekly working volume")
                        Chart(workspaceStore.analytics.volumeByWeek) { point in
                            BarMark(
                                x: .value("Week", point.label),
                                y: .value("Volume", point.value)
                            )
                            .foregroundStyle(SetraTheme.accentGradient)
                        }
                        .frame(height: 180)
                    }
                }

                GlassCard {
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader("Bodyweight", subtitle: "Trend over time")
                        Chart(workspaceStore.analytics.bodyweightTrend) { point in
                            LineMark(
                                x: .value("Date", point.label),
                                y: .value("Weight", point.value)
                            )
                            .foregroundStyle(SetraTheme.success)
                        }
                        .frame(height: 180)
                    }
                }

                GlassCard {
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader("Recent PRs")
                        ForEach(workspaceStore.analytics.recentPRs) { record in
                            Text(record.label)
                                .foregroundStyle(.white)
                        }
                    }
                }
            }
            .padding(20)
            .padding(.bottom, 20)
        }
        .background(SetraTheme.screenBackground.ignoresSafeArea())
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
