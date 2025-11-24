//
//  AdvancedSearchView.swift
//  EasyCommerce
//
//  Advanced search with filters and sort options
//

import SwiftUI

// MARK: - Search Filter Model

struct SearchFilters {
    var minPrice: Double = 0
    var maxPrice: Double = 1000
    var minRating: Double = 0
    var selectedCategories: Set<String> = []
    var sortOption: SortOption = .relevance

    enum SortOption: String, CaseIterable {
        case relevance = "Relevance"
        case priceLowToHigh = "Price: Low to High"
        case priceHighToLow = "Price: High to Low"
        case rating = "Highest Rated"
        case newest = "Newest"
    }

    var isActive: Bool {
        minPrice > 0 || maxPrice < 1000 || minRating > 0 || !selectedCategories.isEmpty
    }
}

// MARK: - Advanced Search View

struct AdvancedSearchView: View {
    @StateObject private var viewModel = ProductListingViewModel(networkManager: NetworkManager.shared)
    @EnvironmentObject var cartManager: CartManager
    @EnvironmentObject var wishlistManager: WishlistManager
    @EnvironmentObject var recentlyViewedManager: RecentlyViewedManager

    @State private var searchText: String = ""
    @State private var filters = SearchFilters()
    @State private var showFilters: Bool = false
    @FocusState private var isSearchFocused: Bool

    private let columns = [
        GridItem(.flexible(), spacing: AppTheme.Spacing.md),
        GridItem(.flexible(), spacing: AppTheme.Spacing.md)
    ]

    var filteredProducts: [Product] {
        var products = viewModel.products

        // Text search
        if !searchText.isEmpty {
            products = products.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText) ||
                $0.category.localizedCaseInsensitiveContains(searchText)
            }
        }

        // Price filter
        products = products.filter {
            $0.price >= filters.minPrice && $0.price <= filters.maxPrice
        }

        // Rating filter
        if filters.minRating > 0 {
            products = products.filter { $0.rating.rate >= filters.minRating }
        }

        // Category filter
        if !filters.selectedCategories.isEmpty {
            products = products.filter { filters.selectedCategories.contains($0.category) }
        }

        // Sort
        switch filters.sortOption {
        case .relevance:
            break // Keep original order
        case .priceLowToHigh:
            products.sort { $0.price < $1.price }
        case .priceHighToLow:
            products.sort { $0.price > $1.price }
        case .rating:
            products.sort { $0.rating.rate > $1.rating.rate }
        case .newest:
            products.sort { $0.id > $1.id }
        }

        return products
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Header
                searchHeader

                // Content
                if searchText.isEmpty && !isSearchFocused {
                    recentAndSuggestionsView
                } else {
                    searchResultsView
                }
            }
            .background(AppTheme.Colors.background)
            .navigationTitle(LocalizedString.search)
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await viewModel.fetchProducts()
                await viewModel.fetchCategories()
            }
            .sheet(isPresented: $showFilters) {
                FilterSheet(
                    filters: $filters,
                    categories: viewModel.categories.map { $0.name }
                )
            }
        }
    }

    private var searchHeader: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            // Search Bar
            HStack(spacing: AppTheme.Spacing.md) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(AppTheme.Colors.secondaryText)

                    TextField(LocalizedString.searchProducts, text: $searchText)
                        .focused($isSearchFocused)

                    if !searchText.isEmpty {
                        Button {
                            searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(AppTheme.Colors.tertiaryText)
                        }
                    }
                }
                .padding(AppTheme.Spacing.md)
                .background(AppTheme.Colors.secondaryBackground)
                .cornerRadius(AppTheme.CornerRadius.medium)

                // Filter Button
                Button {
                    showFilters = true
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 18))
                        .foregroundColor(filters.isActive ? .white : AppTheme.Colors.text)
                        .padding(AppTheme.Spacing.md)
                        .background {
                            if filters.isActive {
                                AppTheme.Colors.primaryGradient
                            } else {
                                AppTheme.Colors.secondaryBackground
                            }
                        }
                        .cornerRadius(AppTheme.CornerRadius.medium)
                }
            }

            // Active Filters
            if filters.isActive {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppTheme.Spacing.sm) {
                        if filters.minPrice > 0 || filters.maxPrice < 1000 {
                            FilterChip(
                                title: "$\(Int(filters.minPrice)) - $\(Int(filters.maxPrice))",
                                onRemove: {
                                    filters.minPrice = 0
                                    filters.maxPrice = 1000
                                }
                            )
                        }

                        if filters.minRating > 0 {
                            FilterChip(
                                title: "\(Int(filters.minRating))+ Stars",
                                onRemove: { filters.minRating = 0 }
                            )
                        }

                        ForEach(Array(filters.selectedCategories), id: \.self) { category in
                            FilterChip(
                                title: category.capitalized,
                                onRemove: { filters.selectedCategories.remove(category) }
                            )
                        }

                        Button("Clear All") {
                            filters = SearchFilters()
                        }
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.Colors.primaryFallback)
                    }
                }
            }

            // Sort Picker
            if !searchText.isEmpty || filters.isActive {
                HStack {
                    Text("\(filteredProducts.count) results")
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.Colors.secondaryText)

                    Spacer()

                    Menu {
                        ForEach(SearchFilters.SortOption.allCases, id: \.self) { option in
                            Button {
                                filters.sortOption = option
                            } label: {
                                HStack {
                                    Text(option.rawValue)
                                    if filters.sortOption == option {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: AppTheme.Spacing.xs) {
                            Text(filters.sortOption.rawValue)
                            Image(systemName: "chevron.down")
                        }
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.Colors.primaryFallback)
                    }
                }
            }
        }
        .padding(AppTheme.Spacing.lg)
    }

    private var recentAndSuggestionsView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xl) {
                // Recently Viewed
                if !recentlyViewedManager.items.isEmpty {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                        HStack {
                            Text("Recently Viewed")
                                .font(AppTheme.Typography.headline)
                                .foregroundColor(AppTheme.Colors.text)

                            Spacer()

                            Button("Clear") {
                                recentlyViewedManager.clear()
                            }
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.Colors.primaryFallback)
                        }
                        .padding(.horizontal, AppTheme.Spacing.lg)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: AppTheme.Spacing.md) {
                                ForEach(recentlyViewedManager.items.prefix(10), id: \.id) { product in
                                    NavigationLink {
                                        ProductDetailView(product: product)
                                    } label: {
                                        RecentProductCard(product: product)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, AppTheme.Spacing.lg)
                        }
                    }
                }

                // Popular Categories
                VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                    Text("Popular Categories")
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(AppTheme.Colors.text)
                        .padding(.horizontal, AppTheme.Spacing.lg)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppTheme.Spacing.md) {
                        ForEach(viewModel.categories) { category in
                            Button {
                                filters.selectedCategories.insert(category.name)
                                isSearchFocused = false
                            } label: {
                                HStack {
                                    Text(category.name.capitalized)
                                        .font(AppTheme.Typography.subheadline)
                                        .foregroundColor(AppTheme.Colors.text)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(AppTheme.Colors.tertiaryText)
                                }
                                .padding(AppTheme.Spacing.md)
                                .background(AppTheme.Colors.secondaryBackground)
                                .cornerRadius(AppTheme.CornerRadius.medium)
                            }
                        }
                    }
                    .padding(.horizontal, AppTheme.Spacing.lg)
                }
            }
            .padding(.vertical, AppTheme.Spacing.lg)
        }
    }

    private var searchResultsView: some View {
        Group {
            if filteredProducts.isEmpty {
                VStack(spacing: AppTheme.Spacing.lg) {
                    Spacer()
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 60))
                        .foregroundColor(AppTheme.Colors.tertiaryText)
                    Text(LocalizedString.noResults)
                        .font(AppTheme.Typography.title3)
                        .foregroundColor(AppTheme.Colors.secondaryText)
                    Text("Try adjusting your search or filters")
                        .font(AppTheme.Typography.subheadline)
                        .foregroundColor(AppTheme.Colors.tertiaryText)
                    Spacer()
                }
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: AppTheme.Spacing.lg) {
                        ForEach(filteredProducts, id: \.id) { product in
                            NavigationLink {
                                ProductDetailView(product: product)
                            } label: {
                                ProductCard(
                                    product: product,
                                    onAddToCart: { cartManager.addToCart(product) },
                                    onFavorite: { wishlistManager.toggle(product) }
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(AppTheme.Spacing.lg)
                }
            }
        }
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let title: String
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: AppTheme.Spacing.xs) {
            Text(title)
                .font(AppTheme.Typography.caption)

            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
            }
        }
        .foregroundColor(AppTheme.Colors.primaryFallback)
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.vertical, AppTheme.Spacing.sm)
        .background(AppTheme.Colors.primaryFallback.opacity(0.1))
        .clipShape(Capsule())
    }
}

// MARK: - Recent Product Card

struct RecentProductCard: View {
    let product: Product

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
            .frame(width: 100, height: 100)
            .background(Color.white)
            .cornerRadius(AppTheme.CornerRadius.small)

            Text(product.title)
                .font(AppTheme.Typography.caption)
                .foregroundColor(AppTheme.Colors.text)
                .lineLimit(2)

            PriceView(amount: product.price, size: .small)
        }
        .frame(width: 100)
    }
}

// MARK: - Filter Sheet

struct FilterSheet: View {
    @Binding var filters: SearchFilters
    let categories: [String]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            List {
                // Price Range
                Section("Price Range") {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("$\(Int(filters.minPrice))")
                            Spacer()
                            Text("$\(Int(filters.maxPrice))")
                        }
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.Colors.secondaryText)

                        // Custom range slider would go here
                        HStack {
                            Slider(value: $filters.minPrice, in: 0...500)
                            Slider(value: $filters.maxPrice, in: 0...1000)
                        }
                    }
                }

                // Rating
                Section("Minimum Rating") {
                    ForEach([4.0, 3.0, 2.0, 1.0], id: \.self) { rating in
                        Button {
                            filters.minRating = filters.minRating == rating ? 0 : rating
                        } label: {
                            HStack {
                                HStack(spacing: 2) {
                                    ForEach(0..<Int(rating), id: \.self) { _ in
                                        Image(systemName: "star.fill")
                                            .foregroundColor(AppTheme.Colors.starFilled)
                                    }
                                    Text("& Up")
                                }
                                .font(AppTheme.Typography.subheadline)

                                Spacer()

                                if filters.minRating == rating {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(AppTheme.Colors.primaryFallback)
                                }
                            }
                        }
                        .foregroundColor(AppTheme.Colors.text)
                    }
                }

                // Categories
                Section("Categories") {
                    ForEach(categories, id: \.self) { category in
                        Button {
                            if filters.selectedCategories.contains(category) {
                                filters.selectedCategories.remove(category)
                            } else {
                                filters.selectedCategories.insert(category)
                            }
                        } label: {
                            HStack {
                                Text(category.capitalized)
                                    .foregroundColor(AppTheme.Colors.text)

                                Spacer()

                                if filters.selectedCategories.contains(category) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(AppTheme.Colors.primaryFallback)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Reset") {
                        filters = SearchFilters()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if #available(iOS 16.0, *) {
                        Button("Done") {
                            dismiss()
                        }
                        .fontWeight(.semibold)
                    } else {
                        // Fallback on earlier versions
                    }
                }
            }
        }
    }
}

// MARK: - Preview

struct AdvancedSearchView_Previews: PreviewProvider {
    static var previews: some View {
        AdvancedSearchView()
            .environmentObject(CartManager.shared)
            .environmentObject(WishlistManager.shared)
            .environmentObject(RecentlyViewedManager.shared)
    }
}
