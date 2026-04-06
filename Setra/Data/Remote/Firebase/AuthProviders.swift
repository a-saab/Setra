import Foundation

protocol AuthProviding {
    var currentUser: AuthUser? { get }
    func authStateChanges() -> AsyncStream<AuthUser?>
    func signUp(email: String, password: String, displayName: String) async throws -> AuthUser
    func signIn(email: String, password: String) async throws -> AuthUser
    func signInWithGoogle() async throws -> AuthUser
    func sendPasswordReset(email: String) async throws
    func signOut() async throws
}

enum AuthProviderError: LocalizedError {
    case invalidCredentials
    case providerUnavailable

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            "Check your credentials and try again."
        case .providerUnavailable:
            "Firebase is not configured yet. Use the local development mode until setup is complete."
        }
    }
}

final class LocalAuthProvider: AuthProviding {
    private struct PersistedAuthUser: Codable {
        var email: String
        var password: String
        var displayName: String
    }

    private let defaultsKey = "setra.local.auth.users"
    private let currentUserKey = "setra.local.auth.current-user"

    var currentUser: AuthUser? {
        guard
            let currentID = UserDefaults.standard.string(forKey: currentUserKey),
            let data = UserDefaults.standard.data(forKey: defaultsKey),
            let users = try? JSONDecoder().decode([String: PersistedAuthUser].self, from: data),
            let record = users[currentID]
        else {
            return nil
        }
        return AuthUser(id: currentID, email: record.email, displayName: record.displayName, usesFirebase: false)
    }

    func authStateChanges() -> AsyncStream<AuthUser?> {
        AsyncStream { continuation in
            continuation.yield(currentUser)
            continuation.onTermination = { _ in }
        }
    }

    func signUp(email: String, password: String, displayName: String) async throws -> AuthUser {
        var users = loadUsers()
        let id = email.lowercased()
        users[id] = PersistedAuthUser(email: email, password: password, displayName: displayName)
        saveUsers(users)
        UserDefaults.standard.set(id, forKey: currentUserKey)
        return AuthUser(id: id, email: email, displayName: displayName, usesFirebase: false)
    }

    func signIn(email: String, password: String) async throws -> AuthUser {
        let users = loadUsers()
        let id = email.lowercased()
        guard let user = users[id], user.password == password else {
            throw AuthProviderError.invalidCredentials
        }
        UserDefaults.standard.set(id, forKey: currentUserKey)
        return AuthUser(id: id, email: user.email, displayName: user.displayName, usesFirebase: false)
    }

    func signInWithGoogle() async throws -> AuthUser {
        let email = "setra.demo@example.com"
        return try await signUp(email: email, password: UUID().uuidString, displayName: "Setra Demo")
    }

    func sendPasswordReset(email: String) async throws {
        guard loadUsers()[email.lowercased()] != nil else {
            throw AuthProviderError.invalidCredentials
        }
    }

    func signOut() async throws {
        UserDefaults.standard.removeObject(forKey: currentUserKey)
    }

    private func loadUsers() -> [String: PersistedAuthUser] {
        guard
            let data = UserDefaults.standard.data(forKey: defaultsKey),
            let users = try? JSONDecoder().decode([String: PersistedAuthUser].self, from: data)
        else {
            return [:]
        }
        return users
    }

    private func saveUsers(_ users: [String: PersistedAuthUser]) {
        if let data = try? JSONEncoder().encode(users) {
            UserDefaults.standard.set(data, forKey: defaultsKey)
        }
    }
}

enum FirebaseAuthProvider {
    static func makeDefault() -> any AuthProviding {
        FirebaseBackedAuthProvider()
    }
}

struct FirebaseBackedAuthProvider: AuthProviding {
    private let fallback = LocalAuthProvider()

    var currentUser: AuthUser? {
        firebaseProvider?.currentUser ?? fallback.currentUser
    }

    func authStateChanges() -> AsyncStream<AuthUser?> {
        firebaseProvider?.authStateChanges() ?? fallback.authStateChanges()
    }

    func signUp(email: String, password: String, displayName: String) async throws -> AuthUser {
        if let firebaseProvider {
            return try await firebaseProvider.signUp(email: email, password: password, displayName: displayName)
        }
        return try await fallback.signUp(email: email, password: password, displayName: displayName)
    }

    func signIn(email: String, password: String) async throws -> AuthUser {
        if let firebaseProvider {
            return try await firebaseProvider.signIn(email: email, password: password)
        }
        return try await fallback.signIn(email: email, password: password)
    }

    func signInWithGoogle() async throws -> AuthUser {
        if let firebaseProvider {
            return try await firebaseProvider.signInWithGoogle()
        }
        return try await fallback.signInWithGoogle()
    }

    func sendPasswordReset(email: String) async throws {
        if let firebaseProvider {
            try await firebaseProvider.sendPasswordReset(email: email)
        } else {
            try await fallback.sendPasswordReset(email: email)
        }
    }

    func signOut() async throws {
        if let firebaseProvider {
            try await firebaseProvider.signOut()
        } else {
            try await fallback.signOut()
        }
    }
}
