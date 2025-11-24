//
//  EasyCommerceApp.swift
//  EasyCommerce
//
//  Created by Gichuki on 12/11/2023.
//

import SwiftUI

@main
struct EasyCommerceApp: App {
    @StateObject private var cartManager = CartManager.shared
    @StateObject private var wishlistManager = WishlistManager.shared
    @StateObject private var recentlyViewedManager = RecentlyViewedManager.shared
    @StateObject private var orderManager = OrderManager.shared
    @StateObject private var userManager = UserManager.shared

    init() {
        configureAppearance()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(cartManager)
                .environmentObject(wishlistManager)
                .environmentObject(recentlyViewedManager)
                .environmentObject(orderManager)
                .environmentObject(userManager)
        }
    }

    private func configureAppearance() {
        // Navigation Bar Appearance
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = UIColor.systemBackground
        navBarAppearance.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold),
            .foregroundColor: UIColor.label
        ]
        navBarAppearance.largeTitleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 34, weight: .bold),
            .foregroundColor: UIColor.label
        ]

        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        UINavigationBar.appearance().compactAppearance = navBarAppearance
        UINavigationBar.appearance().tintColor = UIColor(Color("6C5CE7"))

        // Tab Bar Appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor.secondarySystemBackground

        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        UITabBar.appearance().tintColor = UIColor(Color("6C5CE7"))
    }
}

// MARK: - Root View (Handles Onboarding)

struct RootView: View {
    @EnvironmentObject var userManager: UserManager

    var body: some View {
        Group {
            if !userManager.hasCompletedOnboarding {
                OnboardingView()
            } else {
                MainTabView()
            }
        }
        .animation(.easeInOut, value: userManager.hasCompletedOnboarding)
    }
}
