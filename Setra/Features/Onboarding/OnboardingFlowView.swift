import SwiftUI

struct OnboardingFlowView: View {
    let user: AuthUser

    @Environment(WorkspaceStore.self) private var workspaceStore

    @State private var displayName: String
    @State private var settings = AppSettings.default
    @State private var selectedGoals: Set<TrainingGoal> = [.hypertrophy]
    @State private var isSaving = false

    init(user: AuthUser) {
        self.user = user
        _displayName = State(initialValue: user.displayName)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                header
                identityCard
                setupCard
                barbellCard
                experienceCard
                actionCard
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
        .scrollIndicators(.hidden)
        .background(
            SetraTheme.screenBackground
                .overlay(SetraTheme.ambientGlow)
                .ignoresSafeArea()
        )
        .onChange(of: settings.weightUnit) { _, _ in
            settings.applyWeightUnitDefaults()
        }
    }

    private var header: some View {
        VStack(spacing: 12) {
            Spacer(minLength: 8)
            BrandMark(size: 86)
            Text("Tune Setra To Your Gym")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
            Text("Choose your training defaults once so logging stays fast when you are actually lifting.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 10)
    }

    private var identityCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 18) {
                SectionHeader("Identity", subtitle: "Quick to change later")
                TextField("Display Name", text: $displayName)
                    .authField()

                VStack(alignment: .leading, spacing: 10) {
                    SectionHeader("Primary Goal")
                    FlexibleTagSelector(
                        options: TrainingGoal.allCases,
                        selected: $selectedGoals,
                        title: \.title
                    )
                }
            }
        }
    }

    private var setupCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 18) {
                SectionHeader("Gym Setup", subtitle: "Used for defaults and weekly planning")

                Picker("Weight Unit", selection: $settings.weightUnit) {
                    ForEach(WeightUnit.allCases) { unit in
                        Text(unit.displayName).tag(unit)
                    }
                }
                .pickerStyle(.segmented)

                Picker("Week Starts", selection: $settings.firstWeekday) {
                    ForEach(Weekday.allCases) { day in
                        Text(day.title).tag(day)
                    }
                }
                .pickerStyle(.menu)

                Picker("Equipment Level", selection: $settings.gymEquipmentLevel) {
                    ForEach(GymEquipmentLevel.allCases) { item in
                        Text(item.title).tag(item)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
    }

    private var barbellCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 18) {
                SectionHeader("Barbell Entry", subtitle: "Set how fast load input should work in-session")

                Stepper(
                    "Default Barbell: \(settings.defaultBarbellWeight.clean) \(settings.weightUnit.shortLabel)",
                    value: $settings.defaultBarbellWeight,
                    in: settings.weightUnit == .pounds ? 15...70 : 10...30,
                    step: settings.weightUnit == .pounds ? 5 : 2.5
                )

                Picker("Preferred Entry", selection: $settings.preferredBarbellEntryMode) {
                    ForEach(BarbellEntryMode.allCases) { mode in
                        Text(mode.title).tag(mode)
                    }
                }
                .pickerStyle(.menu)

                VStack(alignment: .leading, spacing: 6) {
                    Text(settings.preferredBarbellEntryMode.subtitle)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                    Text(exampleEntryCopy)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.white.opacity(0.06))
                )
            }
        }
    }

    private var experienceCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 18) {
                SectionHeader("Experience", subtitle: "Everything here stays editable in Settings")

                Picker("Theme", selection: $settings.themePreference) {
                    ForEach(ThemePreference.allCases) { theme in
                        Text(theme.rawValue.capitalized).tag(theme)
                    }
                }
                .pickerStyle(.segmented)

                Toggle("Show previous performance inline", isOn: $settings.showInlinePerformance)
                Toggle("Haptics", isOn: $settings.hapticsEnabled)
            }
            .tint(SetraTheme.accent)
        }
    }

    private var actionCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Testing")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
                Text("Launch with the environment variable `SETRA_FORCE_ONBOARDING=1` or the argument `-force-onboarding` to always show onboarding during testing.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Button(action: finishOnboarding) {
                    Text(isSaving ? "Saving..." : "Enter Setra")
                }
                .buttonStyle(PrimaryActionButtonStyle())
                .disabled(isSaving)
            }
        }
    }

    private var exampleEntryCopy: String {
        switch settings.preferredBarbellEntryMode {
        case .shorthandPlatesPerSide:
            return "`1p` becomes bar + one top plate per side. `1p25` becomes bar + one top plate and one 25 per side."
        case .perSideLoad:
            return "Entering `45` means 45 on one side, plus the bar."
        case .totalLoadExcludingBar:
            return "Entering `90` means 90 of plates plus the bar."
        case .totalLoadIncludingBar:
            return "Entering `135` means the full barbell system weighs 135 total."
        }
    }

    private func finishOnboarding() {
        Task {
            isSaving = true
            settings.trainingGoals = selectedGoals.isEmpty ? [.hypertrophy] : Array(selectedGoals)
            await workspaceStore.completeOnboarding(
                for: user,
                settings: settings,
                displayName: displayName.isEmpty ? user.displayName : displayName
            )
            isSaving = false
        }
    }
}

private struct FlexibleTagSelector<Option: Identifiable & Hashable>: View {
    let options: [Option]
    @Binding var selected: Set<Option>
    var title: KeyPath<Option, String>

    var body: some View {
        HStack(spacing: 10) {
            ForEach(options) { option in
                Button(action: { toggle(option) }) {
                    Text(option[keyPath: title])
                        .font(.subheadline.weight(.semibold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(selected.contains(option) ? SetraTheme.accent.opacity(0.22) : Color.white.opacity(0.06))
                        )
                        .overlay(
                            Capsule()
                                .strokeBorder(selected.contains(option) ? SetraTheme.accent.opacity(0.45) : Color.white.opacity(0.08), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundStyle(.white)
    }

    private func toggle(_ option: Option) {
        if selected.contains(option) {
            selected.remove(option)
        } else {
            selected.insert(option)
        }
    }
}

struct OnboardingFlowView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingFlowView(user: PreviewEnvironment.user)
            .setraPreviewEnvironment(signedIn: true, onboarded: false)
    }
}
