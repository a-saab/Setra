import SwiftUI

struct WeeklyScheduleView: View {
    @Environment(WorkspaceStore.self) private var workspaceStore

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 18) {
                overviewCard

                ForEach(workspaceStore.workspace?.orderedScheduleDays ?? []) { day in
                    NavigationLink {
                        DayDetailView(day: day)
                    } label: {
                        WeeklyDayCard(day: day, summary: daySummary(for: day))
                    }
                    .buttonStyle(.plain)
                }

                if let templates = workspaceStore.workspace?.templates, !templates.isEmpty {
                    templatesCard(templates)
                }
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
        .navigationTitle("Plan")
    }

    private var overviewCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader("Weekly Structure", subtitle: "A premium training app should make the week feel legible in one glance")

                HStack(spacing: 12) {
                    StatChip(label: "Training Days", value: "\(trainingDayCount)")
                    StatChip(label: "Rest Days", value: "\(restDayCount)", accent: SetraTheme.accentSecondary)
                    StatChip(label: "Templates", value: "\(templateCount)", accent: SetraTheme.success)
                }

                Text("The next rewrite will tighten day editing, templates, and copy flows so planning feels deliberate instead of form-heavy.")
                    .font(.footnote)
                    .foregroundStyle(SetraTheme.secondaryText)
            }
        }
    }

    private func templatesCard(_ templates: [WorkoutTemplate]) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionHeader("Templates", subtitle: "Reusable structures that should eventually become first-class")

                ForEach(templates) { template in
                    HStack(spacing: 14) {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(SetraTheme.mutedFill)
                            .frame(width: 44, height: 44)
                            .overlay(
                                Image(systemName: "square.stack.3d.down.forward.fill")
                                    .foregroundStyle(SetraTheme.accent)
                            )

                        VStack(alignment: .leading, spacing: 4) {
                            Text(template.name)
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(SetraTheme.primaryText)
                            Text("\(template.exercises.count) exercises")
                                .font(.subheadline)
                                .foregroundStyle(SetraTheme.secondaryText)
                        }

                        Spacer()
                    }
                }
            }
        }
    }

    private var trainingDayCount: Int {
        workspaceStore.workspace?.schedule.days.filter { $0.kind == .workout }.count ?? 0
    }

    private var restDayCount: Int {
        workspaceStore.workspace?.schedule.days.filter { $0.kind == .rest }.count ?? 0
    }

    private var templateCount: Int {
        workspaceStore.workspace?.templates.count ?? 0
    }

    private func daySummary(for day: ScheduleDayPlan) -> String {
        if day.kind == .rest {
            return day.subtitle
        }
        return "\(day.exercises.count) exercises • \(day.subtitle)"
    }
}

private struct WeeklyDayCard: View {
    let day: ScheduleDayPlan
    let summary: String

    var body: some View {
        GlassCard {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(day.weekday.title.uppercased())
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(SetraTheme.accent)
                    Text(day.kind == .rest ? "Recovery Day" : day.title)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(SetraTheme.primaryText)
                    Text(summary)
                        .font(.subheadline)
                        .foregroundStyle(SetraTheme.secondaryText)
                }

                Spacer()

                VStack(spacing: 10) {
                    Image(systemName: day.kind == .rest ? "moon.zzz.fill" : "chevron.right")
                        .foregroundStyle(day.kind == .rest ? SetraTheme.secondaryText : SetraTheme.accent)
                        .font(.headline)
                    Text(day.kind == .rest ? "Rest" : "\(day.exercises.count)")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(SetraTheme.secondaryText)
                }
            }
        }
    }
}

struct WeeklyScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            WeeklyScheduleView()
        }
        .setraPreviewEnvironment()
    }
}
