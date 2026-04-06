# Setra

Setra is a premium SwiftUI workout planning and logging app for strength training. It is designed to feel fast, clean, and practical during real gym sessions, with built-in progression logic, a reusable weekly split builder, clean history, and an activation path for Firebase Auth + Firestore.

## What is implemented

- Premium SwiftUI iPhone app shell with dark-first visual design
- Welcome, sign up, log in, forgot password, onboarding, profile, and settings flows
- Local development auth fallback so the app runs immediately
- Firebase-ready auth abstraction for email/password and Google Sign In
- Weekly schedule builder with editable day plans, exercise ordering, copy day, clear day, and template saving
- Built-in starter exercise library with aliases, filtering, favorites, recents, and fuzzy search
- Custom exercise creation with optional local image selection
- Live workout logging with set-by-set reps/load entry, inline previous performance, progression hints, and a rest timer
- Plate calculator / plate picker sheet for barbell lifts
- Workout history, simple analytics, bodyweight logging, and recent PR surfacing
- Local-first persistence for offline-friendly usage
- Firestore schema docs, security rules, indexes, branding guidance, and roadmap docs

## Project structure

```text
Setra/
  App/
  Data/
    Local/
    Remote/Firebase/
    Repositories/
  DesignSystem/
  Domain/
    Models/
    Services/
  Features/
    Auth/
    Dashboard/
    Exercises/
    History/
    Onboarding/
    Planner/
    Profile/
    Workout/
  PreviewSupport/
docs/
firebase/
scripts/
```

## Key files

- `Setra/App/SetraApp.swift`: app bootstrap and root wiring
- `Setra/App/AuthController.swift`: auth state and sign-in flow coordination
- `Setra/App/WorkspaceStore.swift`: local-first app state and feature mutations
- `Setra/PreviewSupport/SeedData.swift`: built-in starter exercise library, sample schedule, and preview history
- `Setra/Data/Remote/Firebase/FirebaseRuntime.swift`: Firebase Auth / Firestore integration layer
- `docs/firestore-schema.md`: explicit Firestore shape and document ownership
- `firebase/firestore.rules`: user-scoped Firestore rules

## Local run

1. Open `Setra.xcodeproj` in Xcode 26.4 or newer.
2. Select the `Setra` scheme.
3. Build and run.

The app runs immediately in local-first mode, even before Firebase is configured.

## Verified build

This repo was verified with:

```bash
xcodebuild -project Setra.xcodeproj -scheme Setra -destination 'generic/platform=iOS' -derivedDataPath /tmp/SetraDerived CODE_SIGNING_ALLOWED=NO build
```

## Firebase activation

The app contains a Firebase-ready integration layer, but it intentionally still runs without Firebase so local development is frictionless.

Follow `docs/firebase-setup.md` to enable:

- Firebase Auth email/password
- Google Sign In
- Firestore persistence
- Firestore rules and indexes

## Product decisions

- Local-first storage is used so planning and workout logging stay available offline.
- Firebase is optional at startup: once configured, the runtime switches from local fallback auth/storage to Firebase-backed auth and remote sync.
- The Firestore integration uses explicit user subcollections instead of opaque server functions so data stays inspectable and export-friendly.
- The progression engine favors clarity over complexity: if all working sets hit the top end of the target rep range, Setra suggests an increment next time.

## Design language

- Near-black graphite backgrounds with icy blue accents
- Rounded glass cards and restrained shadows
- Minimal typography hierarchy optimized for one-handed gym usage
- No gamified clutter, no social feed, no non-essential backend services

See `docs/brand-style-guide.md` for the naming, logo, icon, and style system.

## Docs

- `docs/architecture.md`
- `docs/firebase-setup.md`
- `docs/firestore-schema.md`
- `docs/brand-style-guide.md`
- `docs/seed-library.md`
- `docs/roadmap.md`

