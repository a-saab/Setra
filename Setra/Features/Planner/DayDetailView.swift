import SwiftUI

struct DayDetailView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(PlanningStore.self) private var planningStore

    @State private var draft: ScheduleDayPlan
    @State private var lastSavedDraft: ScheduleDayPlan
    @State private var isAddExercisePresented = false
    @State private var activeWorkout: WorkoutSession?

    init(day: ScheduleDayPlan) {
        _draft = State(initialValue: day)
        _lastSavedDraft = State(initialValue: day)
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
                            if let exercise = planningStore.exercise(by: planned.exerciseID) {
                                ExerciseDetailView(exercise: exercise)
                            }
                        } label: {
                            ExercisePlanRow(
                                planned: planned,
                                name: planningStore.exercise(by: planned.exerciseID)?.canonicalName ?? "Exercise",
                                summary: planningStore.performanceSummary(for: planned.exerciseID)?.lastDescription
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
                        activeWorkout = planningStore.startWorkout(from: draft)
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
                        unit: planningStore.weightUnit,
                        order: draft.exercises.count
                    )
                )
            }
        }
        .sheet(item: $activeWorkout) { session in
            WorkoutSessionView(session: session)
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background, hasUnsavedChanges {
                save()
            }
        }
    }

    private var hasUnsavedChanges: Bool {
        normalizedDraft != normalizedSavedDraft
    }

    private var normalizedDraft: ScheduleDayPlan {
        normalized(day: draft)
    }

    private var normalizedSavedDraft: ScheduleDayPlan {
        normalized(day: lastSavedDraft)
    }

    private var copyTargets: [Weekday] {
        let ordered = Weekday.ordered(startingAt: planningStore.firstWeekday)
        return ordered.filter { $0 != draft.weekday }
    }

    private func save() {
        let normalizedDraft = normalized(day: draft)
        draft = normalizedDraft
        lastSavedDraft = normalizedDraft
        Task {
            await planningStore.updateScheduleDay(normalizedDraft)
        }
    }

    private func saveTemplate() {
        Task {
            await planningStore.saveTemplate(from: draft)
        }
    }

    private func copy(to weekday: Weekday) {
        Task {
            await planningStore.copyDay(from: draft.weekday, to: weekday)
        }
    }

    private func clear() {
        draft = ScheduleDayPlan.restDay(for: draft.weekday)
        Task {
            await planningStore.clearDay(draft.weekday)
        }
    }

    private func move(from source: IndexSet, to destination: Int) {
        draft.exercises.move(fromOffsets: source, toOffset: destination)
    }

    private func delete(at offsets: IndexSet) {
        draft.exercises.remove(atOffsets: offsets)
    }

    private func normalized(day: ScheduleDayPlan) -> ScheduleDayPlan {
        var copy = day
        copy.exercises = copy.exercises.enumerated().map { index, exercise in
            var normalizedExercise = exercise
            normalizedExercise.order = index
            return normalizedExercise
        }
        return copy
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
