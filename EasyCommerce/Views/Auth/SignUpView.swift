//
//  SignUpView.swift
//  EasyCommerce
//
//  User registration screen
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var userManager: UserManager
    @Environment(\.dismiss) private var dismiss

    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var agreeToTerms: Bool = false
    @State private var showPassword: Bool = false
    @FocusState private var focusedField: Field?

    enum Field {
        case firstName, lastName, email, password, confirmPassword
    }

    var isFormValid: Bool {
        !firstName.isEmpty &&
        !email.isEmpty &&
        !password.isEmpty &&
        password == confirmPassword &&
        password.count >= 6 &&
        agreeToTerms
    }

    var passwordsMatch: Bool {
        password == confirmPassword || confirmPassword.isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.xl) {
                    // Header
                    VStack(spacing: AppTheme.Spacing.sm) {
                        Text("Create Account")
                            .font(AppTheme.Typography.title)
                            .foregroundColor(AppTheme.Colors.text)

                        Text("Join EasyCommerce today")
                            .font(AppTheme.Typography.subheadline)
                            .foregroundColor(AppTheme.Colors.secondaryText)
                    }
                    .padding(.top, AppTheme.Spacing.xl)

                    // Form
                    VStack(spacing: AppTheme.Spacing.lg) {
                        // Name Row
                        HStack(spacing: AppTheme.Spacing.md) {
                            FormTextField(
                                title: "First Name",
                                placeholder: "John",
                                text: $firstName,
                                icon: "person",
                                isFocused: focusedField == .firstName
                            )
                            .focused($focusedField, equals: .firstName)

                            FormTextField(
                                title: "Last Name",
                                placeholder: "Doe",
                                text: $lastName,
                                icon: "person",
                                isFocused: focusedField == .lastName
                            )
                            .focused($focusedField, equals: .lastName)
                        }

                        // Email
                        FormTextField(
                            title: "Email",
                            placeholder: "john@example.com",
                            text: $email,
                            icon: "envelope",
                            keyboardType: .emailAddress,
                            isFocused: focusedField == .email
                        )
                        .focused($focusedField, equals: .email)

                        // Password
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                            Text("Password")
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(AppTheme.Colors.secondaryText)

                            HStack {
                                Image(systemName: "lock")
                                    .foregroundColor(AppTheme.Colors.secondaryText)

                                if showPassword {
                                    TextField("Min 6 characters", text: $password)
                                        .focused($focusedField, equals: .password)
                                } else {
                                    SecureField("Min 6 characters", text: $password)
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

                            // Password strength indicator
                            if !password.isEmpty {
                                PasswordStrengthView(password: password)
                            }
                        }

                        // Confirm Password
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                            Text("Confirm Password")
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(AppTheme.Colors.secondaryText)

                            HStack {
                                Image(systemName: "lock")
                                    .foregroundColor(AppTheme.Colors.secondaryText)

                                SecureField("Re-enter password", text: $confirmPassword)
                                    .focused($focusedField, equals: .confirmPassword)

                                if !confirmPassword.isEmpty {
                                    Image(systemName: passwordsMatch ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .foregroundColor(passwordsMatch ? AppTheme.Colors.success : AppTheme.Colors.error)
                                }
                            }
                            .padding(AppTheme.Spacing.md)
                            .background(AppTheme.Colors.secondaryBackground)
                            .cornerRadius(AppTheme.CornerRadius.medium)

                            if !passwordsMatch {
                                Text("Passwords don't match")
                                    .font(AppTheme.Typography.caption)
                                    .foregroundColor(AppTheme.Colors.error)
                            }
                        }

                        // Terms Agreement
                        HStack(alignment: .top, spacing: AppTheme.Spacing.sm) {
                            Button {
                                agreeToTerms.toggle()
                            } label: {
                                Image(systemName: agreeToTerms ? "checkmark.square.fill" : "square")
                                    .foregroundColor(agreeToTerms ? AppTheme.Colors.primaryFallback : AppTheme.Colors.secondaryText)
                                    .font(.system(size: 22))
                            }

                            Text("I agree to the [Terms of Service](terms) and [Privacy Policy](privacy)")
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(AppTheme.Colors.secondaryText)
                                .tint(AppTheme.Colors.primaryFallback)
                        }
                    }
                    .padding(.horizontal, AppTheme.Spacing.lg)

                    // Sign Up Button
                    Button {
                        Task {
                            await userManager.signUp(
                                email: email,
                                password: password,
                                firstName: firstName,
                                lastName: lastName
                            )
                            dismiss()
                        }
                    } label: {
                        HStack {
                            if userManager.isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Create Account")
                            }
                        }
                        .primaryButtonStyle()
                    }
                    .disabled(!isFormValid || userManager.isLoading)
                    .padding(.horizontal, AppTheme.Spacing.lg)

                    Spacer(minLength: AppTheme.Spacing.xxl)
                }
            }
            .background(AppTheme.Colors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(AppTheme.Colors.text)
                    }
                }
            }
        }
    }
}

// MARK: - Form Text Field

struct FormTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let icon: String
    var keyboardType: UIKeyboardType = .default
    var isFocused: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            Text(title)
                .font(AppTheme.Typography.caption)
                .foregroundColor(AppTheme.Colors.secondaryText)

            HStack {
                Image(systemName: icon)
                    .foregroundColor(AppTheme.Colors.secondaryText)

                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .autocapitalization(keyboardType == .emailAddress ? .none : .words)
            }
            .padding(AppTheme.Spacing.md)
            .background(AppTheme.Colors.secondaryBackground)
            .cornerRadius(AppTheme.CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                    .stroke(isFocused ? AppTheme.Colors.primaryFallback : Color.clear, lineWidth: 2)
            )
        }
    }
}

// MARK: - Password Strength View

struct PasswordStrengthView: View {
    let password: String

    var strength: (level: Int, text: String, color: Color) {
        var score = 0
        if password.count >= 6 { score += 1 }
        if password.count >= 8 { score += 1 }
        if password.contains(where: { $0.isUppercase }) { score += 1 }
        if password.contains(where: { $0.isNumber }) { score += 1 }
        if password.contains(where: { "!@#$%^&*()_+-=[]{}|;:,.<>?".contains($0) }) { score += 1 }

        switch score {
        case 0...1: return (1, "Weak", AppTheme.Colors.error)
        case 2...3: return (2, "Medium", AppTheme.Colors.warning)
        default: return (3, "Strong", AppTheme.Colors.success)
        }
    }

    var body: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            ForEach(1...3, id: \.self) { level in
                RoundedRectangle(cornerRadius: 2)
                    .fill(level <= strength.level ? strength.color : AppTheme.Colors.secondaryBackground)
                    .frame(height: 4)
            }

            Text(strength.text)
                .font(AppTheme.Typography.caption2)
                .foregroundColor(strength.color)
        }
    }
}

// MARK: - Preview

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
            .environmentObject(UserManager.shared)
    }
}
