//
//  ProfileView.swift
//  EasyCommerce
//
//  User profile and settings view
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var orderManager: OrderManager
    @EnvironmentObject var wishlistManager: WishlistManager
    @EnvironmentObject var recentlyViewedManager: RecentlyViewedManager
    @EnvironmentObject var cartManager: CartManager

    @State private var showCurrencyPicker: Bool = false
    @State private var showLogin: Bool = false
    @ObservedObject private var currencyFormatter = CurrencyFormatter.shared

    var body: some View {
        NavigationView {
            List {
                // User Section
                userSection

                // Orders Section
                ordersSection

                // Shopping Section
                shoppingSection

                // Settings Section
                settingsSection

                // Support Section
                supportSection

                // App Info Section
                appInfoSection

                // Auth Button
                authSection
            }
            .navigationTitle(LocalizedString.profile)
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showCurrencyPicker) {
                CurrencyPicker(isPresented: $showCurrencyPicker)
            }
            .sheet(isPresented: $showLogin) {
                LoginView()
                    .environmentObject(userManager)
            }
        }
    }

    // MARK: - User Section

    private var userSection: some View {
        Section {
            if let user = userManager.currentUser {
                HStack(spacing: AppTheme.Spacing.lg) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.Colors.primaryGradient)
                            .frame(width: 60, height: 60)

                        Text(user.initials)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    }

                    VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                        Text(user.fullName.isEmpty ? "User" : user.fullName)
                            .font(AppTheme.Typography.headline)
                            .foregroundColor(AppTheme.Colors.text)

                        Text(user.email)
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.Colors.secondaryText)
                    }
                }
                .padding(.vertical, AppTheme.Spacing.sm)
            } else {
                Button {
                    showLogin = true
                } label: {
                    HStack(spacing: AppTheme.Spacing.lg) {
                        ZStack {
                            Circle()
                                .fill(AppTheme.Colors.secondaryBackground)
                                .frame(width: 60, height: 60)

                            Image(systemName: "person.fill")
                                .font(.system(size: 24))
                                .foregroundColor(AppTheme.Colors.secondaryText)
                        }

                        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                            Text("Sign In")
                                .font(AppTheme.Typography.headline)
                                .foregroundColor(AppTheme.Colors.text)

                            Text("Sign in for personalized experience")
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(AppTheme.Colors.secondaryText)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundColor(AppTheme.Colors.tertiaryText)
                    }
                }
                .padding(.vertical, AppTheme.Spacing.sm)
            }
        }
    }

    // MARK: - Orders Section

    private var ordersSection: some View {
        Section("Orders") {
            NavigationLink {
                OrderHistoryView()
            } label: {
                ProfileRowContent(
                    icon: "shippingbox",
                    title: "My Orders",
                    subtitle: "\(orderManager.orders.count) orders"
                )
            }

            if !orderManager.activeOrders.isEmpty {
                NavigationLink {
                    OrderHistoryView()
                } label: {
                    ProfileRowContent(
                        icon: "clock",
                        title: "Track Orders",
                        subtitle: "\(orderManager.activeOrders.count) active"
                    )
                }
            }
        }
    }

    // MARK: - Shopping Section

    private var shoppingSection: some View {
        Section("Shopping") {
            NavigationLink {
                WishlistView()
            } label: {
                ProfileRowContent(
                    icon: "heart",
                    title: "Wishlist",
                    subtitle: "\(wishlistManager.count) items"
                )
            }

            NavigationLink {
                RecentlyViewedView()
            } label: {
                ProfileRowContent(
                    icon: "clock.arrow.circlepath",
                    title: "Recently Viewed",
                    subtitle: "\(recentlyViewedManager.items.count) items"
                )
            }
        }
    }

    // MARK: - Settings Section

    private var settingsSection: some View {
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

            NavigationLink {
                Text("Language Settings")
                    .navigationTitle("Language")
            } label: {
                ProfileRowContent(icon: "globe", title: "Language", subtitle: "English")
            }

            NavigationLink {
                Text("Notification Settings")
                    .navigationTitle("Notifications")
            } label: {
                ProfileRowContent(icon: "bell", title: "Notifications", subtitle: "Manage alerts")
            }
        }
    }

    // MARK: - Support Section

    private var supportSection: some View {
        Section("Support") {
            NavigationLink {
                Text("Help Center")
                    .navigationTitle("Help")
            } label: {
                ProfileRowContent(icon: "questionmark.circle", title: "Help Center", subtitle: "FAQs & support")
            }

            NavigationLink {
                Text("Contact Us")
                    .navigationTitle("Contact")
            } label: {
                ProfileRowContent(icon: "envelope", title: "Contact Us", subtitle: "Get in touch")
            }
        }
    }

    // MARK: - App Info Section

    private var appInfoSection: some View {
        Section {
            HStack {
                Text("Version")
                    .font(AppTheme.Typography.subheadline)
                    .foregroundColor(AppTheme.Colors.text)

                Spacer()

                Text("2.0.0")
                    .font(AppTheme.Typography.subheadline)
                    .foregroundColor(AppTheme.Colors.secondaryText)
            }
        }
    }

    // MARK: - Auth Section

    private var authSection: some View {
        Section {
            if userManager.isAuthenticated {
                Button {
                    userManager.signOut()
                } label: {
                    HStack {
                        Spacer()
                        Text("Sign Out")
                            .font(AppTheme.Typography.headline)
                            .foregroundColor(AppTheme.Colors.error)
                        Spacer()
                    }
                }
            } else {
                Button {
                    showLogin = true
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
    }
}

// MARK: - Profile Row Content

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

// MARK: - Recently Viewed View

struct RecentlyViewedView: View {
    @EnvironmentObject var recentlyViewedManager: RecentlyViewedManager
    @EnvironmentObject var cartManager: CartManager
    @EnvironmentObject var wishlistManager: WishlistManager

    private let columns = [
        GridItem(.flexible(), spacing: AppTheme.Spacing.md),
        GridItem(.flexible(), spacing: AppTheme.Spacing.md)
    ]

    var body: some View {
        Group {
            if recentlyViewedManager.items.isEmpty {
                VStack(spacing: AppTheme.Spacing.xl) {
                    Spacer()
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 60))
                        .foregroundColor(AppTheme.Colors.tertiaryText)
                    Text("No recently viewed items")
                        .font(AppTheme.Typography.title3)
                        .foregroundColor(AppTheme.Colors.secondaryText)
                    Spacer()
                }
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: AppTheme.Spacing.lg) {
                        ForEach(recentlyViewedManager.items, id: \.id) { product in
                            NavigationLink {
                                ProductDetailView(product: product)
                            } label: {
                                ProductCard(
                                    product: product,
                                    onAddToCart: { cartManager.addToCart(product) },
                                    onFavorite: { wishlistManager.toggle(product) }
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(AppTheme.Spacing.lg)
                }
            }
        }
        .background(AppTheme.Colors.background)
        .navigationTitle("Recently Viewed")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            if !recentlyViewedManager.items.isEmpty {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Clear") {
                        recentlyViewedManager.clear()
                    }
                    .foregroundColor(AppTheme.Colors.primaryFallback)
                }
            }
        }
    }
}

// MARK: - Preview

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(UserManager.shared)
            .environmentObject(OrderManager.shared)
            .environmentObject(WishlistManager.shared)
            .environmentObject(RecentlyViewedManager.shared)
            .environmentObject(CartManager.shared)
    }
}
