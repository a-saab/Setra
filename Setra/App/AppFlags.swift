import Foundation

enum AppFlags {
    static let forceOnboardingForTesting = ProcessInfo.processInfo.environment["SETRA_FORCE_ONBOARDING"] == "1"
        || ProcessInfo.processInfo.arguments.contains("-force-onboarding")
}
