import SwiftUI

enum SetraTheme {
    static let accent = Color(red: 0.36, green: 0.84, blue: 0.98)
    static let accentSecondary = Color(red: 0.55, green: 0.63, blue: 0.90)
    static let success = Color(red: 0.42, green: 0.84, blue: 0.60)
    static let warning = Color(red: 0.96, green: 0.74, blue: 0.33)
    static let graphite = Color(red: 0.08, green: 0.10, blue: 0.14)
    static let ink = Color(red: 0.03, green: 0.05, blue: 0.08)
    static let mist = Color(red: 0.93, green: 0.96, blue: 1.0)
    static let cardFill = Color.white.opacity(0.08)
    static let cardBorder = Color.white.opacity(0.10)

    static let accentGradient = LinearGradient(
        colors: [accent, accentSecondary],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let screenBackground = LinearGradient(
        colors: [
            Color(red: 0.03, green: 0.05, blue: 0.08),
            Color(red: 0.05, green: 0.08, blue: 0.12),
            Color(red: 0.03, green: 0.05, blue: 0.08)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let ambientGlow = RadialGradient(
        colors: [
            accent.opacity(0.22),
            accentSecondary.opacity(0.08),
            .clear
        ],
        center: .topTrailing,
        startRadius: 20,
        endRadius: 320
    )
}

struct GlassCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(20)
            .background(cardBackground)
            .shadow(color: .black.opacity(0.24), radius: 28, y: 18)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 28, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.10),
                        Color.white.opacity(0.05)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [Color.white.opacity(0.16), Color.white.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
    }
}

struct PrimaryActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 18)
            .padding(.vertical, 15)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(SetraTheme.accentGradient)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.14), lineWidth: 1)
                    )
                    .opacity(configuration.isPressed ? 0.88 : 1)
            )
            .shadow(color: SetraTheme.accent.opacity(0.28), radius: 20, y: 10)
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .animation(.smooth(duration: 0.18), value: configuration.isPressed)
    }
}

struct SecondaryActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.white.opacity(0.92))
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white.opacity(configuration.isPressed ? 0.14 : 0.09))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(SetraTheme.cardBorder, lineWidth: 1)
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
                .foregroundStyle(.secondary)
            Text(value)
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(accent.opacity(0.12))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(accent.opacity(0.18), lineWidth: 1)
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
                            Color.white.opacity(0.20),
                            Color.white.opacity(0.06)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)

            ZStack {
                RoundedRectangle(cornerRadius: size * 0.08, style: .continuous)
                    .fill(SetraTheme.accentGradient)
                    .frame(width: size * 0.56, height: size * 0.12)
                RoundedRectangle(cornerRadius: size * 0.08, style: .continuous)
                    .fill(Color.white.opacity(0.95))
                    .frame(width: size * 0.24, height: size * 0.12)
                    .offset(x: size * 0.08, y: size * 0.18)
            }
            .rotationEffect(.degrees(-22))
        }
        .frame(width: size, height: size)
        .shadow(color: SetraTheme.accent.opacity(0.22), radius: 20, y: 10)
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
                .foregroundStyle(.white)
            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
