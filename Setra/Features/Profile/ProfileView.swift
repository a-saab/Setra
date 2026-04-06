import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var workspaceStore: WorkspaceStore
    @EnvironmentObject private var authController: AuthController

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 6) {
                    Text(workspaceStore.workspace?.profile.displayName ?? "Setra Athlete")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.white)
                    Text(workspaceStore.workspace?.profile.email ?? authController.currentUser?.email ?? "")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }

            Section("Preferences") {
                NavigationLink("Settings") {
                    SettingsView()
                }
                NavigationLink("Bodyweight Log") {
                    BodyweightLogView()
                }
            }

            Section("Account") {
                Button("Sign Out", role: .destructive) {
                    Task {
                        await authController.signOut()
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(SetraTheme.screenBackground.ignoresSafeArea())
        .navigationTitle("Profile")
    }
}

private struct BodyweightLogView: View {
    @EnvironmentObject private var workspaceStore: WorkspaceStore
    @EnvironmentObject private var authController: AuthController

    @State private var value = ""

    var body: some View {
        List {
            Section("Log Today") {
                TextField("Bodyweight", text: $value)
                    .keyboardType(.decimalPad)
                Button("Save Entry") {
                    save()
                }
            }

            Section("Recent Entries") {
                ForEach(workspaceStore.workspace?.bodyweightLogs ?? []) { log in
                    HStack {
                        Text(log.date.formatted(.dateTime.month().day()))
                        Spacer()
                        Text("\(log.weight.clean) \(log.unit.shortLabel)")
                    }
                }
            }
        }
        .navigationTitle("Bodyweight")
    }

    private func save() {
        guard let user = authController.currentUser, let weight = Double(value) else { return }
        let log = BodyweightLog(id: UUID().uuidString, date: .now, weight: weight, unit: workspaceStore.workspace?.settings.weightUnit ?? .pounds, note: "")
        Task {
            await workspaceStore.addBodyweightLog(log, for: user)
            value = ""
        }
    }
}

private struct SettingsView: View {
    @EnvironmentObject private var workspaceStore: WorkspaceStore
    @EnvironmentObject private var authController: AuthController

    @State private var settings = AppSettings.default

    var body: some View {
        Form {
            Section("Units") {
                Picker("Weight Unit", selection: $settings.weightUnit) {
                    ForEach(WeightUnit.allCases) { unit in
                        Text(unit.displayName).tag(unit)
                    }
                }
                Stepper("Barbell: \(settings.defaultBarbellWeight.clean) \(settings.weightUnit.shortLabel)", value: $settings.defaultBarbellWeight, in: 15...100, step: settings.weightUnit == .pounds ? 5 : 2.5)
            }

            Section("Progression") {
                Stepper("Upper Body +\(settings.upperBodyIncrement.clean)", value: $settings.upperBodyIncrement, in: 1...10, step: settings.weightUnit == .pounds ? 2.5 : 1)
                Stepper("Lower Body +\(settings.lowerBodyIncrement.clean)", value: $settings.lowerBodyIncrement, in: 1...20, step: settings.weightUnit == .pounds ? 5 : 2.5)
                Stepper("Rest Timer \(settings.restTimerSeconds)s", value: $settings.restTimerSeconds, in: 30...300, step: 15)
            }

            Section("Experience") {
                Picker("Theme", selection: $settings.themePreference) {
                    ForEach(ThemePreference.allCases) { theme in
                        Text(theme.rawValue.capitalized).tag(theme)
                    }
                }
                Toggle("Inline Previous Performance", isOn: $settings.showInlinePerformance)
                Toggle("Haptics", isOn: $settings.hapticsEnabled)
            }
        }
        .navigationTitle("Settings")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") { save() }
            }
        }
        .onAppear {
            settings = workspaceStore.workspace?.settings ?? .default
        }
    }

    private func save() {
        guard let user = authController.currentUser else { return }
        Task {
            await workspaceStore.updateSettings(settings, for: user)
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ProfileView()
        }
        .setraPreviewEnvironment()
    }
}
