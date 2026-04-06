import Foundation

protocol RemoteWorkspaceSyncing {
    func loadWorkspace(for user: AuthUser) async throws -> UserWorkspace?
    func persist(workspace: UserWorkspace, for user: AuthUser) async throws
}

struct FirebaseWorkspaceSyncClient: RemoteWorkspaceSyncing {
    func loadWorkspace(for user: AuthUser) async throws -> UserWorkspace? {
        try await FirebaseWorkspaceBridge.shared.loadWorkspace(for: user)
    }

    func persist(workspace: UserWorkspace, for user: AuthUser) async throws {
        try await FirebaseWorkspaceBridge.shared.persist(workspace: workspace, for: user)
    }
}

actor FirebaseWorkspaceBridge {
    static let shared = FirebaseWorkspaceBridge()

    func loadWorkspace(for user: AuthUser) async throws -> UserWorkspace? {
        guard user.usesFirebase else { return nil }
        return try await FirebaseRuntime.loadWorkspace(for: user)
    }

    func persist(workspace: UserWorkspace, for user: AuthUser) async throws {
        guard user.usesFirebase else { return }
        try await FirebaseRuntime.persist(workspace: workspace, for: user)
    }
}
