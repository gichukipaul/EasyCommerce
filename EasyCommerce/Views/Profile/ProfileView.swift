//
//  ProfileView.swift
//  EasyCommerce
//
//  User profile and settings view
//

import SwiftUI

struct ProfileView: View {
    @State private var showCurrencyPicker: Bool = false
    @ObservedObject private var currencyFormatter = CurrencyFormatter.shared

    var body: some View {
        NavigationStack {
            List {
                // User Section
                Section {
                    HStack(spacing: AppTheme.Spacing.lg) {
                        // Avatar
                        ZStack {
                            Circle()
                                .fill(AppTheme.Colors.primaryGradient)
                                .frame(width: 60, height: 60)

                            Image(systemName: "person.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                        }

                        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                            Text("Guest User")
                                .font(AppTheme.Typography.headline)
                                .foregroundColor(AppTheme.Colors.text)

                            Text("Sign in for personalized experience")
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(AppTheme.Colors.secondaryText)
                        }
                    }
                    .padding(.vertical, AppTheme.Spacing.sm)
                }

                // Orders Section
                Section("Orders") {
                    ProfileRow(icon: "shippingbox", title: "My Orders", subtitle: "View order history")
                    ProfileRow(icon: "heart", title: "Wishlist", subtitle: "Your saved items")
                    ProfileRow(icon: "clock.arrow.circlepath", title: "Recently Viewed", subtitle: "Products you viewed")
                }

                // Settings Section
                Section("Settings") {
                    Button {
                        showCurrencyPicker = true
                    } label: {
                        HStack {
                            ProfileRowContent(
                                icon: "dollarsign.circle",
                                title: "Currency",
                                subtitle: currencyFormatter.currentCurrencyCode
                            )

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppTheme.Colors.tertiaryText)
                        }
                    }

                    ProfileRow(icon: "globe", title: "Language", subtitle: "English")
                    ProfileRow(icon: "bell", title: "Notifications", subtitle: "Manage alerts")
                    ProfileRow(icon: "moon", title: "Appearance", subtitle: "System")
                }

                // Support Section
                Section("Support") {
                    ProfileRow(icon: "questionmark.circle", title: "Help Center", subtitle: "FAQs & support")
                    ProfileRow(icon: "envelope", title: "Contact Us", subtitle: "Get in touch")
                    ProfileRow(icon: "doc.text", title: "Terms of Service", subtitle: "Legal information")
                    ProfileRow(icon: "hand.raised", title: "Privacy Policy", subtitle: "Your data")
                }

                // App Info Section
                Section {
                    HStack {
                        Text("Version")
                            .font(AppTheme.Typography.subheadline)
                            .foregroundColor(AppTheme.Colors.text)

                        Spacer()

                        Text("1.0.0")
                            .font(AppTheme.Typography.subheadline)
                            .foregroundColor(AppTheme.Colors.secondaryText)
                    }
                }

                // Sign In Button
                Section {
                    Button {
                        // Handle sign in
                    } label: {
                        HStack {
                            Spacer()
                            Text("Sign In")
                                .font(AppTheme.Typography.headline)
                                .foregroundColor(AppTheme.Colors.primaryFallback)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle(LocalizedString.profile)
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showCurrencyPicker) {
                CurrencyPicker(isPresented: $showCurrencyPicker)
            }
        }
    }
}

// MARK: - Profile Row

struct ProfileRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        NavigationLink {
            Text(title)
                .navigationTitle(title)
        } label: {
            ProfileRowContent(icon: icon, title: title, subtitle: subtitle)
        }
    }
}

struct ProfileRowContent: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(AppTheme.Colors.primaryFallback)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
                Text(title)
                    .font(AppTheme.Typography.subheadline)
                    .foregroundColor(AppTheme.Colors.text)

                Text(subtitle)
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.Colors.secondaryText)
            }
        }
    }
}

// MARK: - Preview

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
