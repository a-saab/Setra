import SwiftUI

struct WorkoutSessionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(WorkoutStore.self) private var workoutStore

    @State var session: WorkoutSession
    @State private var selectedSet: SetSelection?
    @State private var restRemaining = 0
    @State private var timerTask: Task<Void, Never>?

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(session.title)
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.white)
                        Text(session.subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        if restRemaining > 0 {
                            Text("Rest \(formattedRest)")
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(SetraTheme.accent)
                        }
                    }
                    .listRowBackground(Color.clear)
                }

                ForEach($session.exercises) { $exercise in
                    let currentExercise = workoutStore.exercise(by: exercise.exerciseID)
                    Section {
                        VStack(alignment: .leading, spacing: 14) {
                            Text(currentExercise?.canonicalName ?? "Exercise")
                                .font(.headline)
                                .foregroundStyle(.white)
                            Text("\(exercise.targetSets) × \(exercise.targetRepRange.title)")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.secondary)

                            if let previous = exercise.previousPerformance {
                                Text(previous.lastDescription)
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }

                            if let suggestion = exercise.suggestedLoad {
                                Text(suggestion.reason)
                                    .font(.footnote)
                                    .foregroundStyle(SetraTheme.accent)
                            }

                            ForEach(exercise.workingSets.indices, id: \.self) { index in
                                SetEntryRow(
                                    index: index + 1,
                                    set: $exercise.workingSets[index],
                                    exercise: currentExercise,
                                    unit: session.unit,
                                    onPickWeight: {
                                        selectedSet = SetSelection(
                                            exerciseIndex: exercise.order,
                                            setIndex: index,
                                            exerciseID: exercise.exerciseID
                                        )
                                    }
                                )
                            }

                            Toggle("Completed all prescribed work", isOn: $exercise.completedAllPrescribedWork)
                            Toggle("Last set to failure completed", isOn: $exercise.lastSetFailureCompleted)

                            Button("Start Rest Timer") {
                                startRestTimer(duration: workoutStore.settings.restTimerSeconds)
                            }
                            .buttonStyle(SecondaryActionButtonStyle())
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(SetraTheme.screenBackground.ignoresSafeArea())
            .navigationTitle("Live Workout")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Finish", action: finish)
                }
            }
            .sheet(item: $selectedSet) { selection in
                WeightPickerSheet(
                    exercise: workoutStore.exercise(by: selection.exerciseID),
                    unit: session.unit,
                    initialWeight: session.exercises[selection.exerciseIndex].workingSets[selection.setIndex].load,
                    settings: workoutStore.settings
                ) { newWeight in
                    session.exercises[selection.exerciseIndex].workingSets[selection.setIndex].load = newWeight
                }
            }
        }
    }

    private var formattedRest: String {
        let minutes = restRemaining / 60
        let seconds = restRemaining % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    private func startRestTimer(duration: Int) {
        restRemaining = duration
        timerTask?.cancel()
        timerTask = Task {
            while restRemaining > 0 {
                try? await Task.sleep(for: .seconds(1))
                await MainActor.run {
                    restRemaining -= 1
                }
            }
        }
    }

    private func finish() {
        var completed = session
        completed.completedAt = .now
        Task {
            await workoutStore.saveCompletedWorkout(completed)
            dismiss()
        }
    }
}

private struct SetSelection: Identifiable {
    let id = UUID()
    var exerciseIndex: Int
    var setIndex: Int
    var exerciseID: String
}

private struct SetEntryRow: View {
    let index: Int
    @Binding var set: SetLog
    let exercise: Exercise?
    let unit: WeightUnit
    let onPickWeight: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Text("\(index)")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(Circle().fill(Color.white.opacity(0.08)))

            Button(action: onPickWeight) {
                Text(loadLabel)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.white.opacity(0.06))
                    )
            }
            .buttonStyle(.plain)

            Spacer()

            Stepper {
                Text("\(set.reps ?? set.targetReps ?? 0) reps")
                    .foregroundStyle(.white)
            } onIncrement: {
                set.reps = (set.reps ?? set.targetReps ?? 0) + 1
            } onDecrement: {
                set.reps = max(0, (set.reps ?? set.targetReps ?? 0) - 1)
            }
            .labelsHidden()
        }
    }

    private var loadLabel: String {
        guard let load = set.load else { return exercise?.exerciseType == .barbell ? "Set barbell load" : "Add load" }
        if exercise?.exerciseType == .barbell {
            return "\(load.clean) \(unit.shortLabel) total"
        }
        return "\(load.clean) \(unit.shortLabel)"
    }
}

private struct WeightPickerSheet: View {
    @Environment(\.dismiss) private var dismiss

    let exercise: Exercise?
    let unit: WeightUnit
    let initialWeight: Double?
    let settings: AppSettings
    let onSave: (Double) -> Void

    @State private var text = ""
    private let parser = BarbellLoadParser()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    TextField(placeholderText, text: $text)
                        .keyboardType(.decimalPad)
                        .authField()

                    if let parsedBarbellLoad {
                        GlassCard {
                            VStack(alignment: .leading, spacing: 10) {
                                SectionHeader("Resolved Load", subtitle: parsedBarbellLoad.summary)
                                Text("\(parsedBarbellLoad.totalWeight.clean) \(unit.shortLabel) total")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                Text("Bar: \(parsedBarbellLoad.barWeight.clean) \(unit.shortLabel) • Side: \(parsedBarbellLoad.perSideWeight.clean) \(unit.shortLabel)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        let result = PlateCalculator().calculate(targetWeight: parsedBarbellLoad.totalWeight, settings: settings)
                        GlassCard {
                            VStack(alignment: .leading, spacing: 10) {
                                SectionHeader("Plate Builder", subtitle: result.isAchievable ? "Per side distribution" : "Closest available stack")
                                Text(result.platesPerSide.map(\.displayWeight).joined(separator: " • "))
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    } else if let resolvedWeight {
                        GlassCard {
                            VStack(alignment: .leading, spacing: 10) {
                                SectionHeader("Resolved Load")
                                Text("\(resolvedWeight.clean) \(unit.shortLabel)")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                }
                .padding(20)
            }
            .scrollIndicators(.hidden)
            .background(SetraTheme.screenBackground.ignoresSafeArea())
            .navigationTitle(exercise?.exerciseType == .barbell ? "Set Barbell Load" : "Pick Load")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        guard let resolvedWeight else { return }
                        onSave(resolvedWeight)
                        dismiss()
                    }
                    .disabled(resolvedWeight == nil)
                }
            }
            .onAppear {
                text = initialWeight?.clean ?? ""
            }
        }
    }

    private var placeholderText: String {
        guard exercise?.exerciseType == .barbell else { return "Weight" }
        return settings.preferredBarbellEntryMode.subtitle
    }

    private var parsedBarbellLoad: ParsedBarbellLoad? {
        guard exercise?.exerciseType == .barbell else { return nil }
        return parser.parse(text: text, settings: settings)
    }

    private var resolvedWeight: Double? {
        if let parsedBarbellLoad {
            return parsedBarbellLoad.totalWeight
        }
        return Double(text)
    }
}

struct WorkoutSessionView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutSessionView(
            session: PreviewEnvironment.workspaceStore().startWorkout(
                from: PreviewEnvironment.workspace().schedule.days.first { $0.kind == .workout }!
            )
        )
        .setraPreviewEnvironment()
    }
}
