import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: AppTab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Home", systemImage: "house.fill", value: .home) {
                NavigationStack {
                    DashboardView()
                }
            }

            Tab("Plan", systemImage: "calendar", value: .plan) {
                NavigationStack {
                    WeeklyScheduleView()
                }
            }

            Tab("History", systemImage: "chart.line.uptrend.xyaxis", value: .history) {
                NavigationStack {
                    HistoryRootView()
                }
            }

            Tab("Profile", systemImage: "person.crop.circle", value: .profile) {
                NavigationStack {
                    ProfileView()
                }
            }
        }
        .tint(SetraTheme.accent)
    }
}

enum AppTab: Hashable {
    case home
    case plan
    case history
    case profile
}
