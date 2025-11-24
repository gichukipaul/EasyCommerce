//
//  CartManager.swift
//  EasyCommerce
//
//  Shopping cart state management
//

import Foundation
import SwiftUI

// MARK: - Cart Item

struct CartItem: Identifiable, Equatable {
    let id: String
    let product: Product
    var quantity: Int

    init(product: Product, quantity: Int = 1) {
        self.id = "\(product.id)"
        self.product = product
        self.quantity = quantity
    }

    var totalPrice: Double {
        product.price * Double(quantity)
    }

    static func == (lhs: CartItem, rhs: CartItem) -> Bool {
        lhs.id == rhs.id && lhs.quantity == rhs.quantity
    }
}

// MARK: - Cart Manager

@MainActor
final class CartManager: ObservableObject {
    static let shared = CartManager()

    @Published private(set) var items: [CartItem] = []
    @Published private(set) var isLoading: Bool = false

    private init() {}

    // MARK: - Computed Properties

    var itemCount: Int {
        items.reduce(0) { $0 + $1.quantity }
    }

    var subtotal: Double {
        items.reduce(0) { $0 + $1.totalPrice }
    }

    var shippingCost: Double {
        subtotal > 50 ? 0 : 5.99
    }

    var total: Double {
        subtotal + shippingCost
    }

    var isEmpty: Bool {
        items.isEmpty
    }

    // MARK: - Actions

    func addToCart(_ product: Product) {
        withAnimation(AppTheme.Animation.spring) {
            if let index = items.firstIndex(where: { $0.product.id == product.id }) {
                items[index].quantity += 1
            } else {
                items.append(CartItem(product: product))
            }
        }
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    func removeFromCart(_ product: Product) {
        withAnimation(AppTheme.Animation.spring) {
            items.removeAll { $0.product.id == product.id }
        }
    }

    func updateQuantity(for product: Product, quantity: Int) {
        withAnimation(AppTheme.Animation.quick) {
            if quantity <= 0 {
                removeFromCart(product)
            } else if let index = items.firstIndex(where: { $0.product.id == product.id }) {
                items[index].quantity = quantity
            }
        }
    }

    func incrementQuantity(for product: Product) {
        if let index = items.firstIndex(where: { $0.product.id == product.id }) {
            withAnimation(AppTheme.Animation.quick) {
                items[index].quantity += 1
            }
        }
    }

    func decrementQuantity(for product: Product) {
        if let index = items.firstIndex(where: { $0.product.id == product.id }) {
            if items[index].quantity > 1 {
                withAnimation(AppTheme.Animation.quick) {
                    items[index].quantity -= 1
                }
            } else {
                removeFromCart(product)
            }
        }
    }

    func clearCart() {
        withAnimation(AppTheme.Animation.standard) {
            items.removeAll()
        }
    }

    func contains(_ product: Product) -> Bool {
        items.contains { $0.product.id == product.id }
    }

    func quantity(for product: Product) -> Int {
        items.first { $0.product.id == product.id }?.quantity ?? 0
    }
}
