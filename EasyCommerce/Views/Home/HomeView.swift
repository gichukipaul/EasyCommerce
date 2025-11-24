//
//  HomeView.swift
//  EasyCommerce
//
//  Modern home view with product grid
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = ProductListingViewModel(networkManager: NetworkManager.shared)
    @EnvironmentObject var cartManager: CartManager
    @State private var selectedCategory: String = "All"
    @State private var searchText: String = ""
    @State private var showCurrencyPicker: Bool = false

    private let columns = [
        GridItem(.flexible(), spacing: AppTheme.Spacing.md),
        GridItem(.flexible(), spacing: AppTheme.Spacing.md)
    ]

    var filteredProducts: [Product] {
        if searchText.isEmpty {
            return viewModel.products
        }
        return viewModel.products.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.category.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Search Bar
                    SearchBar(text: $searchText)
                        .padding(.horizontal, AppTheme.Spacing.lg)
                        .padding(.top, AppTheme.Spacing.sm)

                    // Category Chips
                    if viewModel.categories.isEmpty {
                        CategoryChipsSkeleton()
                    } else {
                        CategoryChips(
                            categories: viewModel.categories,
                            selectedCategory: $selectedCategory
                        )
                    }

                    // Products Grid
                    if viewModel.products.isEmpty && viewModel.error == nil {
                        ProductGridSkeleton()
                            .padding(.horizontal, AppTheme.Spacing.lg)
                    } else if let error = viewModel.error {
                        ErrorView(error: error) {
                            Task {
                                await viewModel.fetchProducts()
                            }
                        }
                        .padding(.top, AppTheme.Spacing.xxxl)
                    } else {
                        productGrid
                    }
                }
            }
            .background(AppTheme.Colors.background)
            .navigationTitle(LocalizedString.home)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showCurrencyPicker = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "globe")
                            Text(CurrencyFormatter.shared.currentCurrencyCode)
                                .font(AppTheme.Typography.caption)
                        }
                        .foregroundColor(AppTheme.Colors.primaryFallback)
                    }
                }
            }
            .refreshable {
                await refreshData()
            }
            .task {
                await loadData()
            }
            .onChange(of: selectedCategory) { newValue in
                Task {
                    if newValue == "All" {
                        await viewModel.fetchProducts()
                    } else {
                        await viewModel.fetchProductsFor(category: Category(name: newValue))
                    }
                }
            }
            .sheet(isPresented: $showCurrencyPicker) {
                CurrencyPicker(isPresented: $showCurrencyPicker)
            }
        }
    }

    private var productGrid: some View {
        LazyVGrid(columns: columns, spacing: AppTheme.Spacing.lg) {
            ForEach(filteredProducts, id: \.id) { product in
                NavigationLink {
                    ProductDetailView(product: product)
                } label: {
                    ProductCard(
                        product: product,
                        onAddToCart: {
                            cartManager.addToCart(product)
                        },
                        onFavorite: {
                            // Handle favorite
                        }
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.top, AppTheme.Spacing.md)
        .padding(.bottom, AppTheme.Spacing.xxxl)
    }

    private func loadData() async {
        await viewModel.fetchCategories()
        await viewModel.fetchProducts()
    }

    private func refreshData() async {
        await loadData()
    }
}

// MARK: - Search Bar

struct SearchBar: View {
    @Binding var text: String
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(AppTheme.Colors.secondaryText)

                TextField(LocalizedString.searchProducts, text: $text)
                    .font(AppTheme.Typography.body)
                    .focused($isFocused)

                if !text.isEmpty {
                    Button {
                        text = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AppTheme.Colors.tertiaryText)
                    }
                }
            }
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.vertical, AppTheme.Spacing.md)
            .background(AppTheme.Colors.secondaryBackground)
            .cornerRadius(AppTheme.CornerRadius.medium)

            if isFocused {
                Button(LocalizedString.cancel) {
                    text = ""
                    isFocused = false
                }
                .font(AppTheme.Typography.subheadline)
                .foregroundColor(AppTheme.Colors.primaryFallback)
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .animation(AppTheme.Animation.quick, value: isFocused)
    }
}

// MARK: - Product Grid Skeleton

struct ProductGridSkeleton: View {
    private let columns = [
        GridItem(.flexible(), spacing: AppTheme.Spacing.md),
        GridItem(.flexible(), spacing: AppTheme.Spacing.md)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: AppTheme.Spacing.lg) {
            ForEach(0..<6, id: \.self) { _ in
                ProductCardSkeleton()
            }
        }
        .padding(.top, AppTheme.Spacing.md)
    }
}

// MARK: - Error View

struct ErrorView: View {
    let error: Error
    let retryAction: () -> Void

    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.Colors.secondaryText)

            Text(LocalizedString.error)
                .font(AppTheme.Typography.title3)
                .foregroundColor(AppTheme.Colors.text)

            Text(error.localizedDescription)
                .font(AppTheme.Typography.subheadline)
                .foregroundColor(AppTheme.Colors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppTheme.Spacing.xxxl)

            Button(action: retryAction) {
                Text(LocalizedString.retry)
                    .primaryButtonStyle()
            }
            .frame(width: 150)
        }
    }
}

// MARK: - Preview

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(CartManager.shared)
    }
}
