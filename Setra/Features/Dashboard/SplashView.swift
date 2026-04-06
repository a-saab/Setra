import SwiftUI

struct SplashView: View {
    var subtitle: String = "Premium workout planning and logging"

    var body: some View {
        VStack(spacing: 20) {
            BrandMark(size: 96)
            VStack(spacing: 8) {
                Text("Setra")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(SetraTheme.screenBackground.ignoresSafeArea())
    }
}
