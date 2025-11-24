//
//  ProductReviews.swift
//  EasyCommerce
//
//  Product reviews display component
//

import SwiftUI

// MARK: - Review Model

struct Review: Identifiable {
    let id: String
    let userName: String
    let rating: Double
    let title: String
    let content: String
    let date: Date
    let isVerifiedPurchase: Bool
    let helpfulCount: Int
    let images: [String]

    var formattedDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    // Sample reviews for demo
    static let samples: [Review] = [
        Review(
            id: "1",
            userName: "John D.",
            rating: 5.0,
            title: "Excellent product!",
            content: "This exceeded my expectations. The quality is amazing and it arrived earlier than expected. Would definitely recommend to anyone looking for a great deal.",
            date: Date().addingTimeInterval(-86400 * 2),
            isVerifiedPurchase: true,
            helpfulCount: 24,
            images: []
        ),
        Review(
            id: "2",
            userName: "Sarah M.",
            rating: 4.0,
            title: "Good value for money",
            content: "Pretty good product overall. Minor issues with packaging but the product itself is great. Fast shipping too!",
            date: Date().addingTimeInterval(-86400 * 5),
            isVerifiedPurchase: true,
            helpfulCount: 12,
            images: []
        ),
        Review(
            id: "3",
            userName: "Mike R.",
            rating: 5.0,
            title: "Perfect!",
            content: "Exactly what I was looking for. Great quality and fair price.",
            date: Date().addingTimeInterval(-86400 * 10),
            isVerifiedPurchase: false,
            helpfulCount: 8,
            images: []
        ),
        Review(
            id: "4",
            userName: "Emma L.",
            rating: 3.0,
            title: "It's okay",
            content: "Decent product but I expected better quality for this price. It works fine though.",
            date: Date().addingTimeInterval(-86400 * 15),
            isVerifiedPurchase: true,
            helpfulCount: 5,
            images: []
        )
    ]
}

// MARK: - Product Reviews Section

struct ProductReviewsSection: View {
    let product: Product
    @State private var showAllReviews: Bool = false

    // Generate sample reviews based on product
    var reviews: [Review] {
        Review.samples
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
            // Header
            HStack {
                Text("Reviews")
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(AppTheme.Colors.text)

                Spacer()

                Button("See All") {
                    showAllReviews = true
                }
                .font(AppTheme.Typography.subheadline)
                .foregroundColor(AppTheme.Colors.primaryFallback)
            }

            // Rating Summary
            RatingSummary(rating: product.rating)

            // Review Cards
            ForEach(reviews.prefix(2)) { review in
                ReviewCard(review: review)
            }

            // Write Review Button
            Button {
                // Handle write review
            } label: {
                HStack {
                    Image(systemName: "square.and.pencil")
                    Text("Write a Review")
                }
                .secondaryButtonStyle()
            }
        }
        .sheet(isPresented: $showAllReviews) {
            AllReviewsView(product: product, reviews: reviews)
        }
    }
}

// MARK: - Rating Summary

struct RatingSummary: View {
    let rating: Rating

    var body: some View {
        HStack(spacing: AppTheme.Spacing.lg) {
            // Big Rating Number
            VStack(spacing: AppTheme.Spacing.xxs) {
                Text(String(format: "%.1f", rating.rate))
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.Colors.text)

                RatingView(rating: rating.rate, count: rating.count, size: .small)
            }

            Divider()
                .frame(height: 80)

            // Rating Breakdown
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                RatingBar(stars: 5, percentage: 0.7)
                RatingBar(stars: 4, percentage: 0.2)
                RatingBar(stars: 3, percentage: 0.05)
                RatingBar(stars: 2, percentage: 0.03)
                RatingBar(stars: 1, percentage: 0.02)
            }
        }
        .padding(AppTheme.Spacing.lg)
        .background(AppTheme.Colors.secondaryBackground)
        .cornerRadius(AppTheme.CornerRadius.medium)
    }
}

// MARK: - Rating Bar

struct RatingBar: View {
    let stars: Int
    let percentage: Double

    var body: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            Text("\(stars)")
                .font(AppTheme.Typography.caption)
                .foregroundColor(AppTheme.Colors.secondaryText)
                .frame(width: 12)

            Image(systemName: "star.fill")
                .font(.system(size: 10))
                .foregroundColor(AppTheme.Colors.starFilled)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(AppTheme.Colors.tertiaryText.opacity(0.2))

                    Rectangle()
                        .fill(AppTheme.Colors.starFilled)
                        .frame(width: geometry.size.width * percentage)
                }
            }
            .frame(height: 6)
            .cornerRadius(3)
        }
    }
}

// MARK: - Review Card

struct ReviewCard: View {
    let review: Review
    @State private var isHelpful: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            // Header
            HStack {
                // Avatar
                Circle()
                    .fill(AppTheme.Colors.primaryGradient)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(String(review.userName.first ?? "U"))
                            .font(AppTheme.Typography.headline)
                            .foregroundColor(.white)
                    )

                VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
                    HStack {
                        Text(review.userName)
                            .font(AppTheme.Typography.subheadline.weight(.medium))
                            .foregroundColor(AppTheme.Colors.text)

                        if review.isVerifiedPurchase {
                            Text("✓ Verified")
                                .font(AppTheme.Typography.caption2)
                                .foregroundColor(AppTheme.Colors.success)
                        }
                    }

                    Text(review.formattedDate)
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.Colors.tertiaryText)
                }

                Spacer()

                // Star rating
                HStack(spacing: 2) {
                    ForEach(0..<5) { index in
                        Image(systemName: index < Int(review.rating) ? "star.fill" : "star")
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.Colors.starFilled)
                    }
                }
            }

            // Title
            Text(review.title)
                .font(AppTheme.Typography.subheadline.weight(.semibold))
                .foregroundColor(AppTheme.Colors.text)

            // Content
            Text(review.content)
                .font(AppTheme.Typography.subheadline)
                .foregroundColor(AppTheme.Colors.secondaryText)
                .lineLimit(4)

            // Helpful Button
            HStack {
                Button {
                    isHelpful.toggle()
                } label: {
                    HStack(spacing: AppTheme.Spacing.xs) {
                        Image(systemName: isHelpful ? "hand.thumbsup.fill" : "hand.thumbsup")
                        Text("Helpful (\(review.helpfulCount + (isHelpful ? 1 : 0)))")
                    }
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(isHelpful ? AppTheme.Colors.primaryFallback : AppTheme.Colors.secondaryText)
                }

                Spacer()

                Button {
                    // Report review
                } label: {
                    Image(systemName: "flag")
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.Colors.tertiaryText)
                }
            }
        }
        .padding(AppTheme.Spacing.lg)
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

// MARK: - All Reviews View

struct AllReviewsView: View {
    let product: Product
    let reviews: [Review]
    @Environment(\.dismiss) private var dismiss
    @State private var sortOption: SortOption = .mostRecent

    enum SortOption: String, CaseIterable {
        case mostRecent = "Most Recent"
        case highestRated = "Highest Rated"
        case lowestRated = "Lowest Rated"
        case mostHelpful = "Most Helpful"
    }

    var sortedReviews: [Review] {
        switch sortOption {
        case .mostRecent:
            return reviews.sorted { $0.date > $1.date }
        case .highestRated:
            return reviews.sorted { $0.rating > $1.rating }
        case .lowestRated:
            return reviews.sorted { $0.rating < $1.rating }
        case .mostHelpful:
            return reviews.sorted { $0.helpfulCount > $1.helpfulCount }
        }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.lg) {
                    // Rating Summary
                    RatingSummary(rating: product.rating)
                        .padding(.horizontal, AppTheme.Spacing.lg)

                    // Sort Picker
                    HStack {
                        Text("\(reviews.count) Reviews")
                            .font(AppTheme.Typography.subheadline)
                            .foregroundColor(AppTheme.Colors.secondaryText)

                        Spacer()

                        Menu {
                            ForEach(SortOption.allCases, id: \.self) { option in
                                Button {
                                    sortOption = option
                                } label: {
                                    HStack {
                                        Text(option.rawValue)
                                        if sortOption == option {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Text(sortOption.rawValue)
                                Image(systemName: "chevron.down")
                            }
                            .font(AppTheme.Typography.subheadline)
                            .foregroundColor(AppTheme.Colors.primaryFallback)
                        }
                    }
                    .padding(.horizontal, AppTheme.Spacing.lg)

                    // Reviews List
                    LazyVStack(spacing: AppTheme.Spacing.md) {
                        ForEach(sortedReviews) { review in
                            ReviewCard(review: review)
                        }
                    }
                    .padding(.horizontal, AppTheme.Spacing.lg)
                }
                .padding(.vertical, AppTheme.Spacing.lg)
            }
            .background(AppTheme.Colors.background)
            .navigationTitle("Reviews")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview

struct ProductReviews_Previews: PreviewProvider {
    static var previews: some View {
        ProductReviewsSection(product: ProductListingViewModel.sampleProduct)
            .padding()
    }
}
