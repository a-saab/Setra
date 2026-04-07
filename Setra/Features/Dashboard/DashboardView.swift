import Charts
import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var workspaceStore: WorkspaceStore

    @State private var activeWorkout: WorkoutSession?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                SectionHeader("Today", subtitle: todayGreeting)

                if let plan = todayPlan {
                    DashboardHeroCard(
                        day: plan,
                        previousSummary: plan.exercises.first.flatMap { workspaceStore.performanceSummary(for: $0.exerciseID) },
                        onStart: {
                            activeWorkout = workspaceStore.startWorkout(from: plan)
                        }
                    )
                }

                GlassCard {
                    VStack(alignment: .leading, spacing: 14) {
                        SectionHeader("Weekly Pulse", subtitle: "Consistency, progress, and upcoming work")
                        HStack(spacing: 12) {
                            StatChip(label: "Adherence", value: adherenceText)
                            StatChip(label: "Streak", value: "\(workspaceStore.analytics.streakCount) days", accent: SetraTheme.success)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        if let recentPR = workspaceStore.analytics.recentPRs.first,
                           let exercise = workspaceStore.exercise(by: recentPR.exerciseID) {
                            HighlightRow(
                                title: "Recent PR",
                                subtitle: "\(exercise.canonicalName) • \(recentPR.label)",
                                systemImage: "sparkles"
                            )
                        } else {
                            HighlightRow(
                                title: "Recent PR",
                                subtitle: "No PRs yet. Your first logged workout starts the trendline.",
                                systemImage: "sparkles"
                            )
                        }

                        if workspaceStore.analytics.bodyweightTrend.count > 1 {
                            Chart(workspaceStore.analytics.bodyweightTrend) { point in
                                LineMark(
                                    x: .value("Date", point.label),
                                    y: .value("Weight", point.value)
                                )
                                .foregroundStyle(SetraTheme.accentGradient)
                            }
                            .frame(height: 120)
                            .chartYAxis(.hidden)
                            .chartXAxis(.hidden)
                        }
                    }
                }

                GlassCard {
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader("Upcoming", subtitle: "Ordered from your chosen week start")
                        ForEach(upcomingDays) { day in
                            HighlightRow(
                                title: day.weekday.title,
                                subtitle: day.kind == .rest ? day.subtitle : day.title,
                                systemImage: day.kind == .rest ? "moon.zzz.fill" : "dumbbell.fill"
                            )
                        }
                    }
                }
            }
            .padding(20)
            .padding(.bottom, 20)
        }
        .scrollIndicators(.hidden)
        .background(SetraTheme.screenBackground.ignoresSafeArea())
        .navigationTitle("Setra")
        .sheet(item: $activeWorkout) { session in
            WorkoutSessionView(session: session)
        }
    }

    private var todayPlan: ScheduleDayPlan? {
        guard let workspace = workspaceStore.workspace else { return nil }
        return workspace.schedule.day(for: .today)
    }

    private var upcomingDays: [ScheduleDayPlan] {
        guard let workspace = workspaceStore.workspace else { return [] }
        let ordered = workspace.orderedScheduleDays
        guard let currentIndex = ordered.firstIndex(where: { $0.weekday == .today }) else {
            return Array(ordered.prefix(3))
        }
        let rotated = Array(ordered[(currentIndex + 1)...]) + Array(ordered[..<currentIndex])
        return Array(rotated.prefix(3))
    }

    private var adherenceText: String {
        guard let workspace = workspaceStore.workspace else { return "--" }
        let completed = workspace.sessions.filter { Calendar.current.isDate($0.startedAt, equalTo: .now, toGranularity: .weekOfYear) }.count
        let planned = workspace.schedule.days.filter { $0.kind == .workout }.count
        return "\(completed)/\(planned)"
    }

    private var todayGreeting: String {
        if let name = workspaceStore.workspace?.profile.displayName.split(separator: " ").first {
            return "Ready, \(name)"
        }
        return "Ready when you are"
    }
}

private struct DashboardHeroCard: View {
    let day: ScheduleDayPlan
    let previousSummary: ExercisePerformanceSummary?
    let onStart: () -> Void

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(day.weekday.title.uppercased())
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(SetraTheme.accent)
                        Text(day.kind == .rest ? "Recovery Day" : day.title)
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.white)
                        Text(day.subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: day.kind == .rest ? "moon.zzz.fill" : "bolt.heart.fill")
                        .font(.title2)
                        .foregroundStyle(SetraTheme.accent)
                }

                if let previousSummary {
                    Text(previousSummary.lastDescription)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } else if day.kind == .workout {
                    Text("No previous performance yet. Your first session creates the baseline.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Button(day.kind == .rest ? "Mobility Session" : "Start Workout", action: onStart)
                    .buttonStyle(PrimaryActionButtonStyle())
            }
        }
    }
}

private struct HighlightRow: View {
    let title: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(SetraTheme.accent)
                .frame(width: 34, height: 34)
                .background(Circle().fill(SetraTheme.accent.opacity(0.14)))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DashboardView()
        }
        .setraPreviewEnvironment()
    }
}
