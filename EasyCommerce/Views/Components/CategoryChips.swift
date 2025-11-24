//
//  CategoryChips.swift
//  EasyCommerce
//
//  Horizontal scrolling category chips component
//

import SwiftUI

struct CategoryChips: View {
    let categories: [Category]
    @Binding var selectedCategory: String

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppTheme.Spacing.sm) {
                // "All" chip
                CategoryChip(
                    title: LocalizedString.allProducts,
                    icon: "square.grid.2x2",
                    isSelected: selectedCategory.isEmpty || selectedCategory == "All"
                ) {
                    withAnimation(AppTheme.Animation.quick) {
                        selectedCategory = "All"
                    }
                }

                // Category chips
                ForEach(categories) { category in
                    CategoryChip(
                        title: category.name.capitalized,
                        icon: iconFor(category: category.name),
                        isSelected: selectedCategory == category.name
                    ) {
                        withAnimation(AppTheme.Animation.quick) {
                            selectedCategory = category.name
                        }
                    }
                }
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
            .padding(.vertical, AppTheme.Spacing.sm)
        }
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
}

// MARK: - Category Chip

struct CategoryChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppTheme.Spacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))

                Text(title)
                    .font(AppTheme.Typography.subheadline)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
            .padding(.vertical, AppTheme.Spacing.md)
            .foregroundColor(isSelected ? .white : AppTheme.Colors.text)
            .background(
                Group {
                    if isSelected {
                        AppTheme.Colors.primaryGradient
                    } else {
                        Color(AppTheme.Colors.secondaryBackground)
                    }
                }
            )
            .clipShape(Capsule())
            .shadow(
                color: isSelected ? AppTheme.Colors.primaryFallback.opacity(0.3) : .clear,
                radius: 8,
                x: 0,
                y: 4
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Category Chips Skeleton

struct CategoryChipsSkeleton: View {
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppTheme.Spacing.sm) {
                ForEach(0..<5) { _ in
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.pill)
                        .fill(AppTheme.Colors.secondaryBackground)
                        .frame(width: CGFloat.random(in: 80...120), height: 40)
                        .shimmer()
                }
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
            .padding(.vertical, AppTheme.Spacing.sm)
        }
    }
}

// MARK: - Category Grid (Alternative Layout)

struct CategoryGrid: View {
    let categories: [Category]
    let onSelect: (Category) -> Void

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: AppTheme.Spacing.md) {
            ForEach(categories) { category in
                CategoryGridItem(category: category) {
                    onSelect(category)
                }
            }
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
    }
}

// MARK: - Category Grid Item

struct CategoryGridItem: View {
    let category: Category
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: AppTheme.Spacing.md) {
                // Icon
                ZStack {
                    Circle()
                        .fill(AppTheme.Colors.primaryFallback.opacity(0.1))
                        .frame(width: 60, height: 60)

                    Image(systemName: iconFor(category: category.name))
                        .font(.system(size: 24))
                        .foregroundColor(AppTheme.Colors.primaryFallback)
                }

                // Title
                Text(category.name.capitalized)
                    .font(AppTheme.Typography.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(AppTheme.Colors.text)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.lg)
            .background(AppTheme.Colors.cardBackground)
            .cornerRadius(AppTheme.CornerRadius.large)
            .shadow(
                color: AppTheme.Shadow.small.color,
                radius: AppTheme.Shadow.small.radius,
                x: AppTheme.Shadow.small.x,
                y: AppTheme.Shadow.small.y
            )
        }
        .buttonStyle(.plain)
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
}

// MARK: - Preview

struct CategoryChips_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            CategoryChips(
                categories: [
                    Category(name: "electronics"),
                    Category(name: "jewelery"),
                    Category(name: "men's clothing"),
                    Category(name: "women's clothing")
                ],
                selectedCategory: .constant("electronics")
            )

            CategoryChipsSkeleton()

            CategoryGrid(
                categories: [
                    Category(name: "electronics"),
                    Category(name: "jewelery"),
                    Category(name: "men's clothing"),
                    Category(name: "women's clothing")
                ],
                onSelect: { _ in }
            )
        }
        .background(AppTheme.Colors.background)
    }
}
