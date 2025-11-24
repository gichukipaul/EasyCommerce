//
//  MainTabView.swift
//  EasyCommerce
//
//  Main tab bar navigation
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var cartManager = CartManager.shared
    @State private var selectedTab: Tab = .home

    enum Tab: String, CaseIterable {
        case home
        case categories
        case cart
        case profile

        var title: String {
            switch self {
            case .home: return LocalizedString.home
            case .categories: return LocalizedString.categories
            case .cart: return LocalizedString.cart
            case .profile: return LocalizedString.profile
            }
        }

        var icon: String {
            switch self {
            case .home: return "house"
            case .categories: return "square.grid.2x2"
            case .cart: return "cart"
            case .profile: return "person"
            }
        }

        var selectedIcon: String {
            switch self {
            case .home: return "house.fill"
            case .categories: return "square.grid.2x2.fill"
            case .cart: return "cart.fill"
            case .profile: return "person.fill"
            }
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .environmentObject(cartManager)
                .tabItem {
                    Label(Tab.home.title, systemImage: selectedTab == .home ? Tab.home.selectedIcon : Tab.home.icon)
                }
                .tag(Tab.home)

            CategoriesView()
                .environmentObject(cartManager)
                .tabItem {
                    Label(Tab.categories.title, systemImage: selectedTab == .categories ? Tab.categories.selectedIcon : Tab.categories.icon)
                }
                .tag(Tab.categories)

            CartView()
                .environmentObject(cartManager)
                .tabItem {
                    Label(Tab.cart.title, systemImage: selectedTab == .cart ? Tab.cart.selectedIcon : Tab.cart.icon)
                }
                .tag(Tab.cart)
                .badge(cartManager.itemCount > 0 ? cartManager.itemCount : 0)

            ProfileView()
                .tabItem {
                    Label(Tab.profile.title, systemImage: selectedTab == .profile ? Tab.profile.selectedIcon : Tab.profile.icon)
                }
                .tag(Tab.profile)
        }
        .tint(AppTheme.Colors.primaryFallback)
    }
}

// MARK: - Custom Tab Bar (Alternative)

struct CustomTabBar: View {
    @Binding var selectedTab: MainTabView.Tab
    let cartCount: Int

    var body: some View {
        HStack {
            ForEach(MainTabView.Tab.allCases, id: \.self) { tab in
                Spacer()

                TabBarButton(
                    tab: tab,
                    isSelected: selectedTab == tab,
                    cartCount: tab == .cart ? cartCount : 0
                ) {
                    withAnimation(AppTheme.Animation.quick) {
                        selectedTab = tab
                    }
                }

                Spacer()
            }
        }
        .padding(.vertical, AppTheme.Spacing.sm)
        .padding(.bottom, AppTheme.Spacing.sm)
        .background(
            AppTheme.Colors.cardBackground
                .shadow(
                    color: AppTheme.Shadow.large.color,
                    radius: AppTheme.Shadow.large.radius,
                    x: 0,
                    y: -4
                )
        )
    }
}

struct TabBarButton: View {
    let tab: MainTabView.Tab
    let isSelected: Bool
    let cartCount: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: AppTheme.Spacing.xxs) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: isSelected ? tab.selectedIcon : tab.icon)
                        .font(.system(size: 22))
                        .foregroundColor(isSelected ? AppTheme.Colors.primaryFallback : AppTheme.Colors.secondaryText)

                    if cartCount > 0 {
                        Text(cartCount > 99 ? "99+" : "\(cartCount)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(AppTheme.Colors.cartBadge)
                            .clipShape(Capsule())
                            .offset(x: 12, y: -8)
                    }
                }

                Text(tab.title)
                    .font(AppTheme.Typography.caption2)
                    .foregroundColor(isSelected ? AppTheme.Colors.primaryFallback : AppTheme.Colors.secondaryText)
            }
        }
    }
}

// MARK: - Preview

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
