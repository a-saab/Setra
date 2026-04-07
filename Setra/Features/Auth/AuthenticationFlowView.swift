import SwiftUI

struct AuthenticationFlowView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Spacer(minLength: 36)

                    VStack(spacing: 18) {
                        BrandMark(size: 90)
                        Text("Setra")
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text("A premium workout planner and logging system built for real sessions, not just pretty plans.")
                            .font(.title3)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 24)

                    GlassCard {
                        VStack(spacing: 16) {
                            NavigationLink {
                                SignUpView()
                            } label: {
                                Text("Create Account")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(PrimaryActionButtonStyle())

                            NavigationLink {
                                LoginView()
                            } label: {
                                Text("Log In")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(SecondaryActionButtonStyle())

                            GoogleSignInButton()
                        }
                    }
                    .padding(.horizontal, 20)

                    GlassCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Label("Fast workout logging", systemImage: "timer")
                            Label("Transparent progression suggestions", systemImage: "arrow.up.right")
                            Label("Offline-friendly schedule and history", systemImage: "icloud.slash")
                        }
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white.opacity(0.88))
                    }
                    .padding(.horizontal, 20)

                    Text("Firebase auth activates automatically when `GoogleService-Info.plist` is present. Until then, local development auth keeps the app fully runnable.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)

                    Spacer(minLength: 20)
                }
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)
            .background(SetraTheme.screenBackground.ignoresSafeArea())
        }
    }
}

private struct GoogleSignInButton: View {
    @Environment(AuthController.self) private var authController

    var body: some View {
        Button {
            Task {
                _ = await authController.signInWithGoogle()
            }
        } label: {
            Label("Continue With Google", systemImage: "g.circle.fill")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(SecondaryActionButtonStyle())
    }
}

struct LoginView: View {
    @Environment(AuthController.self) private var authController
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false

    var body: some View {
        AuthScaffold(
            title: "Welcome Back",
            subtitle: "Sign in and pick up exactly where you left off."
        ) {
            TextField("Email", text: $email)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .autocorrectionDisabled()
                .authField()

            SecureField("Password", text: $password)
                .authField()

            if let message = authController.errorMessage {
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Button {
                Task {
                    isLoading = true
                    _ = await authController.signIn(email: email, password: password)
                    isLoading = false
                }
            } label: {
                Text(isLoading ? "Signing In..." : "Sign In")
            }
            .buttonStyle(PrimaryActionButtonStyle())

            NavigationLink("Forgot your password?") {
                ForgotPasswordView(initialEmail: email)
            }
            .font(.footnote.weight(.semibold))
            .foregroundStyle(SetraTheme.accent)
        }
    }
}

struct SignUpView: View {
    @Environment(AuthController.self) private var authController
    @State private var displayName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false

    var body: some View {
        AuthScaffold(
            title: "Create Your Setra Account",
            subtitle: "Use email, password, or add Google now and Apple later."
        ) {
            TextField("Display Name", text: $displayName)
                .authField()
            TextField("Email", text: $email)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .autocorrectionDisabled()
                .authField()
            SecureField("Password", text: $password)
                .authField()

            if let message = authController.errorMessage {
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Button {
                Task {
                    isLoading = true
                    _ = await authController.signUp(email: email, password: password, displayName: displayName)
                    isLoading = false
                }
            } label: {
                Text(isLoading ? "Creating..." : "Create Account")
            }
            .buttonStyle(PrimaryActionButtonStyle())
        }
    }
}

struct ForgotPasswordView: View {
    @Environment(AuthController.self) private var authController
    @State private var email: String

    init(initialEmail: String = "") {
        _email = State(initialValue: initialEmail)
    }

    var body: some View {
        AuthScaffold(
            title: "Reset Password",
            subtitle: "We’ll send you a reset link if the account exists."
        ) {
            TextField("Email", text: $email)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .autocorrectionDisabled()
                .authField()

            Button("Send Reset Link") {
                Task {
                    _ = await authController.sendPasswordReset(email: email)
                }
            }
            .buttonStyle(PrimaryActionButtonStyle())

            if let message = authController.errorMessage {
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

private struct AuthScaffold<Content: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder var content: Content

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                Spacer(minLength: 20)
                BrandMark(size: 72)
                VStack(spacing: 8) {
                    Text(title)
                        .font(.largeTitle.weight(.bold))
                        .foregroundStyle(.white)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 20)

                GlassCard {
                    VStack(spacing: 14) {
                        content
                    }
                }
                .padding(.horizontal, 20)

                Spacer(minLength: 12)
            }
            .padding(.bottom, 20)
        }
        .scrollIndicators(.hidden)
        .background(SetraTheme.screenBackground.ignoresSafeArea())
    }
}

extension View {
    func authField() -> some View {
        self
            .textFieldStyle(.plain)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(SetraTheme.mutedFill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(SetraTheme.panelBorder, lineWidth: 1)
            )
            .foregroundStyle(SetraTheme.primaryText)
    }
}

struct AuthenticationFlowView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationFlowView()
            .setraPreviewEnvironment(signedIn: false)
    }
}
