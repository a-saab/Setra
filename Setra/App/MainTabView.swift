import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: AppTab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                DashboardView()
            }
            .tag(AppTab.home)
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }

            NavigationStack {
                WeeklyScheduleView()
            }
            .tag(AppTab.plan)
            .tabItem {
                Label("Plan", systemImage: "calendar")
            }

            NavigationStack {
                HistoryRootView()
            }
            .tag(AppTab.history)
            .tabItem {
                Label("History", systemImage: "chart.line.uptrend.xyaxis")
            }

            NavigationStack {
                ProfileView()
            }
            .tag(AppTab.profile)
            .tabItem {
                Label("Profile", systemImage: "person.crop.circle")
            }
        }
        .tint(SetraTheme.accent)
    }
}

enum AppTab {
    case home
    case plan
    case history
    case profile
}
