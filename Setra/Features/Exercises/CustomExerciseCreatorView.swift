import PhotosUI
import SwiftUI

struct CustomExerciseCreatorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(WorkspaceStore.self) private var workspaceStore
    @Environment(AuthController.self) private var authController

    @State private var name = ""
    @State private var aliases = ""
    @State private var notes = ""
    @State private var instructions = ""
    @State private var primaryMuscle: MuscleGroup = .chest
    @State private var secondaryMuscles: Set<MuscleGroup> = []
    @State private var equipment: EquipmentType = .dumbbell
    @State private var movementPattern: MovementPattern = .press
    @State private var exerciseType: ExerciseType = .dumbbell
    @State private var repLower = 8
    @State private var repUpper = 12
    @State private var setCount = 3
    @State private var restTime = 90
    @State private var intensityStyle: IntensityStyle = .none
    @State private var pickerItem: PhotosPickerItem?
    @State private var imagePath: String?

    let onSave: (Exercise) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Identity") {
                    TextField("Name", text: $name)
                    TextField("Aliases / keywords", text: $aliases)
                    Picker("Primary Muscle", selection: $primaryMuscle) {
                        ForEach(MuscleGroup.allCases) { muscle in
                            Text(muscle.title).tag(muscle)
                        }
                    }
                    Picker("Equipment", selection: $equipment) {
                        ForEach(EquipmentType.allCases) { item in
                            Text(item.title).tag(item)
                        }
                    }
                    Picker("Movement", selection: $movementPattern) {
                        ForEach(MovementPattern.allCases) { item in
                            Text(item.title).tag(item)
                        }
                    }
                    Picker("Type", selection: $exerciseType) {
                        ForEach(ExerciseType.allCases) { item in
                            Text(item.title).tag(item)
                        }
                    }
                }

                Section("Programming Defaults") {
                    Stepper("Sets: \(setCount)", value: $setCount, in: 1...8)
                    Stepper("Rep Floor: \(repLower)", value: $repLower, in: 1...20)
                    Stepper("Rep Ceiling: \(repUpper)", value: $repUpper, in: repLower...25)
                    Stepper("Rest: \(restTime)s", value: $restTime, in: 30...300, step: 15)
                    Picker("Intensity Style", selection: $intensityStyle) {
                        ForEach(IntensityStyle.allCases) { style in
                            Text(style.title).tag(style)
                        }
                    }
                }

                Section("Notes") {
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                    TextField("Custom instructions", text: $instructions, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("Optional Image") {
                    PhotosPicker(selection: $pickerItem, matching: .images) {
                        Label(imagePath == nil ? "Choose Photo" : "Replace Photo", systemImage: "photo")
                    }
                }
            }
            .navigationTitle("Custom Exercise")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .task(id: pickerItem) {
                guard let pickerItem else { return }
                if let data = try? await pickerItem.loadTransferable(type: Data.self) {
                    imagePath = try? ExerciseImageStore.persistImage(data: data)
                }
            }
        }
    }

    private func save() {
        guard let user = authController.currentUser else { return }
        let exercise = Exercise(
            id: UUID().uuidString,
            source: .custom,
            canonicalName: name,
            aliases: aliases.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) },
            primaryMuscle: primaryMuscle,
            secondaryMuscles: Array(secondaryMuscles),
            equipment: equipment,
            movementPattern: movementPattern,
            exerciseType: exerciseType,
            defaultRepRange: RepRange(lowerBound: repLower, upperBound: repUpper),
            defaultSetCount: setCount,
            defaultRestTime: restTime,
            notes: notes,
            cues: instructions.split(separator: ".").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty },
            lastSetToFailure: intensityStyle == .failure,
            intensityStyle: intensityStyle,
            keywords: aliases.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) },
            progressionRule: .upperBodyDefault,
            media: ExerciseMedia(localSymbolName: primaryMuscle.symbolName, remoteURL: nil, userImagePath: imagePath)
        )

        Task {
            await workspaceStore.saveCustomExercise(exercise, for: user)
            onSave(exercise)
            dismiss()
        }
    }
}

enum ExerciseImageStore {
    static func persistImage(data: Data) throws -> String {
        let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appendingPathComponent("Setra/Images", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        let fileURL = directory.appendingPathComponent("\(UUID().uuidString).jpg")
        try data.write(to: fileURL)
        return fileURL.path
    }
}
