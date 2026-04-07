import SwiftUI

struct ProfileView: View {
    @Environment(WorkspaceStore.self) private var workspaceStore
    @Environment(AuthController.self) private var authController

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 18) {
                accountCard
                preferencesCard
                accountActionsCard
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .padding(.bottom, 20)
        }
        .scrollIndicators(.hidden)
        .background(
            SetraTheme.screenBackground
                .overlay(SetraTheme.ambientGlow)
                .ignoresSafeArea()
        )
        .navigationTitle("You")
    }

    private var accountCard: some View {
        GlassCard {
            HStack(spacing: 16) {
                BrandMark(size: 68)

                VStack(alignment: .leading, spacing: 6) {
                    Text(workspaceStore.workspace?.profile.displayName ?? "Setra Athlete")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(SetraTheme.primaryText)
                    Text(workspaceStore.workspace?.profile.email ?? authController.currentUser?.email ?? "")
                        .font(.subheadline)
                        .foregroundStyle(SetraTheme.secondaryText)
                    Text("The profile area should stay operational and low-noise so it never competes with training.")
                        .font(.footnote)
                        .foregroundStyle(SetraTheme.secondaryText)
                }
            }
        }
    }

    private var preferencesCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionHeader("Preferences", subtitle: "Keep utilities here, not in the middle of the workout flow")

                NavigationLink {
                    SettingsView()
                } label: {
                    profileRow(title: "Settings", subtitle: "Units, week structure, progression, experience")
                }
                .buttonStyle(.plain)

                NavigationLink {
                    BodyweightLogView()
                } label: {
                    profileRow(title: "Bodyweight", subtitle: "Track entries and keep trend context")
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var accountActionsCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionHeader("Account")

                Button("Sign Out", role: .destructive) {
                    Task {
                        await authController.signOut()
                    }
                }
                .buttonStyle(SecondaryActionButtonStyle())
            }
        }
    }

    private func profileRow(title: String, subtitle: String) -> some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(SetraTheme.mutedFill)
                .frame(width: 42, height: 42)
                .overlay(
                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.bold))
                        .foregroundStyle(SetraTheme.accent)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(SetraTheme.primaryText)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(SetraTheme.secondaryText)
            }

            Spacer()
        }
    }
}

private struct BodyweightLogView: View {
    @Environment(WorkspaceStore.self) private var workspaceStore
    @Environment(AuthController.self) private var authController

    @State private var value = ""

    var body: some View {
        List {
            Section("Log Today") {
                TextField("Bodyweight", text: $value)
                    .keyboardType(.decimalPad)
                Button("Save Entry", action: save)
            }

            Section("Recent Entries") {
                if let logs = workspaceStore.workspace?.bodyweightLogs, !logs.isEmpty {
                    ForEach(logs) { log in
                        HStack {
                            Text(log.date.formatted(.dateTime.month().day()))
                            Spacer()
                            Text("\(log.weight.clean) \(log.unit.shortLabel)")
                        }
                    }
                } else {
                    Text("No bodyweight entries yet.")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(SetraTheme.screenBackground.ignoresSafeArea())
        .navigationTitle("Bodyweight")
    }

    private func save() {
        guard let user = authController.currentUser, let weight = Double(value) else { return }
        let log = BodyweightLog(
            id: UUID().uuidString,
            date: .now,
            weight: weight,
            unit: workspaceStore.workspace?.settings.weightUnit ?? .pounds,
            note: ""
        )
        Task {
            await workspaceStore.addBodyweightLog(log, for: user)
            value = ""
        }
    }
}

private struct SettingsView: View {
    @Environment(WorkspaceStore.self) private var workspaceStore
    @Environment(AuthController.self) private var authController

    @State private var settings = AppSettings.default

    var body: some View {
        Form {
            Section("Weekly Planning") {
                Picker("Week Starts", selection: $settings.firstWeekday) {
                    ForEach(Weekday.allCases) { day in
                        Text(day.title).tag(day)
                    }
                }
            }

            Section("Units") {
                Picker("Weight Unit", selection: $settings.weightUnit) {
                    ForEach(WeightUnit.allCases) { unit in
                        Text(unit.displayName).tag(unit)
                    }
                }
                .onChange(of: settings.weightUnit) { _, _ in
                    settings.applyWeightUnitDefaults()
                }
            }

            Section("Barbell Entry") {
                Stepper(
                    "Barbell: \(settings.defaultBarbellWeight.clean) \(settings.weightUnit.shortLabel)",
                    value: $settings.defaultBarbellWeight,
                    in: settings.weightUnit == .pounds ? 15...70 : 10...30,
                    step: settings.weightUnit == .pounds ? 5 : 2.5
                )

                Picker("Preferred Input", selection: $settings.preferredBarbellEntryMode) {
                    ForEach(BarbellEntryMode.allCases) { mode in
                        Text(mode.title).tag(mode)
                    }
                }

                Text(settings.preferredBarbellEntryMode.subtitle)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
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
                Button("Save", action: save)
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
