import SwiftUI

struct DayDetailView: View {
    @Environment(WorkspaceStore.self) private var workspaceStore
    @Environment(AuthController.self) private var authController

    @State private var draft: ScheduleDayPlan
    @State private var isAddExercisePresented = false
    @State private var activeWorkout: WorkoutSession?

    init(day: ScheduleDayPlan) {
        _draft = State(initialValue: day)
    }

    var body: some View {
        List {
            Section {
                Picker("Day Type", selection: $draft.kind) {
                    ForEach(DayPlanKind.allCases) { kind in
                        Text(kind.rawValue.capitalized).tag(kind)
                    }
                }
                .pickerStyle(.segmented)

                TextField("Title", text: $draft.title)
                TextField("Subtitle / Focus", text: $draft.subtitle)
                TextField("Notes", text: $draft.notes, axis: .vertical)
                    .lineLimit(3...6)
            }

            if draft.kind == .workout {
                Section("Exercises") {
                    ForEach(draft.exercises) { planned in
                        NavigationLink {
                            if let exercise = workspaceStore.exercise(by: planned.exerciseID) {
                                ExerciseDetailView(exercise: exercise)
                            }
                        } label: {
                            ExercisePlanRow(
                                planned: planned,
                                name: workspaceStore.exercise(by: planned.exerciseID)?.canonicalName ?? "Exercise",
                                summary: workspaceStore.performanceSummary(for: planned.exerciseID)?.lastDescription
                            )
                        }
                    }
                    .onMove(perform: move)
                    .onDelete(perform: delete)

                    Button("Add Exercise") {
                        isAddExercisePresented = true
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(SetraTheme.screenBackground.ignoresSafeArea())
        .navigationTitle(draft.weekday.title)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                EditButton()
            }
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("Save Day") { save() }
                    Button("Save as Template") { saveTemplate() }

                    Menu("Copy to Day") {
                        ForEach(copyTargets) { weekday in
                            Button(weekday.title) {
                                copy(to: weekday)
                            }
                        }
                    }

                    Button(role: .destructive) {
                        clear()
                    } label: {
                        Text("Clear Day")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
            ToolbarItem(placement: .bottomBar) {
                if draft.kind == .workout {
                    Button("Quick Start Workout") {
                        activeWorkout = workspaceStore.startWorkout(from: draft)
                    }
                }
            }
        }
        .sheet(isPresented: $isAddExercisePresented) {
            AddExerciseSearchView { exercise in
                draft.kind = .workout
                draft.exercises.append(
                    PlannedExercise.from(
                        exercise: exercise,
                        unit: workspaceStore.workspace?.settings.weightUnit ?? .pounds,
                        order: draft.exercises.count
                    )
                )
            }
        }
        .sheet(item: $activeWorkout) { session in
            WorkoutSessionView(session: session)
        }
        .onDisappear {
            save()
        }
    }

    private var copyTargets: [Weekday] {
        let ordered = workspaceStore.workspace.map { workspace in
            Weekday.ordered(startingAt: workspace.settings.firstWeekday)
        } ?? Weekday.allCases
        return ordered.filter { $0 != draft.weekday }
    }

    private func save() {
        guard let user = authController.currentUser else { return }
        draft.exercises = draft.exercises.enumerated().map { index, exercise in
            var copy = exercise
            copy.order = index
            return copy
        }
        Task {
            await workspaceStore.updateScheduleDay(draft, for: user)
        }
    }

    private func saveTemplate() {
        guard let user = authController.currentUser else { return }
        Task {
            await workspaceStore.saveTemplate(from: draft, for: user)
        }
    }

    private func copy(to weekday: Weekday) {
        guard let user = authController.currentUser else { return }
        Task {
            await workspaceStore.copyDay(from: draft.weekday, to: weekday, for: user)
        }
    }

    private func clear() {
        guard let user = authController.currentUser else { return }
        draft = ScheduleDayPlan.restDay(for: draft.weekday)
        Task {
            await workspaceStore.clearDay(draft.weekday, for: user)
        }
    }

    private func move(from source: IndexSet, to destination: Int) {
        draft.exercises.move(fromOffsets: source, toOffset: destination)
    }

    private func delete(at offsets: IndexSet) {
        draft.exercises.remove(atOffsets: offsets)
    }
}

private struct ExercisePlanRow: View {
    let planned: PlannedExercise
    let name: String
    let summary: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(name)
                .font(.headline)
            Text("\(planned.targetSetCount) × \(planned.targetRepRange.title)")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            if let summary {
                Text(summary)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct DayDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DayDetailView(day: PreviewEnvironment.workspace().schedule.days.first!)
        }
        .setraPreviewEnvironment()
    }
}
