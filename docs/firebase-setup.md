# Firebase Setup Guide

Setra already contains the Firebase-ready auth and Firestore integration layer. These steps activate it.

## 1. Create the Firebase app

In Firebase Console:

1. Create a project.
2. Add an iOS app with bundle identifier `Saab-Studios.Setra` or update the Xcode bundle ID to match your Firebase app.
3. Download `GoogleService-Info.plist`.

## 2. Add the Firebase packages in Xcode

In Xcode:

1. Open `Setra.xcodeproj`.
2. Go to `Package Dependencies`.
3. Add `https://github.com/firebase/firebase-ios-sdk`.
4. Add these products to the `Setra` target:
   - `FirebaseCore`
   - `FirebaseAuth`
   - `FirebaseFirestore`
   - `FirebaseStorage` only if you decide to move custom exercise images to cloud storage later
5. Add `https://github.com/google/GoogleSignIn-iOS`.
6. Add the `GoogleSignIn` product to the `Setra` target.

## 3. Add the Firebase config file

1. Drag `GoogleService-Info.plist` into the `Setra/` group in Xcode.
2. Ensure it is added to the `Setra` target.

The app will automatically switch from local fallback mode to Firebase mode when the Firebase packages are available and the plist exists.

## 4. Enable auth providers

In Firebase Console:

1. Go to `Authentication`.
2. Enable `Email/Password`.
3. Enable `Google`.

## 5. Add the Google URL scheme

Google Sign In requires the reversed client ID from `GoogleService-Info.plist`.

1. Open the plist.
2. Copy `REVERSED_CLIENT_ID`.
3. In Xcode target settings, add a `URL Type` using that value as the URL scheme.

## 6. Create Firestore

1. Enable Cloud Firestore in production mode.
2. Review `docs/firestore-schema.md`.
3. Deploy `firebase/firestore.rules`.
4. Deploy `firebase/firestore.indexes.json`.

## 7. Deploy rules and indexes

With Firebase CLI installed:

```bash
firebase deploy --only firestore:rules,firestore:indexes
```

## 8. Verify activation

Expected runtime behavior:

- `Email + password` uses Firebase Auth
- `Continue with Google` uses Google Sign In + Firebase credential exchange
- Workspace data persists to `users/{uid}` and its subcollections

## Development fallback

If Firebase is not configured yet:

- the app still builds and runs
- auth uses a local development fallback
- workout data persists locally

That makes UI development and seed-data iteration much faster.

