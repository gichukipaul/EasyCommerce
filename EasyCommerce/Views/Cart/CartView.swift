//
//  CartView.swift
//  EasyCommerce
//
//  Shopping cart view with item management
//

import SwiftUI

struct CartView: View {
    @EnvironmentObject var cartManager: CartManager
    @State private var showCheckout: Bool = false

    var body: some View {
        NavigationView {
            Group {
                if cartManager.isEmpty {
                    emptyCartView
                } else {
                    cartContentView
                }
            }
            .navigationTitle(LocalizedString.yourCart)
            .navigationBarTitleDisplayMode(.large)
            .background(AppTheme.Colors.background)
        }
    }

    // MARK: - Empty Cart View

    private var emptyCartView: some View {
        VStack(spacing: AppTheme.Spacing.xl) {
            Spacer()

            Image(systemName: "cart")
                .font(.system(size: 80))
                .foregroundColor(AppTheme.Colors.tertiaryText)

            Text(LocalizedString.emptyCart)
                .font(AppTheme.Typography.title3)
                .foregroundColor(AppTheme.Colors.secondaryText)

            Text("Start shopping to add items to your cart")
                .font(AppTheme.Typography.subheadline)
                .foregroundColor(AppTheme.Colors.tertiaryText)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .padding(AppTheme.Spacing.lg)
    }

    // MARK: - Cart Content View

    private var cartContentView: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVStack(spacing: AppTheme.Spacing.md) {
                    ForEach(cartManager.items) { item in
                        CartItemRow(item: item)
                            .transition(.asymmetric(
                                insertion: .slide,
                                removal: .move(edge: .trailing).combined(with: .opacity)
                            ))
                    }
                }
                .padding(AppTheme.Spacing.lg)
            }

            // Order Summary
            orderSummary
        }
    }

    // MARK: - Order Summary

    private var orderSummary: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            // Summary rows
            VStack(spacing: AppTheme.Spacing.sm) {
                summaryRow(title: LocalizedString.subtotal, amount: cartManager.subtotal)

                summaryRow(
                    title: LocalizedString.shipping,
                    amount: cartManager.shippingCost,
                    note: cartManager.shippingCost == 0 ? LocalizedString.free : nil
                )

                Divider()

                HStack {
                    Text(LocalizedString.total)
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(AppTheme.Colors.text)

                    Spacer()

                    PriceView(amount: cartManager.total, size: .large)
                }
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
            .padding(.top, AppTheme.Spacing.lg)

            // Checkout Button
            Button {
                showCheckout = true
            } label: {
                HStack {
                    Image(systemName: "lock.fill")
                    Text(LocalizedString.checkout)
                }
                .primaryButtonStyle()
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
            .padding(.bottom, AppTheme.Spacing.lg)
        }
        .background(
            AppTheme.Colors.cardBackground
                .shadow(
                    color: AppTheme.Shadow.large.color,
                    radius: AppTheme.Shadow.large.radius,
                    x: 0,
                    y: -4
                )
        )
        .alert("Checkout", isPresented: $showCheckout) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Checkout functionality coming soon!")
        }
    }

    private func summaryRow(title: String, amount: Double, note: String? = nil) -> some View {
        HStack {
            Text(title)
                .font(AppTheme.Typography.subheadline)
                .foregroundColor(AppTheme.Colors.secondaryText)

            Spacer()

            if let note = note {
                Text(note)
                    .font(AppTheme.Typography.subheadline)
                    .foregroundColor(AppTheme.Colors.success)
            } else {
                Text(CurrencyFormatter.shared.format(amount))
                    .font(AppTheme.Typography.subheadline)
                    .foregroundColor(AppTheme.Colors.text)
            }
        }
    }
}

// MARK: - Cart Item Row

struct CartItemRow: View {
    let item: CartItem
    @EnvironmentObject var cartManager: CartManager

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // Product Image
            AsyncImage(url: URL(string: item.product.image)) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(AppTheme.Colors.secondaryBackground)
                        .overlay(ProgressView())
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                case .failure:
                    Rectangle()
                        .fill(AppTheme.Colors.secondaryBackground)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(AppTheme.Colors.tertiaryText)
                        )
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 80, height: 80)
            .background(Color.white)
            .cornerRadius(AppTheme.CornerRadius.small)

            // Product Info
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text(item.product.title)
                    .font(AppTheme.Typography.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(AppTheme.Colors.text)
                    .lineLimit(2)

                Text(item.product.category.capitalized)
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.Colors.secondaryText)

                Spacer()

                HStack {
                    PriceView(amount: item.product.price, size: .small)

                    Spacer()

                    // Quantity Controls
                    quantityControls
                }
            }
        }
        .padding(AppTheme.Spacing.md)
        .background(AppTheme.Colors.cardBackground)
        .cornerRadius(AppTheme.CornerRadius.medium)
        .shadow(
            color: AppTheme.Shadow.small.color,
            radius: AppTheme.Shadow.small.radius,
            x: AppTheme.Shadow.small.x,
            y: AppTheme.Shadow.small.y
        )
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                cartManager.removeFromCart(item.product)
            } label: {
                Label(LocalizedString.removeFromCart, systemImage: "trash")
            }
        }
    }

    private var quantityControls: some View {
        HStack(spacing: 0) {
            Button {
                cartManager.decrementQuantity(for: item.product)
            } label: {
                Image(systemName: "minus")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(AppTheme.Colors.text)
                    .frame(width: 32, height: 32)
            }

            Text("\(item.quantity)")
                .font(AppTheme.Typography.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(AppTheme.Colors.text)
                .frame(width: 30)

            Button {
                cartManager.incrementQuantity(for: item.product)
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(AppTheme.Colors.text)
                    .frame(width: 32, height: 32)
            }
        }
        .background(AppTheme.Colors.secondaryBackground)
        .cornerRadius(AppTheme.CornerRadius.small)
    }
}

// MARK: - Cart Badge

struct CartBadge: View {
    let count: Int

    var body: some View {
        if count > 0 {
            Text(count > 99 ? "99+" : "\(count)")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(AppTheme.Colors.cartBadge)
                .clipShape(Capsule())
        }
    }
}

// MARK: - Preview

struct CartView_Previews: PreviewProvider {
    static var previews: some View {
        CartView()
            .environmentObject(CartManager.shared)
    }
}
