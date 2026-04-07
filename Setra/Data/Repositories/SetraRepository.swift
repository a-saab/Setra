import Foundation

protocol WorkspaceRepository {
    func loadWorkspace(for user: AuthUser) async throws -> UserWorkspace
    func persist(workspace: UserWorkspace, for user: AuthUser) async throws
}

struct CompositeWorkspaceRepository: WorkspaceRepository {
    let localStore: LocalWorkspaceStore
    let remoteSync: RemoteWorkspaceSyncing

    func loadWorkspace(for user: AuthUser) async throws -> UserWorkspace {
        async let local = localStore.loadWorkspace(for: user)
        async let remote = remoteSync.loadWorkspace(for: user)

        let localValue = (try? await local) ?? UserWorkspace.empty(for: user)
        let remoteValue = try? await remote

        guard let remoteValue else {
            return localValue
        }

        let chosen = remoteValue.updatedAt >= localValue.updatedAt ? remoteValue : localValue
        try? await localStore.persist(workspace: chosen, for: user)
        return chosen
    }

    func persist(workspace: UserWorkspace, for user: AuthUser) async throws {
        try await localStore.persist(workspace: workspace, for: user)
        try? await remoteSync.persist(workspace: workspace, for: user)
    }
}
