import Charts
import SwiftUI

struct DashboardView: View {
    @Environment(WorkspaceStore.self) private var workspaceStore

    @State private var activeWorkout: WorkoutSession?

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 18) {
                header

                if let plan = todayPlan {
                    TodayFocusCard(
                        day: plan,
                        summary: workoutSummary(for: plan),
                        previousSummary: primaryExercisePerformance(for: plan),
                        onStart: {
                            activeWorkout = workspaceStore.startWorkout(from: plan)
                        }
                    )
                } else {
                    emptyTodayCard
                }

                metricsCard
                momentumCard
                upcomingCard
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
        .navigationTitle("Today")
        .sheet(item: $activeWorkout) { session in
            WorkoutSessionView(session: session)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(greetingLine)
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(SetraTheme.primaryText)
            Text(statusLine)
                .font(.subheadline)
                .foregroundStyle(SetraTheme.secondaryText)
        }
    }

    private var metricsCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader("This Week", subtitle: "The signals that should matter most at a glance")

                HStack(spacing: 12) {
                    StatChip(label: "Planned", value: "\(plannedSessionsThisWeek)")
                    StatChip(label: "Done", value: "\(completedSessionsThisWeek)", accent: SetraTheme.success)
                    StatChip(label: "Streak", value: "\(workspaceStore.analytics.streakCount)d", accent: SetraTheme.accentSecondary)
                }

                if let latestSession = workspaceStore.historySessions.first {
                    dashboardCallout(
                        title: "Last session",
                        subtitle: "\(latestSession.title) • \(latestSession.totalVolume.clean) total volume"
                    )
                } else {
                    dashboardCallout(
                        title: "First workout pending",
                        subtitle: "Log one complete session and Setra will start surfacing your real momentum."
                    )
                }
            }
        }
    }

    private var momentumCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader("Momentum", subtitle: "Progress should feel visible, not buried")

                if let recentPR = workspaceStore.analytics.recentPRs.first,
                   let exercise = workspaceStore.exercise(by: recentPR.exerciseID) {
                    dashboardCallout(
                        title: "Recent best",
                        subtitle: "\(exercise.canonicalName) • \(recentPR.label)"
                    )
                } else {
                    dashboardCallout(
                        title: "No records yet",
                        subtitle: "Your first few workouts will establish the baseline for records and trend signals."
                    )
                }

                if workspaceStore.analytics.bodyweightTrend.count > 1 {
                    Chart(workspaceStore.analytics.bodyweightTrend) { point in
                        LineMark(
                            x: .value("Date", point.label),
                            y: .value("Weight", point.value)
                        )
                        .foregroundStyle(SetraTheme.accentGradient)
                        .lineStyle(.init(lineWidth: 3, lineCap: .round, lineJoin: .round))

                        AreaMark(
                            x: .value("Date", point.label),
                            y: .value("Weight", point.value)
                        )
                        .foregroundStyle(SetraTheme.accent.opacity(0.08))
                    }
                    .frame(height: 150)
                    .chartXAxis(.hidden)
                    .chartYAxis(.hidden)
                } else {
                    Text("Bodyweight trendlines appear once you have a couple of entries. Until then, the important thing is building the rhythm.")
                        .font(.footnote)
                        .foregroundStyle(SetraTheme.secondaryText)
                }
            }
        }
    }

    private var upcomingCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader("Upcoming", subtitle: "What the next few days of training look like")

                if upcomingDays.isEmpty {
                    Text("No upcoming days yet. Build your weekly split in Plan and Setra will keep this view anchored to your schedule.")
                        .font(.footnote)
                        .foregroundStyle(SetraTheme.secondaryText)
                } else {
                    ForEach(upcomingDays) { day in
                        HStack(alignment: .top, spacing: 14) {
                            VStack(spacing: 6) {
                                Circle()
                                    .fill(day.kind == .workout ? SetraTheme.accent : SetraTheme.surfaceTertiary)
                                    .frame(width: 10, height: 10)
                                Rectangle()
                                    .fill(SetraTheme.divider)
                                    .frame(width: 1)
                            }
                            .padding(.top, 8)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(day.weekday.title)
                                    .font(.headline.weight(.semibold))
                                    .foregroundStyle(SetraTheme.primaryText)
                                Text(day.kind == .rest ? "Recovery Day" : day.title)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(SetraTheme.primaryText)
                                Text(day.kind == .rest ? "Space to recover, walk, and reset." : day.subtitle)
                                    .font(.subheadline)
                                    .foregroundStyle(SetraTheme.secondaryText)
                            }

                            Spacer()

                            Text(day.kind == .rest ? "Rest" : "\(day.exercises.count)")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(day.kind == .rest ? SetraTheme.secondaryText : SetraTheme.accent)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(SetraTheme.mutedFill)
                                )
                        }
                    }
                }
            }
        }
    }

    private var emptyTodayCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionHeader("Today", subtitle: "There is no plan for today yet")
                Text("The product should never make a blank day feel dead. The next rewrite will support faster plan creation, templates, and recovery guidance right from this screen.")
                    .font(.subheadline)
                    .foregroundStyle(SetraTheme.secondaryText)
            }
        }
    }

    private func dashboardCallout(title: String, subtitle: String) -> some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(SetraTheme.mutedFill)
                .frame(width: 46, height: 46)
                .overlay(
                    Image(systemName: "sparkles")
                        .font(.headline)
                        .foregroundStyle(SetraTheme.accent)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(SetraTheme.primaryText)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(SetraTheme.secondaryText)
            }

            Spacer()
        }
    }

    private var todayPlan: ScheduleDayPlan? {
        workspaceStore.workspace?.schedule.day(for: .today)
    }

    private var plannedSessionsThisWeek: Int {
        workspaceStore.workspace?.schedule.days.filter { $0.kind == .workout }.count ?? 0
    }

    private var completedSessionsThisWeek: Int {
        workspaceStore.historySessions.filter {
            Calendar.current.isDate($0.startedAt, equalTo: .now, toGranularity: .weekOfYear)
        }.count
    }

    private var upcomingDays: [ScheduleDayPlan] {
        guard let workspace = workspaceStore.workspace else { return [] }
        let ordered = workspace.orderedScheduleDays
        guard let currentIndex = ordered.firstIndex(where: { $0.weekday == .today }) else {
            return Array(ordered.prefix(4))
        }
        let rotated = Array(ordered.dropFirst(currentIndex + 1)) + Array(ordered.prefix(currentIndex))
        return Array(rotated.prefix(4))
    }

    private var greetingLine: String {
        if let name = workspaceStore.workspace?.profile.displayName.split(separator: " ").first {
            return "Ready, \(name)"
        }
        return "Ready when you are"
    }

    private var statusLine: String {
        if let todayPlan {
            if todayPlan.kind == .rest {
                return "Today is for recovery. Keep the rhythm without forcing work."
            }
            return "\(todayPlan.exercises.count) exercises lined up. The right next step is obvious."
        }
        return "Setra should always answer what happens next."
    }

    private func workoutSummary(for day: ScheduleDayPlan) -> String {
        guard day.kind == .workout else {
            return "Recovery, mobility, and staying fresh for the next hard session."
        }
        return "\(day.exercises.count) exercises • \(day.subtitle)"
    }

    private func primaryExercisePerformance(for day: ScheduleDayPlan) -> ExercisePerformanceSummary? {
        guard let firstExerciseID = day.exercises.first?.exerciseID else { return nil }
        return workspaceStore.performanceSummary(for: firstExerciseID)
    }
}

private struct TodayFocusCard: View {
    let day: ScheduleDayPlan
    let summary: String
    let previousSummary: ExercisePerformanceSummary?
    let onStart: () -> Void

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(day.weekday.title.uppercased())
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(SetraTheme.accent)
                        Text(day.kind == .rest ? "Recovery Day" : day.title)
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundStyle(SetraTheme.primaryText)
                        Text(summary)
                            .font(.subheadline)
                            .foregroundStyle(SetraTheme.secondaryText)
                    }

                    Spacer()

                    Image(systemName: day.kind == .rest ? "figure.cooldown" : "figure.strengthtraining.traditional")
                        .font(.title2)
                        .foregroundStyle(SetraTheme.accent)
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(SetraTheme.mutedFill)
                        )
                }

                if let previousSummary {
                    Text(previousSummary.lastDescription)
                        .font(.footnote)
                        .foregroundStyle(SetraTheme.secondaryText)
                } else {
                    Text(day.kind == .rest ? "A calmer day is still part of the plan." : "This session has room to become your baseline. Start clean and let the product learn from it.")
                        .font(.footnote)
                        .foregroundStyle(SetraTheme.secondaryText)
                }

                Button(day.kind == .rest ? "Open Recovery Session" : "Start Workout", action: onStart)
                    .buttonStyle(PrimaryActionButtonStyle())
            }
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
