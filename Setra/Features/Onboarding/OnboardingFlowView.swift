import SwiftUI

struct OnboardingFlowView: View {
    let user: AuthUser

    @EnvironmentObject private var workspaceStore: WorkspaceStore

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
            VStack(spacing: 20) {
                Spacer(minLength: 24)
                BrandMark(size: 82)
                VStack(spacing: 8) {
                    Text("Build Your System")
                        .font(.largeTitle.weight(.bold))
                        .foregroundStyle(.white)
                    Text("Setra uses these choices to tune defaults, progression, and the logging flow.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 22)

                GlassCard {
                    VStack(alignment: .leading, spacing: 18) {
                        SectionHeader("Identity", subtitle: "Simple, quick, and editable later")
                        TextField("Display Name", text: $displayName)
                            .authField()

                        SectionHeader("Units")
                        Picker("Weight Unit", selection: $settings.weightUnit) {
                            ForEach(WeightUnit.allCases) { unit in
                                Text(unit.displayName).tag(unit)
                            }
                        }
                        .pickerStyle(.segmented)

                        SectionHeader("Training Goal")
                        FlexibleTagSelector(
                            options: TrainingGoal.allCases,
                            selected: $selectedGoals,
                            title: \.title
                        )

                        SectionHeader("Gym Setup")
                        Picker("Equipment Level", selection: $settings.gymEquipmentLevel) {
                            ForEach(GymEquipmentLevel.allCases) { item in
                                Text(item.title).tag(item)
                            }
                        }
                        .pickerStyle(.segmented)

                        SectionHeader("Theme")
                        Picker("Theme", selection: $settings.themePreference) {
                            ForEach(ThemePreference.allCases) { theme in
                                Text(theme.rawValue.capitalized).tag(theme)
                            }
                        }
                        .pickerStyle(.segmented)

                        Button {
                            Task {
                                isSaving = true
                                settings.trainingGoals = Array(selectedGoals)
                                settings.defaultBarbellWeight = settings.weightUnit == .pounds ? 45 : 20
                                settings.upperBodyIncrement = settings.weightUnit == .pounds ? 5 : 2.5
                                settings.lowerBodyIncrement = settings.weightUnit == .pounds ? 10 : 5
                                await workspaceStore.completeOnboarding(
                                    for: user,
                                    settings: settings,
                                    displayName: displayName.isEmpty ? user.displayName : displayName
                                )
                                isSaving = false
                            }
                        } label: {
                            Text(isSaving ? "Finishing..." : "Enter Setra")
                        }
                        .buttonStyle(PrimaryActionButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
                Spacer(minLength: 20)
            }
            .padding(.bottom, 24)
        }
        .background(SetraTheme.screenBackground.ignoresSafeArea())
    }
}

private struct FlexibleTagSelector<Option: Identifiable & Hashable>: View {
    let options: [Option]
    @Binding var selected: Set<Option>
    var title: KeyPath<Option, String>

    var body: some View {
        HStack(spacing: 10) {
            ForEach(options) { option in
                Button {
                    if selected.contains(option) {
                        selected.remove(option)
                    } else {
                        selected.insert(option)
                    }
                } label: {
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
                                .strokeBorder(selected.contains(option) ? SetraTheme.accent.opacity(0.6) : Color.white.opacity(0.08), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundStyle(.white)
    }
}

struct OnboardingFlowView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingFlowView(user: PreviewEnvironment.user)
            .setraPreviewEnvironment(signedIn: true, onboarded: false)
    }
}
