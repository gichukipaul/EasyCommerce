//
//  OrderManager.swift
//  EasyCommerce
//
//  Order history management
//

import Foundation
import SwiftUI

// MARK: - Order Status

enum OrderStatus: String, Codable, CaseIterable {
    case pending = "Pending"
    case confirmed = "Confirmed"
    case processing = "Processing"
    case shipped = "Shipped"
    case delivered = "Delivered"
    case cancelled = "Cancelled"

    var icon: String {
        switch self {
        case .pending: return "clock"
        case .confirmed: return "checkmark.circle"
        case .processing: return "gearshape.2"
        case .shipped: return "shippingbox"
        case .delivered: return "checkmark.seal.fill"
        case .cancelled: return "xmark.circle"
        }
    }

    var color: Color {
        switch self {
        case .pending: return AppTheme.Colors.warning
        case .confirmed: return AppTheme.Colors.primaryFallback
        case .processing: return AppTheme.Colors.secondary
        case .shipped: return Color.blue
        case .delivered: return AppTheme.Colors.success
        case .cancelled: return AppTheme.Colors.error
        }
    }
}

// MARK: - Order Item

struct OrderItem: Identifiable, Codable {
    let id: String
    let product: Product
    let quantity: Int
    let priceAtPurchase: Double

    var total: Double {
        priceAtPurchase * Double(quantity)
    }

    init(product: Product, quantity: Int) {
        self.id = UUID().uuidString
        self.product = product
        self.quantity = quantity
        self.priceAtPurchase = product.price
    }
}

// MARK: - Order

struct Order: Identifiable, Codable {
    let id: String
    let orderNumber: String
    let items: [OrderItem]
    let subtotal: Double
    let shippingCost: Double
    let total: Double
    let status: OrderStatus
    let createdAt: Date
    let estimatedDelivery: Date?
    let shippingAddress: String?
    let trackingNumber: String?

    init(items: [OrderItem], shippingAddress: String? = nil) {
        self.id = UUID().uuidString
        self.orderNumber = "EC-\(Int.random(in: 100000...999999))"
        self.items = items
        self.subtotal = items.reduce(0) { $0 + $1.total }
        self.shippingCost = subtotal > 50 ? 0 : 5.99
        self.total = subtotal + shippingCost
        self.status = .confirmed
        self.createdAt = Date()
        self.estimatedDelivery = Calendar.current.date(byAdding: .day, value: 5, to: Date())
        self.shippingAddress = shippingAddress
        self.trackingNumber = nil
    }

    var itemCount: Int {
        items.reduce(0) { $0 + $1.quantity }
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: createdAt)
    }

    var formattedEstimatedDelivery: String? {
        guard let date = estimatedDelivery else { return nil }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - Order Manager

@MainActor
final class OrderManager: ObservableObject {
    static let shared = OrderManager()

    @Published private(set) var orders: [Order] = []
    @Published private(set) var isLoading: Bool = false

    private let storageKey = "orderHistory"

    private init() {
        loadFromStorage()

        // Add sample orders if empty (for demo)
        if orders.isEmpty {
            addSampleOrders()
        }
    }

    // MARK: - Computed Properties

    var recentOrders: [Order] {
        Array(orders.prefix(5))
    }

    var activeOrders: [Order] {
        orders.filter { ![.delivered, .cancelled].contains($0.status) }
    }

    var completedOrders: [Order] {
        orders.filter { $0.status == .delivered }
    }

    // MARK: - Actions

    func placeOrder(from cart: CartManager) -> Order {
        let orderItems = cart.items.map { OrderItem(product: $0.product, quantity: $0.quantity) }
        let order = Order(items: orderItems, shippingAddress: "123 Main St, City, Country")

        withAnimation(AppTheme.Animation.spring) {
            orders.insert(order, at: 0)
        }
        saveToStorage()

        // Clear cart after order
        cart.clearCart()

        return order
    }

    func cancelOrder(_ order: Order) {
        guard let index = orders.firstIndex(where: { $0.id == order.id }) else { return }

        // Create updated order with cancelled status
        var updatedOrder = order
        updatedOrder = Order(items: order.items, shippingAddress: order.shippingAddress)

        // We can't mutate the order directly since it's a struct, so we need to recreate
        // In a real app, this would be an API call
        orders.remove(at: index)
        saveToStorage()
    }

    // MARK: - Persistence

    private func loadFromStorage() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([Order].self, from: data) else {
            return
        }
        orders = decoded
    }

    private func saveToStorage() {
        guard let data = try? JSONEncoder().encode(orders) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    // MARK: - Sample Data

    private func addSampleOrders() {
        let sampleProducts = [
            Product(id: 1, title: "Wireless Bluetooth Headphones", price: 59.99, description: "High quality sound", category: "electronics", image: "https://fakestoreapi.com/img/81fPKd-2AYL._AC_SL1500_.jpg", rating: Rating(rate: 4.5, count: 120)),
            Product(id: 2, title: "Classic Cotton T-Shirt", price: 22.99, description: "Comfortable fit", category: "men's clothing", image: "https://fakestoreapi.com/img/71-3HjGNDUL._AC_SY879._SX._UX._SY._UY_.jpg", rating: Rating(rate: 4.2, count: 89))
        ]

        // Add a sample delivered order
        let deliveredItems = [OrderItem(product: sampleProducts[0], quantity: 1)]
        var deliveredOrder = Order(items: deliveredItems)
        orders.append(deliveredOrder)

        saveToStorage()
    }
}
