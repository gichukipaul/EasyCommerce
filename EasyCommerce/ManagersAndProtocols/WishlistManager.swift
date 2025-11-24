//
//  WishlistManager.swift
//  EasyCommerce
//
//  Persistent wishlist/favorites management
//

import Foundation
import SwiftUI

@MainActor
final class WishlistManager: ObservableObject {
    static let shared = WishlistManager()

    @Published private(set) var items: [Product] = []

    private let storageKey = "wishlistItems"

    private init() {
        loadFromStorage()
    }

    // MARK: - Computed Properties

    var count: Int {
        items.count
    }

    var isEmpty: Bool {
        items.isEmpty
    }

    // MARK: - Actions

    func add(_ product: Product) {
        guard !contains(product) else { return }

        withAnimation(AppTheme.Animation.spring) {
            items.insert(product, at: 0)
        }
        saveToStorage()

        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    func remove(_ product: Product) {
        withAnimation(AppTheme.Animation.spring) {
            items.removeAll { $0.id == product.id }
        }
        saveToStorage()
    }

    func toggle(_ product: Product) {
        if contains(product) {
            remove(product)
        } else {
            add(product)
        }
    }

    func contains(_ product: Product) -> Bool {
        items.contains { $0.id == product.id }
    }

    func clear() {
        withAnimation(AppTheme.Animation.standard) {
            items.removeAll()
        }
        saveToStorage()
    }

    // MARK: - Persistence

    private func loadFromStorage() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([Product].self, from: data) else {
            return
        }
        items = decoded
    }

    private func saveToStorage() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}
