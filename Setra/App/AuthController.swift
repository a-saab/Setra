import Foundation
import Observation

@MainActor
@Observable
final class AuthController {
    enum Phase: Equatable {
        case launching
        case signedOut
        case signedIn(AuthUser)
    }

    var phase: Phase = .launching
    var errorMessage: String?

    private let provider: AuthProviding
    private var streamTask: Task<Void, Never>?

    init(provider: AuthProviding) {
        self.provider = provider
    }

    var currentUser: AuthUser? {
        if case let .signedIn(user) = phase {
            return user
        }
        return nil
    }

    var phaseID: String {
        switch phase {
        case .launching:
            "launching"
        case .signedOut:
            "signedOut"
        case .signedIn(let user):
            user.id
        }
    }

    func start() async {
        if streamTask != nil { return }
        streamTask = Task { [weak self] in
            guard let self else { return }
            for await user in provider.authStateChanges() {
                await MainActor.run {
                    self.phase = user.map(Phase.signedIn) ?? .signedOut
                }
            }
        }
        phase = provider.currentUser.map(Phase.signedIn) ?? .signedOut
    }

    func signUp(email: String, password: String, displayName: String) async -> Bool {
        errorMessage = nil
        do {
            let user = try await provider.signUp(email: email, password: password, displayName: displayName)
            phase = .signedIn(user)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func signIn(email: String, password: String) async -> Bool {
        errorMessage = nil
        do {
            let user = try await provider.signIn(email: email, password: password)
            phase = .signedIn(user)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func signInWithGoogle() async -> Bool {
        errorMessage = nil
        do {
            let user = try await provider.signInWithGoogle()
            phase = .signedIn(user)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func sendPasswordReset(email: String) async -> Bool {
        errorMessage = nil
        do {
            try await provider.sendPasswordReset(email: email)
            errorMessage = "Reset link sent to \(email)"
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func signOut() async {
        errorMessage = nil
        do {
            try await provider.signOut()
            phase = .signedOut
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
