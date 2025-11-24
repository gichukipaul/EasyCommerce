//
//  LoginView.swift
//  EasyCommerce
//
//  User login screen
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var userManager: UserManager
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showPassword: Bool = false
    @State private var showSignUp: Bool = false
    @FocusState private var focusedField: Field?

    enum Field {
        case email, password
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.xxl) {
                    // Logo & Welcome
                    VStack(spacing: AppTheme.Spacing.md) {
                        Image(systemName: "bag.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(AppTheme.Colors.primaryGradient)

                        Text("Welcome Back")
                            .font(AppTheme.Typography.title)
                            .foregroundColor(AppTheme.Colors.text)

                        Text("Sign in to continue shopping")
                            .font(AppTheme.Typography.subheadline)
                            .foregroundColor(AppTheme.Colors.secondaryText)
                    }
                    .padding(.top, AppTheme.Spacing.xxxl)

                    // Form
                    VStack(spacing: AppTheme.Spacing.lg) {
                        // Email Field
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                            Text("Email")
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(AppTheme.Colors.secondaryText)

                            HStack {
                                Image(systemName: "envelope")
                                    .foregroundColor(AppTheme.Colors.secondaryText)
                                TextField("Enter your email", text: $email)
                                    .textContentType(.emailAddress)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .focused($focusedField, equals: .email)
                            }
                            .padding(AppTheme.Spacing.md)
                            .background(AppTheme.Colors.secondaryBackground)
                            .cornerRadius(AppTheme.CornerRadius.medium)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                                    .stroke(focusedField == .email ? AppTheme.Colors.primaryFallback : Color.clear, lineWidth: 2)
                            )
                        }

                        // Password Field
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                            Text("Password")
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(AppTheme.Colors.secondaryText)

                            HStack {
                                Image(systemName: "lock")
                                    .foregroundColor(AppTheme.Colors.secondaryText)

                                if showPassword {
                                    TextField("Enter your password", text: $password)
                                        .focused($focusedField, equals: .password)
                                } else {
                                    SecureField("Enter your password", text: $password)
                                        .focused($focusedField, equals: .password)
                                }

                                Button {
                                    showPassword.toggle()
                                } label: {
                                    Image(systemName: showPassword ? "eye.slash" : "eye")
                                        .foregroundColor(AppTheme.Colors.secondaryText)
                                }
                            }
                            .padding(AppTheme.Spacing.md)
                            .background(AppTheme.Colors.secondaryBackground)
                            .cornerRadius(AppTheme.CornerRadius.medium)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                                    .stroke(focusedField == .password ? AppTheme.Colors.primaryFallback : Color.clear, lineWidth: 2)
                            )
                        }

                        // Forgot Password
                        HStack {
                            Spacer()
                            Button("Forgot Password?") {
                                // Handle forgot password
                            }
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.Colors.primaryFallback)
                        }
                    }
                    .padding(.horizontal, AppTheme.Spacing.lg)

                    // Error Message
                    if let error = userManager.error {
                        Text(error)
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.Colors.error)
                            .padding(.horizontal, AppTheme.Spacing.lg)
                    }

                    // Sign In Button
                    Button {
                        Task {
                            await userManager.signIn(email: email, password: password)
                        }
                    } label: {
                        HStack {
                            if userManager.isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Sign In")
                            }
                        }
                        .primaryButtonStyle()
                    }
                    .disabled(email.isEmpty || password.isEmpty || userManager.isLoading)
                    .padding(.horizontal, AppTheme.Spacing.lg)

                    // Divider
                    HStack {
                        Rectangle()
                            .fill(AppTheme.Colors.secondaryText.opacity(0.3))
                            .frame(height: 1)
                        Text("or")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.Colors.secondaryText)
                        Rectangle()
                            .fill(AppTheme.Colors.secondaryText.opacity(0.3))
                            .frame(height: 1)
                    }
                    .padding(.horizontal, AppTheme.Spacing.lg)

                    // Social Login
                    VStack(spacing: AppTheme.Spacing.md) {
                        SocialLoginButton(provider: .apple)
                        SocialLoginButton(provider: .google)
                    }
                    .padding(.horizontal, AppTheme.Spacing.lg)

                    Spacer(minLength: AppTheme.Spacing.xxl)

                    // Sign Up Link
                    HStack(spacing: AppTheme.Spacing.xs) {
                        Text("Don't have an account?")
                            .font(AppTheme.Typography.subheadline)
                            .foregroundColor(AppTheme.Colors.secondaryText)

                        Button("Sign Up") {
                            showSignUp = true
                        }
                        .font(AppTheme.Typography.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(AppTheme.Colors.primaryFallback)
                    }
                    .padding(.bottom, AppTheme.Spacing.xxl)
                }
            }
            .background(AppTheme.Colors.background)
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showSignUp) {
                SignUpView()
                    .environmentObject(userManager)
            }
        }
    }
}

// MARK: - Social Login Button

enum SocialProvider {
    case apple, google

    var title: String {
        switch self {
        case .apple: return "Continue with Apple"
        case .google: return "Continue with Google"
        }
    }

    var icon: String {
        switch self {
        case .apple: return "apple.logo"
        case .google: return "globe"
        }
    }
}

struct SocialLoginButton: View {
    let provider: SocialProvider

    var body: some View {
        Button {
            // Handle social login
        } label: {
            HStack(spacing: AppTheme.Spacing.md) {
                Image(systemName: provider.icon)
                    .font(.system(size: 18))
                Text(provider.title)
                    .font(AppTheme.Typography.subheadline)
                    .fontWeight(.medium)
            }
            .foregroundColor(AppTheme.Colors.text)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.md)
            .background(AppTheme.Colors.secondaryBackground)
            .cornerRadius(AppTheme.CornerRadius.medium)
        }
    }
}

// MARK: - Preview

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(UserManager.shared)
    }
}
