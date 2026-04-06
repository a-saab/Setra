import Foundation

actor LocalWorkspaceStore {
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init() {
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }

    func loadWorkspace(for user: AuthUser) throws -> UserWorkspace {
        let url = fileURL(for: user)
        guard FileManager.default.fileExists(atPath: url.path) else {
            return UserWorkspace.seeded(for: user)
        }
        let data = try Data(contentsOf: url)
        return try decoder.decode(UserWorkspace.self, from: data)
    }

    func persist(workspace: UserWorkspace, for user: AuthUser) throws {
        let url = fileURL(for: user)
        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true,
            attributes: nil
        )
        let data = try encoder.encode(workspace)
        try data.write(to: url, options: .atomic)
    }

    private func fileURL(for user: AuthUser) -> URL {
        let root = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        return root
            .appendingPathComponent("Setra", isDirectory: true)
            .appendingPathComponent("workspace-\(user.id).json")
    }
}
