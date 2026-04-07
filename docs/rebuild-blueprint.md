# Setra Remake Blueprint

## Phase 1. Current-State Audit

### What the app does now

Setra is currently a solo-user strength training planner and workout logger. It lets a user:

- sign up or sign in with Firebase or a local development fallback
- complete onboarding with gym preferences
- define a weekly split
- search or create exercises
- log workouts and bodyweight
- review simple history and progress charts

### Core user value proposition

The best part of the current product is simple: it helps a lifter walk into the gym with a plan and leave with a clean record of what happened.

### Likely target user

- self-directed lifter
- intermediate beginner through intermediate
- wants structure, not entertainment
- cares about progression, speed, and clarity more than social features

### Strongest parts

- The domain model is better than the UI it powers. Exercise, schedule, session, and settings types are explicit and reasonably coherent.
- The product is already local-first enough to avoid blocking workout logging on network conditions.
- The seeded exercise library and progression hints show the right product instinct: reduce friction during real training.

### Weakest parts

- The app has no sharp product opinion. It is a bundle of planner, logger, settings, and charts rather than a focused training companion.
- The UI looks like a well-made concept app, not a high-retention shipped product.
- `WorkspaceStore` is effectively the whole application state and mutation layer. It is too broad to scale safely.
- Firebase is doing too much implicitly and not enough deliberately. The issue is not that another backend is missing; it is that the current Firebase usage has not been shaped into a disciplined product backend.

### Product and UX problems

- The app is tab-driven, but the product is not truly organized around the user’s main job: opening the app and knowing what to do next.
- Onboarding asks for too much low-confidence setup up front before the app earns trust.
- Planner editing is dense and utilitarian.
- History and analytics are separated in a way that makes both feel thin.
- Settings and profile flows look functional but generic.
- Empty, loading, and error states are present but not systematized.

### Architecture and engineering problems

- `WorkspaceStore` mixes bootstrapping, persistence scheduling, mutations, analytics access, search coordination, and workout assembly.
- The app still uses `ObservableObject`, `@StateObject`, and `@EnvironmentObject` instead of the more modern Observation stack already supported by the project settings.
- Firebase sync is snapshot-oriented and silent-failure tolerant. That is okay for a prototype, but not for a premium multi-device product.
- Local auth fallback is useful for development, but the current implementation can blur product assumptions because it behaves like a shadow auth system.
- There are no tests, no build verification layer, no structured analytics taxonomy, no release hardening path, and no monitoring plan.

### Backend and data problems

- There is no server-side API boundary, but that is acceptable for this stage of the product. The real issue is missing discipline around Firebase modeling, validation, analytics, and sync behavior.
- Firestore rules are permissive at the ownership boundary but do not validate document shapes or write constraints.
- All sync is essentially last-write-wins snapshot mirroring.
- There is no clean path yet for future capabilities such as entitlements, notification orchestration, remote config, recovery flows, or abuse controls if the app outgrows direct client-to-Firebase patterns.

### Security and privacy concerns

- No App Check strategy.
- No server-side abuse or write-hardening strategy beyond Firestore ownership rules.
- No observability pipeline for auth failures, sync issues, or degraded launch paths.

### App Store quality gaps

- No testing target
- No localization strategy
- No clear accessibility system
- No release checklist
- No notification permissions strategy
- No subscription or monetization hooks, which is fine for now, but there is also no deliberate decision framework around it

### Blunt assessment

Preserve:

- the core concept of a calm, serious training companion
- the local-first mindset for workout execution
- much of the domain vocabulary

Redesign:

- product focus
- information architecture
- onboarding
- navigation shell
- visual system
- analytics and progress surfacing
- state architecture
- sync boundaries

Delete:

- the assumption that Firebase is the whole backend
- generic “glass concept” styling used as the default visual language
- the current broad store-as-app-architecture approach
- vague backend ambitions that add complexity without current product need

Rebuild from zero:

- app shell
- feature architecture
- design system
- observability model
- release readiness pipeline

## Phase 2. Redefined Product

### Product vision

Setra should become a today-first strength training companion for people who want to train consistently without thinking like spreadsheet operators.

### Target user

- serious casual lifter
- values structure and measurable progress
- does not want a loud fitness app
- likely trains 3 to 5 times per week
- wants a product that feels dependable, private, and fast

### Primary use cases

- open the app and instantly see today’s plan
- start a session in one tap
- log sets faster than using Notes
- understand what changed since the last session
- stay aligned to a weekly rhythm without feeling micromanaged

### Secondary use cases

- adapt plan structure
- review progress and trends
- track bodyweight and adherence
- create or customize exercises

### Success metrics

- day-1 onboarding completion
- workout start rate from app open
- session completion rate
- weekly active retention
- plan adherence
- edit-to-log friction time
- sync reliability

### Emotional goal

The app should feel calm, prepared, precise, and quietly motivating. It should feel like opening a finely designed instrument, not a fitness marketplace.

### Healthy retention loop

- show the next relevant action immediately
- reflect progress clearly after every session
- preserve momentum across days
- use reminders sparingly and only when tied to the user’s real schedule

## Phase 3. UX and UI Redesign

### Experience pillars

- native
- fast
- legible
- restrained
- confidence-building

### Information architecture

- Today: next workout, current rhythm, quick resume, recovery context
- Plan: weekly structure, templates, day editing
- Progress: recent sessions, streaks, records, bodyweight and volume trends
- You: settings, bodyweight, account, notification controls

### Major screens

#### Today

- Purpose: answer “what should I do now?”
- Layout: hero, metrics strip, next-session details, recent wins, upcoming rhythm
- States: ready, rest day, empty plan, stale data, in-progress workout
- Accessibility: large tap targets, spoken workout summaries, reduced-motion-safe transitions

#### Plan

- Purpose: edit the training week without overwhelm
- Layout: weekly overview first, then day cards, then templates
- Interactions: quick copy, reorder, template save, day drill-in
- Edge cases: no plan yet, all-rest week, custom exercise deleted, schedule copy conflicts

#### Progress

- Purpose: make effort feel visible
- Layout: summary metrics first, then charts, then recent sessions
- Interactions: tap through to workout summary and exercise detail
- Edge cases: low-data states should still feel intentional, not empty

#### You

- Purpose: keep operational controls and personal data out of the main training flow
- Layout: account summary, bodyweight, preferences, notification and privacy controls
- Edge cases: signed-out fallback, sync issues, Firebase-disabled local development mode

## Phase 4. Target Architecture

### iOS

- SwiftUI-first with Observation-based app state
- feature-based folders with smaller focused stores
- root app shell responsible only for session and navigation concerns
- reusable design system with semantic tokens and screen scaffolds
- async workflows modeled explicitly, not hidden inside ad hoc tasks

### Firebase

Firebase becomes the primary backend for v1, but with much stricter boundaries.

- Auth: identity and client session bootstrap
- Firestore: user-scoped durable data
- Cloud Messaging: notifications when needed
- Analytics: product telemetry, but only for defined events
- App Check: protect production endpoints and reduce abuse
- Remote Config: only if it serves a real product or rollout need

### Optional server layer later

Do not add a second backend just to look “architected.”

- Start with direct client-to-Firebase flows for v1
- Add a server layer later only if the product truly needs server-owned logic, webhook processing, entitlement verification, or cross-service orchestration
- If that day comes, choose the smallest backend addition that solves the specific problem

### Data strategy

- local-first cached workspace on device
- Firestore remains source of durable user data
- future path for conflict-aware merge, drafts, multi-device recovery, and optional server-side workflows if needed

## Phase 5. Rebuild Plan

1. Foundation
   - Observation migration
   - new shell
   - design tokens
   - app state boundaries
2. Architecture skeleton
   - feature folders
   - routing model
   - service protocols
   - environment injection
3. Design system
   - surfaces
   - typography
   - spacing
   - buttons
   - empty, loading, and error states
4. Core flows
   - auth
   - onboarding
   - today
   - workout execution
   - progress
5. Backend
   - Firebase data contract cleanup
   - Firestore rules hardening
   - App Check strategy
   - observability and analytics taxonomy
6. Data layer
   - repository split
   - sync engine
   - offline drafts
7. Polish
   - haptics
   - motion
   - accessibility
   - copywriting
8. Testing
   - domain tests
   - store tests
   - snapshot or preview coverage
9. Launch hardening
   - analytics taxonomy
   - notifications strategy
   - release checklist
   - failure reporting

## Phase 6. Execution Start

The first implementation slice should:

- modernize app state injection
- replace the generic shell with a sharper today-first navigation structure
- establish a more premium, restrained visual system
- prepare the codebase for a deeper feature-by-feature rewrite

## Stack Decision

For the current remake, the stack is:

- iOS frontend: Swift / SwiftUI
- backend and persistence: Firebase-first
- no Cloudflare in v1

Add another backend only when the product has a concrete need for it.
