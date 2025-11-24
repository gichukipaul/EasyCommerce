//
//  RecentlyViewedManager.swift
//  EasyCommerce
//
//  Track recently viewed products
//

import Foundation
import SwiftUI

@MainActor
final class RecentlyViewedManager: ObservableObject {
    static let shared = RecentlyViewedManager()

    @Published private(set) var items: [Product] = []

    private let storageKey = "recentlyViewedItems"
    private let maxItems = 20

    private init() {
        loadFromStorage()
    }

    // MARK: - Actions

    func addProduct(_ product: Product) {
        // Remove if already exists (will re-add at front)
        items.removeAll { $0.id == product.id }

        // Insert at beginning
        items.insert(product, at: 0)

        // Limit size
        if items.count > maxItems {
            items = Array(items.prefix(maxItems))
        }

        saveToStorage()
    }

    func clear() {
        items.removeAll()
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
