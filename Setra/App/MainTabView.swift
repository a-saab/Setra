import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: AppTab = .today

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Today", systemImage: "sun.max.fill", value: .today) {
                NavigationStack {
                    DashboardView()
                }
            }

            Tab("Plan", systemImage: "calendar", value: .plan) {
                NavigationStack {
                    WeeklyScheduleView()
                }
            }

            Tab("Progress", systemImage: "chart.line.uptrend.xyaxis", value: .progress) {
                NavigationStack {
                    HistoryRootView()
                }
            }

            Tab("You", systemImage: "person.crop.circle", value: .profile) {
                NavigationStack {
                    ProfileView()
                }
            }
        }
        .tint(SetraTheme.accent)
        .toolbarBackground(SetraTheme.surface, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
    }
}

enum AppTab: Hashable {
    case today
    case plan
    case progress
    case profile
}
