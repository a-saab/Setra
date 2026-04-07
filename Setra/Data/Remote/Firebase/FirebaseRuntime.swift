import Foundation

#if canImport(FirebaseAuth) && canImport(FirebaseCore) && canImport(FirebaseFirestore) && canImport(GoogleSignIn)
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import GoogleSignIn
import UIKit

enum FirebaseRuntime {
    static let authProvider = LiveFirebaseAuthProvider()
    static let workspaceProvider = LiveFirebaseWorkspaceProvider()

    static func loadWorkspace(for user: AuthUser) async throws -> UserWorkspace? {
        try await workspaceProvider.loadWorkspace(for: user)
    }

    static func persist(workspace: UserWorkspace, for user: AuthUser) async throws {
        try await workspaceProvider.persist(workspace: workspace, for: user)
    }
}

extension FirebaseBackedAuthProvider {
    var firebaseProvider: LiveFirebaseAuthProvider? {
        guard FirebaseApp.app() != nil || Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil else {
            if FirebaseApp.app() == nil, Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil {
                FirebaseApp.configure()
            }
            return nil
        }
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        return FirebaseRuntime.authProvider
    }
}

final class LiveFirebaseAuthProvider: AuthProviding {
    var currentUser: AuthUser? {
        Auth.auth().currentUser.map {
            AuthUser(
                id: $0.uid,
                email: $0.email ?? "",
                displayName: $0.displayName ?? "Setra Athlete",
                usesFirebase: true
            )
        }
    }

    func authStateChanges() -> AsyncStream<AuthUser?> {
        AsyncStream { continuation in
            let handle = Auth.auth().addStateDidChangeListener { _, user in
                continuation.yield(
                    user.map {
                        AuthUser(
                            id: $0.uid,
                            email: $0.email ?? "",
                            displayName: $0.displayName ?? "Setra Athlete",
                            usesFirebase: true
                        )
                    }
                )
            }
            continuation.onTermination = { _ in
                Auth.auth().removeStateDidChangeListener(handle)
            }
        }
    }

    func signUp(email: String, password: String, displayName: String) async throws -> AuthUser {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        let request = result.user.createProfileChangeRequest()
        request.displayName = displayName
        try await request.commitChanges()
        return AuthUser(id: result.user.uid, email: email, displayName: displayName, usesFirebase: true)
    }

    func signIn(email: String, password: String) async throws -> AuthUser {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        return AuthUser(
            id: result.user.uid,
            email: result.user.email ?? email,
            displayName: result.user.displayName ?? "Setra Athlete",
            usesFirebase: true
        )
    }

    func signInWithGoogle() async throws -> AuthUser {
        guard
            let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let root = scene.windows.first?.rootViewController,
            let clientID = FirebaseApp.app()?.options.clientID
        else {
            throw AuthProviderError.providerUnavailable
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: root)
        guard let idToken = result.user.idToken?.tokenString else {
            throw AuthProviderError.providerUnavailable
        }
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: result.user.accessToken.tokenString)
        let authResult = try await Auth.auth().signIn(with: credential)
        return AuthUser(
            id: authResult.user.uid,
            email: authResult.user.email ?? "",
            displayName: authResult.user.displayName ?? "Setra Athlete",
            usesFirebase: true
        )
    }

    func sendPasswordReset(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }

    func signOut() async throws {
        try Auth.auth().signOut()
    }
}

struct LiveFirebaseWorkspaceProvider {
    private let db = Firestore.firestore()

    func loadWorkspace(for user: AuthUser) async throws -> UserWorkspace? {
        let userRef = db.collection("users").document(user.id)

        async let profileDoc = userRef.getDocument()
        async let settingsDoc = userRef.collection("settings").document("app").getDocument()
        async let scheduleDoc = userRef.collection("weeklySchedules").document("current").getDocument()
        async let templateDocs = userRef.collection("workoutTemplates").getDocuments()
        async let customExerciseDocs = userRef.collection("customExercises").getDocuments()
        async let sessionDocs = userRef.collection("workoutSessions").getDocuments()
        async let bodyweightDocs = userRef.collection("bodyweightLogs").getDocuments()
        async let prDocs = userRef.collection("personalRecords").getDocuments()
        async let favoritesDoc = userRef.collection("meta").document("favorites").getDocument()
        async let recentDoc = userRef.collection("meta").document("recentExercises").getDocument()

        let profileSnapshot = try await profileDoc
        guard let profileData = profileSnapshot.data() else {
            return nil
        }

        let settingsSnapshot = try await settingsDoc
        let scheduleSnapshot = try await scheduleDoc
        let templateSnapshot = try await templateDocs
        let customExerciseSnapshot = try await customExerciseDocs
        let sessionSnapshot = try await sessionDocs
        let bodyweightSnapshot = try await bodyweightDocs
        let prSnapshot = try await prDocs
        let favoritesSnapshot = try await favoritesDoc
        let recentSnapshot = try await recentDoc

        let profile = try decode(UserProfile.self, from: profileData)
        let settings = try settingsSnapshot.data().map { try decode(AppSettings.self, from: $0) } ?? .default
        let schedule = try scheduleSnapshot.data().map { try decode(WeeklySchedule.self, from: $0) } ?? WeeklySchedule.empty(startingAt: settings.firstWeekday)
        let templates = try templateSnapshot.documents.map { try decode(WorkoutTemplate.self, from: $0.data()) }
        let customExercises = try customExerciseSnapshot.documents.map { try decode(Exercise.self, from: $0.data()) }
        let sessions = try sessionSnapshot.documents.map { try decode(WorkoutSession.self, from: $0.data()) }
        let bodyweightLogs = try bodyweightSnapshot.documents.map { try decode(BodyweightLog.self, from: $0.data()) }
        let personalRecords = try prSnapshot.documents.map { try decode(PersonalRecord.self, from: $0.data()) }
        let favorites = Set((favoritesSnapshot.data()?["ids"] as? [String]) ?? [])
        let recents = (recentSnapshot.data()?["ids"] as? [String]) ?? []

        return UserWorkspace(
            profile: profile,
            settings: settings,
            schedule: schedule,
            templates: templates.sorted(by: { $0.updatedAt > $1.updatedAt }),
            customExercises: customExercises.sorted(by: { $0.canonicalName < $1.canonicalName }),
            sessions: sessions.sorted(by: { $0.startedAt > $1.startedAt }),
            bodyweightLogs: bodyweightLogs.sorted(by: { $0.date > $1.date }),
            favoriteExerciseIDs: favorites,
            recentExerciseIDs: recents,
            personalRecords: personalRecords.sorted(by: { $0.date > $1.date }),
            updatedAt: profile.updatedAt
        )
    }

    func persist(workspace: UserWorkspace, for user: AuthUser) async throws {
        let userRef = db.collection("users").document(user.id)
        let batch = db.batch()

        batch.setData(
            try encode(workspace.profile.mergingOwner(userID: user.id)),
            forDocument: userRef,
            merge: true
        )
        batch.setData(
            try encode(workspace.settings),
            forDocument: userRef.collection("settings").document("app")
        )
        batch.setData(
            try encode(workspace.schedule),
            forDocument: userRef.collection("weeklySchedules").document("current")
        )
        batch.setData(
            ["ids": Array(workspace.favoriteExerciseIDs)],
            forDocument: userRef.collection("meta").document("favorites")
        )
        batch.setData(
            ["ids": workspace.recentExerciseIDs],
            forDocument: userRef.collection("meta").document("recentExercises")
        )

        try await syncCollection(
            named: "workoutTemplates",
            under: userRef,
            items: workspace.templates,
            batch: batch,
            id: \.id
        )
        try await syncCollection(
            named: "customExercises",
            under: userRef,
            items: workspace.customExercises,
            batch: batch,
            id: \.id
        )
        try await syncCollection(
            named: "workoutSessions",
            under: userRef,
            items: workspace.sessions,
            batch: batch,
            id: \.id
        )
        try await syncCollection(
            named: "bodyweightLogs",
            under: userRef,
            items: workspace.bodyweightLogs,
            batch: batch,
            id: \.id
        )
        try await syncCollection(
            named: "personalRecords",
            under: userRef,
            items: workspace.personalRecords,
            batch: batch,
            id: \.id
        )

        try await batch.commit()
    }

    private func syncCollection<Model: Encodable>(
        named collectionName: String,
        under userRef: DocumentReference,
        items: [Model],
        batch: WriteBatch,
        id: KeyPath<Model, String>
    ) async throws {
        let collection = userRef.collection(collectionName)
        let existingSnapshot = try await collection.getDocuments()
        let existing = existingSnapshot.documents.map(\.documentID)
        let incoming = Set(items.map { $0[keyPath: id] })

        for item in items {
            let ref = collection.document(item[keyPath: id])
            batch.setData(try encode(item), forDocument: ref)
        }

        for documentID in existing where !incoming.contains(documentID) {
            batch.deleteDocument(collection.document(documentID))
        }
    }

    private func encode<T: Encodable>(_ value: T) throws -> [String: Any] {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(value)
        let object = try JSONSerialization.jsonObject(with: data)
        return object as? [String: Any] ?? [:]
    }

    private func decode<T: Decodable>(_ type: T.Type, from data: [String: Any]) throws -> T {
        let raw = try JSONSerialization.data(withJSONObject: data)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(T.self, from: raw)
    }
}

private extension UserProfile {
    func mergingOwner(userID: String) -> [String: AnyEncodable] {
        [
            "ownerId": AnyEncodable(userID),
            "displayName": AnyEncodable(displayName),
            "email": AnyEncodable(email),
            "hasCompletedOnboarding": AnyEncodable(hasCompletedOnboarding),
            "createdAt": AnyEncodable(createdAt),
            "updatedAt": AnyEncodable(updatedAt),
        ]
    }
}

private struct AnyEncodable: Encodable {
    private let encodeBlock: (Encoder) throws -> Void

    init<T: Encodable>(_ value: T) {
        encodeBlock = value.encode(to:)
    }

    func encode(to encoder: Encoder) throws {
        try encodeBlock(encoder)
    }
}
#else
enum FirebaseRuntime {
    static func loadWorkspace(for user: AuthUser) async throws -> UserWorkspace? { nil }
    static func persist(workspace: UserWorkspace, for user: AuthUser) async throws {}
}

extension FirebaseBackedAuthProvider {
    var firebaseProvider: (any AuthProviding)? { nil }
}
#endif
