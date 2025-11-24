//
//  CategoriesView.swift
//  EasyCommerce
//
//  Categories browsing view
//

import SwiftUI

struct CategoriesView: View {
    @StateObject private var viewModel = ProductListingViewModel(networkManager: NetworkManager.shared)
    @State private var selectedCategory: Category?

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                if viewModel.categories.isEmpty {
                    categoriesSkeleton
                } else {
                    LazyVGrid(columns: columns, spacing: AppTheme.Spacing.lg) {
                        ForEach(viewModel.categories) { category in
                            NavigationLink {
                                CategoryProductsView(category: category)
                            } label: {
                                CategoryCard(category: category)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(AppTheme.Spacing.lg)
                }
            }
            .background(AppTheme.Colors.background)
            .navigationTitle(LocalizedString.categories)
            .navigationBarTitleDisplayMode(.large)
            .task {
                await viewModel.fetchCategories()
            }
        }
    }

    private var categoriesSkeleton: some View {
        LazyVGrid(columns: columns, spacing: AppTheme.Spacing.lg) {
            ForEach(0..<4, id: \.self) { _ in
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large)
                    .fill(AppTheme.Colors.secondaryBackground)
                    .frame(height: 150)
                    .shimmer()
            }
        }
        .padding(AppTheme.Spacing.lg)
    }
}

// MARK: - Category Card

struct CategoryCard: View {
    let category: Category

    var body: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            // Icon
            ZStack {
                Circle()
                    .fill(gradientFor(category: category.name))
                    .frame(width: 70, height: 70)

                Image(systemName: iconFor(category: category.name))
                    .font(.system(size: 28))
                    .foregroundColor(.white)
            }

            // Title
            Text(category.name.capitalized)
                .font(AppTheme.Typography.headline)
                .foregroundColor(AppTheme.Colors.text)
                .multilineTextAlignment(.center)

            // Subtitle
            Text("Explore →")
                .font(AppTheme.Typography.caption)
                .foregroundColor(AppTheme.Colors.primaryFallback)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.Spacing.xl)
        .padding(.horizontal, AppTheme.Spacing.md)
        .background(AppTheme.Colors.cardBackground)
        .cornerRadius(AppTheme.CornerRadius.large)
        .shadow(
            color: AppTheme.Shadow.medium.color,
            radius: AppTheme.Shadow.medium.radius,
            x: AppTheme.Shadow.medium.x,
            y: AppTheme.Shadow.medium.y
        )
    }

    private func iconFor(category: String) -> String {
        switch category.lowercased() {
        case "electronics":
            return "laptopcomputer"
        case "jewelery":
            return "sparkles"
        case "men's clothing":
            return "tshirt"
        case "women's clothing":
            return "tshirt.fill"
        default:
            return "tag"
        }
    }

    private func gradientFor(category: String) -> LinearGradient {
        switch category.lowercased() {
        case "electronics":
            return LinearGradient(
                colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case "jewelery":
            return LinearGradient(
                colors: [Color(hex: "f093fb"), Color(hex: "f5576c")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case "men's clothing":
            return LinearGradient(
                colors: [Color(hex: "4facfe"), Color(hex: "00f2fe")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case "women's clothing":
            return LinearGradient(
                colors: [Color(hex: "fa709a"), Color(hex: "fee140")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        default:
            return LinearGradient(
                colors: [Color(hex: "6C5CE7"), Color(hex: "A29BFE")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

// MARK: - Category Products View

struct CategoryProductsView: View {
    let category: Category
    @StateObject private var viewModel = ProductListingViewModel(networkManager: NetworkManager.shared)
    @EnvironmentObject var cartManager: CartManager

    private let columns = [
        GridItem(.flexible(), spacing: AppTheme.Spacing.md),
        GridItem(.flexible(), spacing: AppTheme.Spacing.md)
    ]

    var body: some View {
        ScrollView {
            if viewModel.products.isEmpty && viewModel.error == nil {
                ProductGridSkeleton()
                    .padding(.horizontal, AppTheme.Spacing.lg)
            } else if let error = viewModel.error {
                ErrorView(error: error) {
                    Task {
                        await viewModel.fetchProductsFor(category: category)
                    }
                }
                .padding(.top, AppTheme.Spacing.xxxl)
            } else {
                LazyVGrid(columns: columns, spacing: AppTheme.Spacing.lg) {
                    ForEach(viewModel.products, id: \.id) { product in
                        NavigationLink {
                            ProductDetailView(product: product)
                        } label: {
                            ProductCard(
                                product: product,
                                onAddToCart: {
                                    cartManager.addToCart(product)
                                },
                                onFavorite: {}
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(AppTheme.Spacing.lg)
            }
        }
        .background(AppTheme.Colors.background)
        .navigationTitle(category.name.capitalized)
        .navigationBarTitleDisplayMode(.large)
        .task {
            await viewModel.fetchProductsFor(category: category)
        }
    }
}

// MARK: - Preview

struct CategoriesView_Previews: PreviewProvider {
    static var previews: some View {
        CategoriesView()
            .environmentObject(CartManager.shared)
    }
}
