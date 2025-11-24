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
    @EnvironmentObject var wishlistManager: WishlistManager
    @EnvironmentObject var recentlyViewedManager: RecentlyViewedManager
    @Environment(\.dismiss) private var dismiss

    @State private var quantity: Int = 1
    @State private var showAddedToCart: Bool = false
    @State private var selectedImageScale: CGFloat = 1.0
    @State private var showShareSheet: Bool = false

    var isFavorite: Bool {
        wishlistManager.contains(product)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Hero Image
                heroImage

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

                    Divider()

                    // Reviews Section
                    ProductReviewsSection(product: product)

                    Divider()

                    // Recommendations
                    RecommendationsSection(currentProduct: product)
                }
                .padding(AppTheme.Spacing.lg)
                .background(AppTheme.Colors.background)
            }
        }
        .background(AppTheme.Colors.background)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: AppTheme.Spacing.md) {
                    // Share Button
                    Button {
                        showShareSheet = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(AppTheme.Colors.text)
                    }

                    // Favorite Button
                    Button {
                        withAnimation(AppTheme.Animation.spring) {
                            wishlistManager.toggle(product)
                        }
                    } label: {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(isFavorite ? AppTheme.Colors.error : AppTheme.Colors.text)
                    }
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            bottomBar
        }
        .overlay {
            if showAddedToCart {
                AddedToCartOverlay()
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: [
                "Check out this product: \(product.title)",
                URL(string: "https://easycommerce.app/product/\(product.id)")!
            ])
        }
        .onAppear {
            recentlyViewedManager.addProduct(product)
        }
    }

    private var heroImage: some View {
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

// MARK: - Recommendations Section

struct RecommendationsSection: View {
    let currentProduct: Product
    @StateObject private var viewModel = ProductListingViewModel(networkManager: NetworkManager.shared)
    @EnvironmentObject var cartManager: CartManager

    var recommendedProducts: [Product] {
        viewModel.products
            .filter { $0.id != currentProduct.id && $0.category == currentProduct.category }
            .prefix(6)
            .map { $0 }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("You Might Also Like")
                .font(AppTheme.Typography.headline)
                .foregroundColor(AppTheme.Colors.text)

            if recommendedProducts.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppTheme.Spacing.md) {
                        ForEach(recommendedProducts, id: \.id) { product in
                            NavigationLink {
                                ProductDetailView(product: product)
                            } label: {
                                RecommendationCard(product: product) {
                                    cartManager.addToCart(product)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
        .task {
            await viewModel.fetchProducts()
        }
    }
}

// MARK: - Recommendation Card

struct RecommendationCard: View {
    let product: Product
    let onAddToCart: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            AsyncImage(url: URL(string: product.image)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                default:
                    Rectangle()
                        .fill(AppTheme.Colors.secondaryBackground)
                }
            }
            .frame(width: 120, height: 120)
            .background(Color.white)
            .cornerRadius(AppTheme.CornerRadius.small)

            Text(product.title)
                .font(AppTheme.Typography.caption)
                .foregroundColor(AppTheme.Colors.text)
                .lineLimit(2)

            HStack(spacing: 2) {
                Image(systemName: "star.fill")
                    .font(.system(size: 10))
                    .foregroundColor(AppTheme.Colors.starFilled)
                Text(String(format: "%.1f", product.rating.rate))
                    .font(AppTheme.Typography.caption2)
                    .foregroundColor(AppTheme.Colors.secondaryText)
            }

            PriceView(amount: product.price, size: .small)
        }
        .frame(width: 120)
        .padding(AppTheme.Spacing.sm)
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

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview

struct ProductDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ProductDetailView(product: ProductListingViewModel.sampleProduct)
                .environmentObject(CartManager.shared)
                .environmentObject(WishlistManager.shared)
                .environmentObject(RecentlyViewedManager.shared)
        }
    }
}
