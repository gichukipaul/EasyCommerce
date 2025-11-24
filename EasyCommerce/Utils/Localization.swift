//
//  Localization.swift
//  EasyCommerce
//
//  Internationalization utilities for currency, dates, and strings
//

import Foundation
import SwiftUI

// MARK: - Currency Formatter

final class CurrencyFormatter: ObservableObject {
    static let shared = CurrencyFormatter()

    @Published var currentLocale: Locale = .current
    @Published var currentCurrencyCode: String = "USD"

    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }()

    // Supported currencies for international e-commerce
    static let supportedCurrencies: [(code: String, symbol: String, name: String)] = [
        ("USD", "$", "US Dollar"),
        ("EUR", "€", "Euro"),
        ("GBP", "£", "British Pound"),
        ("JPY", "¥", "Japanese Yen"),
        ("CNY", "¥", "Chinese Yuan"),
        ("KRW", "₩", "Korean Won"),
        ("INR", "₹", "Indian Rupee"),
        ("BRL", "R$", "Brazilian Real"),
        ("CAD", "C$", "Canadian Dollar"),
        ("AUD", "A$", "Australian Dollar"),
        ("MXN", "$", "Mexican Peso"),
        ("KES", "KSh", "Kenyan Shilling"),
        ("NGN", "₦", "Nigerian Naira"),
        ("ZAR", "R", "South African Rand"),
        ("AED", "د.إ", "UAE Dirham"),
        ("SAR", "﷼", "Saudi Riyal"),
        ("SGD", "S$", "Singapore Dollar"),
        ("CHF", "CHF", "Swiss Franc"),
        ("SEK", "kr", "Swedish Krona"),
        ("PLN", "zł", "Polish Zloty")
    ]

    // Exchange rates (simplified - in production use API)
    private let exchangeRates: [String: Double] = [
        "USD": 1.0,
        "EUR": 0.92,
        "GBP": 0.79,
        "JPY": 149.50,
        "CNY": 7.24,
        "KRW": 1298.0,
        "INR": 83.12,
        "BRL": 4.97,
        "CAD": 1.36,
        "AUD": 1.53,
        "MXN": 17.15,
        "KES": 153.50,
        "NGN": 1550.0,
        "ZAR": 18.65,
        "AED": 3.67,
        "SAR": 3.75,
        "SGD": 1.34,
        "CHF": 0.88,
        "SEK": 10.42,
        "PLN": 3.95
    ]

    func format(_ amount: Double, currencyCode: String? = nil) -> String {
        let code = currencyCode ?? currentCurrencyCode
        numberFormatter.currencyCode = code
        numberFormatter.locale = localeFor(currencyCode: code)

        let convertedAmount = convert(amount, to: code)
        return numberFormatter.string(from: NSNumber(value: convertedAmount)) ?? "\(code) \(convertedAmount)"
    }

    func convert(_ amount: Double, from: String = "USD", to: String) -> Double {
        guard let fromRate = exchangeRates[from],
              let toRate = exchangeRates[to] else {
            return amount
        }
        let usdAmount = amount / fromRate
        return usdAmount * toRate
    }

    func setCurrency(_ code: String) {
        currentCurrencyCode = code
        objectWillChange.send()
    }

    private func localeFor(currencyCode: String) -> Locale {
        switch currencyCode {
        case "EUR": return Locale(identifier: "de_DE")
        case "GBP": return Locale(identifier: "en_GB")
        case "JPY": return Locale(identifier: "ja_JP")
        case "CNY": return Locale(identifier: "zh_CN")
        case "KRW": return Locale(identifier: "ko_KR")
        case "INR": return Locale(identifier: "en_IN")
        case "BRL": return Locale(identifier: "pt_BR")
        case "KES": return Locale(identifier: "sw_KE")
        default: return Locale(identifier: "en_US")
        }
    }
}

// MARK: - Localized Strings

enum LocalizedString {
    // Navigation
    static let home = NSLocalizedString("Home", comment: "Home tab")
    static let categories = NSLocalizedString("Categories", comment: "Categories tab")
    static let cart = NSLocalizedString("Cart", comment: "Cart tab")
    static let profile = NSLocalizedString("Profile", comment: "Profile tab")
    static let search = NSLocalizedString("Search", comment: "Search")

    // Products
    static let products = NSLocalizedString("Products", comment: "Products title")
    static let allProducts = NSLocalizedString("All", comment: "All products filter")
    static let addToCart = NSLocalizedString("Add to Cart", comment: "Add to cart button")
    static let buyNow = NSLocalizedString("Buy Now", comment: "Buy now button")
    static let inStock = NSLocalizedString("In Stock", comment: "In stock label")
    static let outOfStock = NSLocalizedString("Out of Stock", comment: "Out of stock label")
    static let reviews = NSLocalizedString("reviews", comment: "Reviews count")
    static let description = NSLocalizedString("Description", comment: "Description section")
    static let relatedProducts = NSLocalizedString("Related Products", comment: "Related products section")

    // Cart
    static let yourCart = NSLocalizedString("Your Cart", comment: "Cart title")
    static let emptyCart = NSLocalizedString("Your cart is empty", comment: "Empty cart message")
    static let subtotal = NSLocalizedString("Subtotal", comment: "Subtotal label")
    static let shipping = NSLocalizedString("Shipping", comment: "Shipping label")
    static let total = NSLocalizedString("Total", comment: "Total label")
    static let checkout = NSLocalizedString("Checkout", comment: "Checkout button")
    static let continueShopping = NSLocalizedString("Continue Shopping", comment: "Continue shopping button")
    static let removeFromCart = NSLocalizedString("Remove", comment: "Remove from cart")

    // Search
    static let searchProducts = NSLocalizedString("Search products...", comment: "Search placeholder")
    static let noResults = NSLocalizedString("No results found", comment: "No search results")
    static let recentSearches = NSLocalizedString("Recent Searches", comment: "Recent searches title")

    // General
    static let loading = NSLocalizedString("Loading...", comment: "Loading state")
    static let error = NSLocalizedString("Error", comment: "Error title")
    static let retry = NSLocalizedString("Retry", comment: "Retry button")
    static let cancel = NSLocalizedString("Cancel", comment: "Cancel button")
    static let done = NSLocalizedString("Done", comment: "Done button")
    static let free = NSLocalizedString("Free", comment: "Free shipping")
}

// MARK: - Price View

struct PriceView: View {
    let amount: Double
    let originalAmount: Double?
    let size: PriceSize

    @ObservedObject private var currencyFormatter = CurrencyFormatter.shared

    enum PriceSize {
        case small, medium, large

        var font: Font {
            switch self {
            case .small: return AppTheme.Typography.priceSmall
            case .medium: return AppTheme.Typography.price
            case .large: return AppTheme.Typography.title2
            }
        }
    }

    init(amount: Double, originalAmount: Double? = nil, size: PriceSize = .medium) {
        self.amount = amount
        self.originalAmount = originalAmount
        self.size = size
    }

    var body: some View {
        HStack(spacing: AppTheme.Spacing.xs) {
            Text(currencyFormatter.format(amount))
                .font(size.font)
                .foregroundColor(AppTheme.Colors.primaryFallback)

            if let original = originalAmount, original > amount {
                Text(currencyFormatter.format(original))
                    .font(size == .large ? AppTheme.Typography.subheadline : AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.Colors.tertiaryText)
                    .strikethrough()
            }
        }
    }
}

// MARK: - Currency Picker

struct CurrencyPicker: View {
    @ObservedObject private var currencyFormatter = CurrencyFormatter.shared
    @Binding var isPresented: Bool

    var body: some View {
        NavigationView {
            List(CurrencyFormatter.supportedCurrencies, id: \.code) { currency in
                Button {
                    currencyFormatter.setCurrency(currency.code)
                    isPresented = false
                } label: {
                    HStack {
                        Text(currency.symbol)
                            .font(AppTheme.Typography.title3)
                            .frame(width: 40)

                        VStack(alignment: .leading) {
                            Text(currency.code)
                                .font(AppTheme.Typography.headline)
                                .foregroundColor(AppTheme.Colors.text)
                            Text(currency.name)
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(AppTheme.Colors.secondaryText)
                        }

                        Spacer()

                        if currencyFormatter.currentCurrencyCode == currency.code {
                            Image(systemName: "checkmark")
                                .foregroundColor(AppTheme.Colors.primaryFallback)
                        }
                    }
                }
            }
            .navigationTitle("Select Currency")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(LocalizedString.done) {
                        isPresented = false
                    }
                }
            }
        }
    }
}
