import SwiftUI

private struct PreviewAuthProvider: AuthProviding {
    var user: AuthUser?

    var currentUser: AuthUser? { user }

    func authStateChanges() -> AsyncStream<AuthUser?> {
        AsyncStream { continuation in
            continuation.yield(user)
            continuation.finish()
        }
    }

    func signUp(email: String, password: String, displayName: String) async throws -> AuthUser {
        AuthUser(id: "preview-user", email: email, displayName: displayName, usesFirebase: false)
    }

    func signIn(email: String, password: String) async throws -> AuthUser {
        AuthUser(id: "preview-user", email: email, displayName: "Preview Athlete", usesFirebase: false)
    }

    func signInWithGoogle() async throws -> AuthUser {
        AuthUser(id: "preview-user", email: "preview@example.com", displayName: "Preview Athlete", usesFirebase: false)
    }

    func sendPasswordReset(email: String) async throws {}
    func signOut() async throws {}
}

private struct PreviewWorkspaceRepository: WorkspaceRepository {
    let workspace: UserWorkspace

    func loadWorkspace(for user: AuthUser) async throws -> UserWorkspace {
        workspace
    }

    func persist(workspace: UserWorkspace, for user: AuthUser) async throws {}
}

enum PreviewEnvironment {
    static let user = AuthUser(
        id: "preview-user",
        email: "preview@example.com",
        displayName: "Preview Athlete",
        usesFirebase: false
    )

    static func workspace(onboarded: Bool = true) -> UserWorkspace {
        var workspace = UserWorkspace.seeded(for: user)
        workspace.profile.hasCompletedOnboarding = onboarded
        workspace.profile.displayName = user.displayName
        workspace.personalRecords = AnalyticsEngine().personalRecords(
            from: workspace.sessions,
            exerciseLibrary: SeedData.exerciseLibrary
        )
        return workspace
    }

    static func authController(signedIn: Bool = true) -> AuthController {
        let controller = AuthController(provider: PreviewAuthProvider(user: signedIn ? user : nil))
        controller.phase = signedIn ? .signedIn(user) : .signedOut
        return controller
    }

    static func workspaceStore(onboarded: Bool = true) -> WorkspaceStore {
        let store = WorkspaceStore(
            repository: PreviewWorkspaceRepository(workspace: workspace(onboarded: onboarded)),
            progressionEngine: ProgressionEngine(),
            analyticsEngine: AnalyticsEngine(),
            searchEngine: ExerciseSearchEngine()
        )
        store.workspace = workspace(onboarded: onboarded)
        return store
    }
}

extension View {
    func setraPreviewEnvironment(
        signedIn: Bool = true,
        onboarded: Bool = true
    ) -> some View {
        let auth = PreviewEnvironment.authController(signedIn: signedIn)
        let workspace = PreviewEnvironment.workspaceStore(onboarded: onboarded)

        return self
            .environment(auth)
            .environment(workspace)
    }
}
