//
//  ProductCard.swift
//  EasyCommerce
//
//  Modern product card component with grid layout support
//

import SwiftUI

struct ProductCard: View {
    let product: Product
    let onAddToCart: () -> Void
    let onFavorite: () -> Void

    @State private var isFavorite: Bool = false
    @State private var isPressed: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image Section
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: URL(string: product.image)) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(AppTheme.Colors.secondaryBackground)
                            .overlay(
                                ProgressView()
                                    .tint(AppTheme.Colors.primaryFallback)
                            )
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
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
                .frame(height: 160)
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .clipped()

                // Favorite Button
                Button {
                    withAnimation(AppTheme.Animation.spring) {
                        isFavorite.toggle()
                        onFavorite()
                    }
                } label: {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(isFavorite ? AppTheme.Colors.error : AppTheme.Colors.secondaryText)
                        .padding(AppTheme.Spacing.sm)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                .padding(AppTheme.Spacing.sm)
            }

            // Content Section
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                // Category Badge
                Text(product.category.uppercased())
                    .font(AppTheme.Typography.caption2)
                    .foregroundColor(AppTheme.Colors.secondaryText)
                    .padding(.top, AppTheme.Spacing.md)

                // Title
                Text(product.title)
                    .font(AppTheme.Typography.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(AppTheme.Colors.text)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                // Rating
                RatingView(rating: product.rating.rate, count: product.rating.count, size: .small)

                Spacer(minLength: AppTheme.Spacing.sm)

                // Price and Cart
                HStack {
                    PriceView(amount: product.price, size: .small)

                    Spacer()

                    // Add to Cart Button
                    Button {
                        withAnimation(AppTheme.Animation.spring) {
                            onAddToCart()
                        }
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(AppTheme.Colors.primaryGradient)
                            .clipShape(Circle())
                    }
                }
                .padding(.bottom, AppTheme.Spacing.md)
            }
            .padding(.horizontal, AppTheme.Spacing.md)
        }
        .background(AppTheme.Colors.cardBackground)
        .cornerRadius(AppTheme.CornerRadius.large)
        .shadow(
            color: AppTheme.Shadow.medium.color,
            radius: AppTheme.Shadow.medium.radius,
            x: AppTheme.Shadow.medium.x,
            y: AppTheme.Shadow.medium.y
        )
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(AppTheme.Animation.quick, value: isPressed)
    }
}

// MARK: - Rating View

struct RatingView: View {
    let rating: Double
    let count: Int
    let size: RatingSize

    enum RatingSize {
        case small, medium, large

        var starSize: CGFloat {
            switch self {
            case .small: return 12
            case .medium: return 16
            case .large: return 20
            }
        }

        var font: Font {
            switch self {
            case .small: return AppTheme.Typography.caption2
            case .medium: return AppTheme.Typography.caption
            case .large: return AppTheme.Typography.subheadline
            }
        }
    }

    var body: some View {
        HStack(spacing: AppTheme.Spacing.xxs) {
            // Stars
            HStack(spacing: 2) {
                ForEach(0..<5) { index in
                    Image(systemName: starImageName(for: index))
                        .font(.system(size: size.starSize))
                        .foregroundColor(index < Int(rating.rounded()) ? AppTheme.Colors.starFilled : AppTheme.Colors.starEmpty)
                }
            }

            // Rating text
            Text(String(format: "%.1f", rating))
                .font(size.font)
                .fontWeight(.medium)
                .foregroundColor(AppTheme.Colors.text)

            // Count
            Text("(\(count))")
                .font(size.font)
                .foregroundColor(AppTheme.Colors.secondaryText)
        }
    }

    private func starImageName(for index: Int) -> String {
        let diff = rating - Double(index)
        if diff >= 1 {
            return "star.fill"
        } else if diff >= 0.5 {
            return "star.leadinghalf.filled"
        } else {
            return "star"
        }
    }
}

// MARK: - Product Card Skeleton

struct ProductCardSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image placeholder
            Rectangle()
                .fill(AppTheme.Colors.secondaryBackground)
                .frame(height: 160)
                .shimmer()

            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                // Category placeholder
                RoundedRectangle(cornerRadius: 4)
                    .fill(AppTheme.Colors.secondaryBackground)
                    .frame(width: 60, height: 10)
                    .shimmer()
                    .padding(.top, AppTheme.Spacing.md)

                // Title placeholder
                VStack(alignment: .leading, spacing: 4) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppTheme.Colors.secondaryBackground)
                        .frame(height: 14)
                        .shimmer()

                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppTheme.Colors.secondaryBackground)
                        .frame(width: 100, height: 14)
                        .shimmer()
                }

                // Rating placeholder
                RoundedRectangle(cornerRadius: 4)
                    .fill(AppTheme.Colors.secondaryBackground)
                    .frame(width: 80, height: 12)
                    .shimmer()

                Spacer(minLength: AppTheme.Spacing.sm)

                // Price placeholder
                HStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppTheme.Colors.secondaryBackground)
                        .frame(width: 70, height: 18)
                        .shimmer()

                    Spacer()

                    Circle()
                        .fill(AppTheme.Colors.secondaryBackground)
                        .frame(width: 32, height: 32)
                        .shimmer()
                }
                .padding(.bottom, AppTheme.Spacing.md)
            }
            .padding(.horizontal, AppTheme.Spacing.md)
        }
        .background(AppTheme.Colors.cardBackground)
        .cornerRadius(AppTheme.CornerRadius.large)
        .shadow(
            color: AppTheme.Shadow.small.color,
            radius: AppTheme.Shadow.small.radius,
            x: AppTheme.Shadow.small.x,
            y: AppTheme.Shadow.small.y
        )
    }
}

// MARK: - Preview

struct ProductCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            ProductCard(
                product: ProductListingViewModel.sampleProduct,
                onAddToCart: {},
                onFavorite: {}
            )
            .frame(width: 180)

            ProductCardSkeleton()
                .frame(width: 180)
        }
        .padding()
        .background(AppTheme.Colors.background)
    }
}
