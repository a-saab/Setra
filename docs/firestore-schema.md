# Firestore Schema

Setra uses user-scoped documents and subcollections. Every path is owned by a single authenticated user.

## Top-level ownership

```text
users/{userId}
```

`userId` must match `request.auth.uid`.

## Collections and documents

### `users/{userId}`

Profile / ownership document.

Fields:

- `ownerId: string`
- `displayName: string`
- `email: string`
- `hasCompletedOnboarding: boolean`
- `createdAt: timestamp or ISO string`
- `updatedAt: timestamp or ISO string`

### `users/{userId}/settings/app`

Single settings document.

Fields:

- `weightUnit`
- `defaultBarbellWeight`
- `plateInventory[]`
- `favoritePlateSetups[]`
- `restTimerSeconds`
- `upperBodyIncrement`
- `lowerBodyIncrement`
- `themePreference`
- `showInlinePerformance`
- `hapticsEnabled`
- `gymEquipmentLevel`
- `trainingGoals[]`

### `users/{userId}/weeklySchedules/current`

Current active split.

Fields:

- `id`
- `title`
- `notes`
- `days[]`

Each day stores:

- `id`
- `weekday`
- `kind`
- `title`
- `subtitle`
- `notes`
- `exercises[]`

Each planned exercise stores:

- `id`
- `exerciseID`
- `order`
- `targetSetCount`
- `targetRepRange`
- `targetWeight`
- `defaultRestTime`
- `notes`
- `lastSetIntensity`
- `warmUpSets[]`
- `supersetTag`

### `users/{userId}/workoutTemplates/{templateId}`

Reusable saved day templates.

Fields:

- `id`
- `name`
- `subtitle`
- `notes`
- `exercises[]`
- `createdAt`
- `updatedAt`

### `users/{userId}/customExercises/{exerciseId}`

User-created exercise definitions.

Fields:

- `id`
- `source`
- `canonicalName`
- `aliases[]`
- `primaryMuscle`
- `secondaryMuscles[]`
- `equipment`
- `movementPattern`
- `exerciseType`
- `defaultRepRange`
- `defaultSetCount`
- `defaultRestTime`
- `notes`
- `cues[]`
- `lastSetToFailure`
- `intensityStyle`
- `keywords[]`
- `progressionRule`
- `media`

### `users/{userId}/workoutSessions/{sessionId}`

Completed or in-progress workout sessions.

Fields:

- `id`
- `weekday`
- `title`
- `subtitle`
- `startedAt`
- `completedAt`
- `notes`
- `state`
- `unit`
- `exercises[]`

Each logged exercise stores:

- `id`
- `plannedExerciseID`
- `exerciseID`
- `order`
- `targetSets`
- `targetRepRange`
- `warmUpSets[]`
- `workingSets[]`
- `notes`
- `completedAllPrescribedWork`
- `lastSetFailureCompleted`
- `previousPerformance`
- `suggestedLoad`

Each set log stores:

- `id`
- `kind`
- `targetReps`
- `reps`
- `load`
- `unit`
- `isPerHand`
- `didReachFailure`
- `note`

### `users/{userId}/bodyweightLogs/{logId}`

Fields:

- `id`
- `date`
- `weight`
- `unit`
- `note`

### `users/{userId}/personalRecords/{recordId}`

Fields:

- `id`
- `exerciseID`
- `date`
- `weight`
- `reps`
- `unit`
- `label`

### `users/{userId}/meta/favorites`

Fields:

- `ids[]`: favorite exercise IDs

### `users/{userId}/meta/recentExercises`

Fields:

- `ids[]`: recent exercise IDs in order

## Built-in exercise library

The built-in library ships locally in the app and is not required in Firestore for v1.

This keeps startup fast and avoids duplication across users.

## IDs

- `userId`: Firebase Auth UID
- `templateId`: UUID
- `exerciseId`: built-in slug or UUID for custom exercises
- `sessionId`: UUID
- `logId`: UUID
- `recordId`: deterministic or UUID

## Ownership rules

- Users can only read/write their own root doc and subcollections.
- No shared global workout data is required for v1.
- Built-in exercises are bundled locally and safe from accidental mutation.

