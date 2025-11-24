//
//  MainTabView.swift
//  EasyCommerce
//
//  Main tab bar navigation
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var cartManager: CartManager
    @EnvironmentObject var wishlistManager: WishlistManager
    @State private var selectedTab: Tab = .home

    enum Tab: String, CaseIterable {
        case home
        case search
        case cart
        case wishlist
        case profile

        var title: String {
            switch self {
            case .home: return LocalizedString.home
            case .search: return LocalizedString.search
            case .cart: return LocalizedString.cart
            case .wishlist: return "Wishlist"
            case .profile: return LocalizedString.profile
            }
        }

        var icon: String {
            switch self {
            case .home: return "house"
            case .search: return "magnifyingglass"
            case .cart: return "cart"
            case .wishlist: return "heart"
            case .profile: return "person"
            }
        }

        var selectedIcon: String {
            switch self {
            case .home: return "house.fill"
            case .search: return "magnifyingglass"
            case .cart: return "cart.fill"
            case .wishlist: return "heart.fill"
            case .profile: return "person.fill"
            }
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label(Tab.home.title, systemImage: selectedTab == .home ? Tab.home.selectedIcon : Tab.home.icon)
                }
                .tag(Tab.home)

            AdvancedSearchView()
                .tabItem {
                    Label(Tab.search.title, systemImage: selectedTab == .search ? Tab.search.selectedIcon : Tab.search.icon)
                }
                .tag(Tab.search)

            CartView()
                .tabItem {
                    Label(Tab.cart.title, systemImage: selectedTab == .cart ? Tab.cart.selectedIcon : Tab.cart.icon)
                }
                .tag(Tab.cart)
                .badge(cartManager.itemCount > 0 ? cartManager.itemCount : 0)

            WishlistView()
                .tabItem {
                    Label(Tab.wishlist.title, systemImage: selectedTab == .wishlist ? Tab.wishlist.selectedIcon : Tab.wishlist.icon)
                }
                .tag(Tab.wishlist)
                .badge(wishlistManager.count > 0 ? wishlistManager.count : 0)

            ProfileView()
                .tabItem {
                    Label(Tab.profile.title, systemImage: selectedTab == .profile ? Tab.profile.selectedIcon : Tab.profile.icon)
                }
                .tag(Tab.profile)
        }
        .tint(AppTheme.Colors.primaryFallback)
    }
}

// MARK: - Preview

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(CartManager.shared)
            .environmentObject(WishlistManager.shared)
            .environmentObject(RecentlyViewedManager.shared)
            .environmentObject(OrderManager.shared)
            .environmentObject(UserManager.shared)
    }
}
