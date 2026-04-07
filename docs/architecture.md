# Setra Architecture

## Principles

- Fast over flashy
- Clear over clever
- Local-first for the workout flow
- Firebase-first for v1 without blocking local development
- Explicit models and repository seams over giant ad hoc state

## Layers

### App

- `SetraApp.swift` wires observation-backed root state into SwiftUI.
- `AuthController` owns sign-in state and delegates work to an auth provider.
- `WorkspaceStore` still owns too much, but now serves as the transitional app store until feature-scoped stores replace it.

### Domain

- `WorkoutModels.swift` contains the reusable domain model layer.
- `ExerciseSearchEngine` ranks exact matches, aliases, typo-tolerant matches, favorites, and recents.
- `ProgressionEngine` calculates last performance and next-session recommendations.
- `PlateCalculator` computes plate-per-side distributions from the saved gym setup.
- `AnalyticsEngine` derives volume, streaks, bodyweight trend, and PR summaries from sessions.

### Data

- `LocalWorkspaceStore` persists a full user workspace snapshot to app support storage for offline resilience.
- `CompositeWorkspaceRepository` writes local first, then mirrors to remote when Firebase is active.
- `FirebaseRuntime` contains the concrete Firebase Auth and Firestore implementation behind conditional imports.

### Features

- `Auth`: welcome, sign up, log in, forgot password
- `Onboarding`: initial preferences and defaults
- `Dashboard`: today view, adherence, upcoming days, PR and bodyweight snippets
- `Planner`: weekly split editing and day detail editing
- `Exercises`: search, filtering, detail, favorites, custom exercise creation
- `Workout`: live session logging, plate picker, rest timer
- `History`: completed workouts and analytics
- `Profile`: account, settings, sign out, bodyweight logging

## Persistence strategy

### Local

- Every signed-in user gets a local `workspace-<user-id>.json`.
- Writes are debounced to avoid thrashing while the user edits quickly.
- The app is fully usable with only local persistence.

### Remote

- Firebase Auth and Firestore are the primary backend in production and activate when the required packages and config are installed.
- Firestore mirrors the same workspace data into structured user subcollections.
- Local remains the primary store for the active session; remote sync is additive.

## Why a local-first store for v1

- Workout logging must not stall on connectivity.
- Firebase setup varies per environment and should not block UI development.
- The repository abstraction keeps the app ready for more granular sync or conflict resolution later.

## Tradeoffs

- `WorkspaceStore` is still intentionally broad, but it is transitional and should be split by feature as the rewrite continues.
- Firestore sync is snapshot-oriented rather than streaming listeners in v1 to keep the implementation transparent and dependable.
- The app favors explicit fields and clean exports over adding a second backend prematurely.
