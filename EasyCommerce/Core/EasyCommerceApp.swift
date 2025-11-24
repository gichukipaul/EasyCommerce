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

    init() {
        configureAppearance()
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(cartManager)
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
