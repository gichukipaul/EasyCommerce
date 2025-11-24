//
//  ProductDetailView.swift
//  EasyCommerce
//
//  Detailed product view with full information
//

import SwiftUI

struct ProductDetailView: View {
    let product: Product
    @EnvironmentObject var cartManager: CartManager
    @Environment(\.dismiss) private var dismiss
    @State private var quantity: Int = 1
    @State private var showAddedToCart: Bool = false
    @State private var selectedImageScale: CGFloat = 1.0

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Hero Image
                ZStack(alignment: .topTrailing) {
                    AsyncImage(url: URL(string: product.image)) { phase in
                        switch phase {
                        case .empty:
                            Rectangle()
                                .fill(AppTheme.Colors.secondaryBackground)
                                .overlay(ProgressView())
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .scaleEffect(selectedImageScale)
                                .gesture(
                                    MagnificationGesture()
                                        .onChanged { value in
                                            selectedImageScale = value
                                        }
                                        .onEnded { _ in
                                            withAnimation {
                                                selectedImageScale = 1.0
                                            }
                                        }
                                )
                        case .failure:
                            Rectangle()
                                .fill(AppTheme.Colors.secondaryBackground)
                                .overlay(
                                    Image(systemName: "photo")
                                        .font(.largeTitle)
                                        .foregroundColor(AppTheme.Colors.tertiaryText)
                                )
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 350)
                    .background(Color.white)

                    // Favorite button
                    Button {
                        // Handle favorite
                    } label: {
                        Image(systemName: "heart")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(AppTheme.Colors.secondaryText)
                            .padding(AppTheme.Spacing.md)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    .padding(AppTheme.Spacing.lg)
                }

                // Content
                VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                    // Category
                    Text(product.category.uppercased())
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.Colors.primaryFallback)
                        .padding(.horizontal, AppTheme.Spacing.sm)
                        .padding(.vertical, AppTheme.Spacing.xs)
                        .background(AppTheme.Colors.primaryFallback.opacity(0.1))
                        .cornerRadius(AppTheme.CornerRadius.small)

                    // Title
                    Text(product.title)
                        .font(AppTheme.Typography.title2)
                        .foregroundColor(AppTheme.Colors.text)

                    // Rating
                    HStack(spacing: AppTheme.Spacing.md) {
                        RatingView(rating: product.rating.rate, count: product.rating.count, size: .medium)

                        Spacer()

                        // Stock status
                        HStack(spacing: AppTheme.Spacing.xs) {
                            Circle()
                                .fill(AppTheme.Colors.success)
                                .frame(width: 8, height: 8)
                            Text(LocalizedString.inStock)
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(AppTheme.Colors.success)
                        }
                    }

                    // Price
                    PriceView(amount: product.price, size: .large)

                    Divider()

                    // Description Section
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                        Text(LocalizedString.description)
                            .font(AppTheme.Typography.headline)
                            .foregroundColor(AppTheme.Colors.text)

                        Text(product.description)
                            .font(AppTheme.Typography.body)
                            .foregroundColor(AppTheme.Colors.secondaryText)
                            .lineSpacing(4)
                    }

                    Divider()

                    // Quantity Selector
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                        Text("Quantity")
                            .font(AppTheme.Typography.headline)
                            .foregroundColor(AppTheme.Colors.text)

                        QuantitySelector(quantity: $quantity)
                    }
                }
                .padding(AppTheme.Spacing.lg)
                .background(AppTheme.Colors.background)
            }
        }
        .background(AppTheme.Colors.background)
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            bottomBar
        }
        .overlay {
            if showAddedToCart {
                AddedToCartOverlay()
                    .transition(.scale.combined(with: .opacity))
            }
        }
    }

    private var bottomBar: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // Total Price
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
                Text("Total")
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.Colors.secondaryText)
                PriceView(amount: product.price * Double(quantity), size: .medium)
            }

            Spacer()

            // Add to Cart Button
            Button {
                addToCart()
            } label: {
                HStack(spacing: AppTheme.Spacing.sm) {
                    Image(systemName: "cart.badge.plus")
                    Text(LocalizedString.addToCart)
                }
                .font(AppTheme.Typography.headline)
                .foregroundColor(.white)
                .padding(.horizontal, AppTheme.Spacing.xl)
                .padding(.vertical, AppTheme.Spacing.md)
                .background(AppTheme.Colors.primaryGradient)
                .cornerRadius(AppTheme.CornerRadius.medium)
            }
        }
        .padding(AppTheme.Spacing.lg)
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

    private func addToCart() {
        for _ in 0..<quantity {
            cartManager.addToCart(product)
        }

        withAnimation(AppTheme.Animation.spring) {
            showAddedToCart = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(AppTheme.Animation.standard) {
                showAddedToCart = false
            }
        }
    }
}

// MARK: - Quantity Selector

struct QuantitySelector: View {
    @Binding var quantity: Int

    var body: some View {
        HStack(spacing: 0) {
            Button {
                if quantity > 1 {
                    quantity -= 1
                }
            } label: {
                Image(systemName: "minus")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(quantity > 1 ? AppTheme.Colors.text : AppTheme.Colors.tertiaryText)
                    .frame(width: 44, height: 44)
            }
            .disabled(quantity <= 1)

            Text("\(quantity)")
                .font(AppTheme.Typography.headline)
                .foregroundColor(AppTheme.Colors.text)
                .frame(width: 50)

            Button {
                quantity += 1
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AppTheme.Colors.text)
                    .frame(width: 44, height: 44)
            }
        }
        .background(AppTheme.Colors.secondaryBackground)
        .cornerRadius(AppTheme.CornerRadius.medium)
    }
}

// MARK: - Added to Cart Overlay

struct AddedToCartOverlay: View {
    var body: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(AppTheme.Colors.success)

            Text("Added to Cart!")
                .font(AppTheme.Typography.headline)
                .foregroundColor(AppTheme.Colors.text)
        }
        .padding(AppTheme.Spacing.xxl)
        .background(.ultraThinMaterial)
        .cornerRadius(AppTheme.CornerRadius.large)
    }
}

// MARK: - Preview

struct ProductDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ProductDetailView(product: ProductListingViewModel.sampleProduct)
                .environmentObject(CartManager.shared)
        }
    }
}
