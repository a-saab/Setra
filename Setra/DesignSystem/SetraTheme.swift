import SwiftUI

enum SetraTheme {
    static let accent = Color(red: 0.22, green: 0.72, blue: 0.98)
    static let accentSecondary = Color(red: 0.46, green: 0.52, blue: 0.86)
    static let success = Color(red: 0.27, green: 0.82, blue: 0.53)
    static let warning = Color(red: 0.95, green: 0.72, blue: 0.28)
    static let card = Color.white.opacity(0.08)
    static let darkBackground = Color(red: 0.04, green: 0.05, blue: 0.08)
    static let lightBackground = Color(red: 0.95, green: 0.97, blue: 1.0)
    static let graphite = Color(red: 0.11, green: 0.12, blue: 0.16)

    static let accentGradient = LinearGradient(
        colors: [accent, accentSecondary],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let screenBackground = LinearGradient(
        colors: [
            Color(red: 0.03, green: 0.04, blue: 0.07),
            Color(red: 0.07, green: 0.08, blue: 0.12),
            Color(red: 0.03, green: 0.04, blue: 0.07)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

struct GlassCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.10), lineWidth: 1)
                    )
            )
            .shadow(color: .black.opacity(0.24), radius: 30, y: 18)
    }
}

struct PrimaryActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(SetraTheme.accentGradient)
                    .opacity(configuration.isPressed ? 0.85 : 1)
            )
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .animation(.smooth(duration: 0.18), value: configuration.isPressed)
    }
}

struct SecondaryActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.white.opacity(0.9))
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white.opacity(configuration.isPressed ? 0.12 : 0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.10), lineWidth: 1)
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
                .fill(accent.opacity(0.14))
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
            RoundedRectangle(cornerRadius: size * 0.26, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.18),
                            Color.white.opacity(0.06)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            RoundedRectangle(cornerRadius: size * 0.24, style: .continuous)
                .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)

            VStack(spacing: size * 0.05) {
                RoundedRectangle(cornerRadius: size * 0.07, style: .continuous)
                    .fill(SetraTheme.accentGradient)
                    .frame(width: size * 0.56, height: size * 0.12)
                RoundedRectangle(cornerRadius: size * 0.07, style: .continuous)
                    .fill(Color.white.opacity(0.92))
                    .frame(width: size * 0.32, height: size * 0.12)
                    .overlay {
                        RoundedRectangle(cornerRadius: size * 0.07, style: .continuous)
                            .strokeBorder(SetraTheme.graphite.opacity(0.08), lineWidth: 1)
                    }
            }
            .rotationEffect(.degrees(-22))
        }
        .frame(width: size, height: size)
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
