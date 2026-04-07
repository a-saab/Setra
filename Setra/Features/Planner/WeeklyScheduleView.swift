import SwiftUI

struct WeeklyScheduleView: View {
    @EnvironmentObject private var workspaceStore: WorkspaceStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                SectionHeader("Weekly Split", subtitle: "Ordered from your chosen week start")

                ForEach(workspaceStore.workspace?.orderedScheduleDays ?? []) { day in
                    NavigationLink {
                        DayDetailView(day: day)
                    } label: {
                        WeeklyDayCard(day: day, summary: daySummary(for: day))
                    }
                    .buttonStyle(.plain)
                }

                if let templates = workspaceStore.workspace?.templates, !templates.isEmpty {
                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader("Templates", subtitle: "Reusable day presets")
                            ForEach(templates) { template in
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(template.name)
                                        .font(.headline)
                                        .foregroundStyle(.white)
                                    Text("\(template.exercises.count) exercises")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
            }
            .padding(20)
            .padding(.bottom, 20)
        }
        .background(SetraTheme.screenBackground.ignoresSafeArea())
        .navigationTitle("Plan")
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
                VStack(alignment: .leading, spacing: 6) {
                    Text(day.weekday.title)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.white)
                    Text(day.kind == .rest ? "Rest Day" : day.title)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.white)
                    Text(summary)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: day.kind == .rest ? "moon.zzz" : "chevron.right")
                    .foregroundStyle(day.kind == .rest ? .secondary : SetraTheme.accent)
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
