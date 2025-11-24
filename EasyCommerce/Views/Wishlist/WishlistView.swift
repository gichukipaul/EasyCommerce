//
//  WishlistView.swift
//  EasyCommerce
//
//  User's saved/favorite products
//

import SwiftUI

struct WishlistView: View {
    @EnvironmentObject var wishlistManager: WishlistManager
    @EnvironmentObject var cartManager: CartManager

    private let columns = [
        GridItem(.flexible(), spacing: AppTheme.Spacing.md),
        GridItem(.flexible(), spacing: AppTheme.Spacing.md)
    ]

    var body: some View {
        NavigationView {
            Group {
                if wishlistManager.isEmpty {
                    emptyView
                } else {
                    contentView
                }
            }
            .navigationTitle("Wishlist")
            .navigationBarTitleDisplayMode(.large)
            .background(AppTheme.Colors.background)
        }
    }

    private var emptyView: some View {
        VStack(spacing: AppTheme.Spacing.xl) {
            Spacer()

            Image(systemName: "heart")
                .font(.system(size: 80))
                .foregroundColor(AppTheme.Colors.tertiaryText)

            Text("Your wishlist is empty")
                .font(AppTheme.Typography.title3)
                .foregroundColor(AppTheme.Colors.secondaryText)

            Text("Save items you love by tapping the heart icon")
                .font(AppTheme.Typography.subheadline)
                .foregroundColor(AppTheme.Colors.tertiaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppTheme.Spacing.xxl)

            Spacer()
        }
    }

    private var contentView: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: AppTheme.Spacing.lg) {
                ForEach(wishlistManager.items, id: \.id) { product in
                    NavigationLink {
                        ProductDetailView(product: product)
                    } label: {
                        WishlistItemCard(
                            product: product,
                            onRemove: {
                                wishlistManager.remove(product)
                            },
                            onAddToCart: {
                                cartManager.addToCart(product)
                                wishlistManager.remove(product)
                            }
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(AppTheme.Spacing.lg)
        }
    }
}

// MARK: - Wishlist Item Card

struct WishlistItemCard: View {
    let product: Product
    let onRemove: () -> Void
    let onAddToCart: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image with remove button
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
                .frame(height: 150)
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .clipped()

                // Remove button
                Button(action: onRemove) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(AppTheme.Colors.secondaryText)
                        .padding(AppTheme.Spacing.sm)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                .padding(AppTheme.Spacing.sm)
            }

            // Content
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text(product.title)
                    .font(AppTheme.Typography.caption.weight(.medium))
                    .foregroundColor(AppTheme.Colors.text)
                    .lineLimit(2)
                    .padding(.top, AppTheme.Spacing.sm)

                PriceView(amount: product.price, size: .small)

                // Add to Cart button
                Button(action: onAddToCart) {
                    HStack {
                        Image(systemName: "cart.badge.plus")
                        Text("Add to Cart")
                    }
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppTheme.Spacing.sm)
                    .background(AppTheme.Colors.primaryGradient)
                    .cornerRadius(AppTheme.CornerRadius.small)
                }
                .padding(.top, AppTheme.Spacing.xs)
                .padding(.bottom, AppTheme.Spacing.sm)
            }
            .padding(.horizontal, AppTheme.Spacing.sm)
        }
        .background(AppTheme.Colors.cardBackground)
        .cornerRadius(AppTheme.CornerRadius.medium)
        .shadow(
            color: AppTheme.Shadow.small.color,
            radius: AppTheme.Shadow.small.radius,
            x: AppTheme.Shadow.small.x,
            y: AppTheme.Shadow.small.y
        )
    }
}

// MARK: - Preview

struct WishlistView_Previews: PreviewProvider {
    static var previews: some View {
        WishlistView()
            .environmentObject(WishlistManager.shared)
            .environmentObject(CartManager.shared)
    }
}
