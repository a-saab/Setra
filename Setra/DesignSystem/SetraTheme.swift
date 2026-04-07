import SwiftUI

enum SetraTheme {
    static let accent = Color(red: 0.19, green: 0.50, blue: 0.96)
    static let accentSecondary = Color(red: 0.45, green: 0.68, blue: 0.97)
    static let success = Color(red: 0.19, green: 0.69, blue: 0.51)
    static let warning = Color(red: 0.86, green: 0.59, blue: 0.18)

    static let screenBackground = LinearGradient(
        colors: [canvasTop, canvasBase, canvasBottom],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let ambientGlow = RadialGradient(
        colors: [
            accent.opacity(0.16),
            accentSecondary.opacity(0.06),
            .clear,
        ],
        center: .topTrailing,
        startRadius: 20,
        endRadius: 320
    )

    static let accentGradient = LinearGradient(
        colors: [accent, accentSecondary],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let surface = Color(red: 0.09, green: 0.12, blue: 0.17)
    static let surfaceSecondary = Color(red: 0.11, green: 0.15, blue: 0.21)
    static let surfaceTertiary = Color(red: 0.14, green: 0.19, blue: 0.26)
    static let panelBorder = Color.white.opacity(0.08)
    static let divider = Color.white.opacity(0.08)
    static let mutedFill = Color.white.opacity(0.06)

    static let primaryText = Color.white
    static let secondaryText = Color.white.opacity(0.68)

    private static let canvasTop = Color(red: 0.05, green: 0.07, blue: 0.10)
    private static let canvasBase = Color(red: 0.06, green: 0.09, blue: 0.13)
    private static let canvasBottom = Color(red: 0.08, green: 0.11, blue: 0.16)
}

struct GlassCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(22)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(cardBackground)
            .shadow(
                color: Color.black.opacity(0.14),
                radius: 28,
                x: 0,
                y: 14
            )
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 28, style: .continuous)
            .fill(SetraTheme.surface.opacity(0.92))
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(.ultraThinMaterial.opacity(0.16))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .strokeBorder(SetraTheme.panelBorder.opacity(0.95), lineWidth: 1)
            )
    }
}

struct PrimaryActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(SetraTheme.accentGradient)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                    )
                    .opacity(configuration.isPressed ? 0.92 : 1)
            )
            .shadow(color: SetraTheme.accent.opacity(0.26), radius: 16, y: 10)
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .animation(.smooth(duration: 0.18), value: configuration.isPressed)
    }
}

struct SecondaryActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(SetraTheme.primaryText)
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(SetraTheme.mutedFill.opacity(configuration.isPressed ? 0.84 : 1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(SetraTheme.panelBorder, lineWidth: 1)
            )
    }
}

struct StatChip: View {
    let label: String
    let value: String
    var accent: Color = SetraTheme.accent

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label.uppercased())
                .font(.caption2.weight(.semibold))
                .foregroundStyle(SetraTheme.secondaryText)
            Text(value)
                .font(.headline.weight(.semibold))
                .foregroundStyle(SetraTheme.primaryText)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(accent.opacity(0.10))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(accent.opacity(0.22), lineWidth: 1)
        )
    }
}

struct BrandMark: View {
    var size: CGFloat = 64

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            SetraTheme.surfaceSecondary,
                            SetraTheme.surface,
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                .strokeBorder(SetraTheme.panelBorder, lineWidth: 1)

            ZStack {
                RoundedRectangle(cornerRadius: size * 0.08, style: .continuous)
                    .fill(SetraTheme.accentGradient)
                    .frame(width: size * 0.56, height: size * 0.12)
                RoundedRectangle(cornerRadius: size * 0.08, style: .continuous)
                    .fill(.white.opacity(0.96))
                    .frame(width: size * 0.24, height: size * 0.12)
                    .offset(x: size * 0.08, y: size * 0.18)
            }
            .rotationEffect(.degrees(-22))
        }
        .frame(width: size, height: size)
        .shadow(color: SetraTheme.accent.opacity(0.18), radius: 18, y: 8)
    }
}

struct SectionHeader: View {
    let title: String
    let subtitle: String?

    init(_ title: String, subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.title3.weight(.semibold))
                .foregroundStyle(SetraTheme.primaryText)
            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(SetraTheme.secondaryText)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
