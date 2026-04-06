import SwiftUI

struct AppRootView: View {
    @EnvironmentObject private var authController: AuthController
    @EnvironmentObject private var workspaceStore: WorkspaceStore

    var body: some View {
        ZStack {
            SetraTheme.screenBackground
                .ignoresSafeArea()

            switch authController.phase {
            case .launching:
                SplashView()
            case .signedOut:
                AuthenticationFlowView()
            case .signedIn(let user):
                if workspaceStore.isBootstrapping {
                    SplashView(subtitle: "Loading your training system")
                } else if !(workspaceStore.workspace?.profile.hasCompletedOnboarding ?? false) {
                    OnboardingFlowView(user: user)
                } else {
                    MainTabView()
                        .transition(.opacity.combined(with: .scale(scale: 0.98)))
                }
            }
        }
        .animation(.smooth(duration: 0.32), value: authController.phaseID)
        .task {
            await authController.start()
        }
        .overlay(alignment: .top) {
            if let message = workspaceStore.bannerMessage {
                BannerView(message: message)
                    .padding(.top, 12)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }
}

private struct BannerView: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.callout.weight(.semibold))
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .foregroundStyle(.white)
            .background(
                Capsule()
                    .fill(SetraTheme.accentGradient)
            )
            .shadow(color: SetraTheme.accent.opacity(0.28), radius: 20, y: 10)
    }
}
