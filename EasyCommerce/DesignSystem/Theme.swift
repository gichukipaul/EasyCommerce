//
//  Theme.swift
//  EasyCommerce
//
//  Modern design system for international e-commerce
//

import SwiftUI

// MARK: - App Theme

enum AppTheme {

    // MARK: - Colors

    enum Colors {
        // Primary brand colors
        static let primary = Color("PrimaryColor", bundle: nil)
        static let primaryFallback = Color(hex: "6C5CE7")

        static let secondary = Color(hex: "00CEC9")
        static let accent = Color(hex: "FD79A8")

        // Semantic colors
        static let success = Color(hex: "00B894")
        static let warning = Color(hex: "FDCB6E")
        static let error = Color(hex: "D63031")

        // Neutral colors
        static let background = Color(UIColor.systemBackground)
        static let secondaryBackground = Color(UIColor.secondarySystemBackground)
        static let tertiaryBackground = Color(UIColor.tertiarySystemBackground)

        static let text = Color(UIColor.label)
        static let secondaryText = Color(UIColor.secondaryLabel)
        static let tertiaryText = Color(UIColor.tertiaryLabel)

        // Card colors
        static let cardBackground = Color(UIColor.secondarySystemBackground)
        static let cardShadow = Color.black.opacity(0.08)

        // Rating
        static let starFilled = Color(hex: "F1C40F")
        static let starEmpty = Color(hex: "BDC3C7")

        // Cart
        static let cartBadge = Color(hex: "E74C3C")

        // Gradient
        static let primaryGradient = LinearGradient(
            colors: [Color(hex: "6C5CE7"), Color(hex: "A29BFE")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Typography

    enum Typography {
        static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
        static let title = Font.system(size: 28, weight: .bold, design: .rounded)
        static let title2 = Font.system(size: 22, weight: .bold, design: .rounded)
        static let title3 = Font.system(size: 20, weight: .semibold, design: .rounded)
        static let headline = Font.system(size: 17, weight: .semibold, design: .rounded)
        static let body = Font.system(size: 17, weight: .regular, design: .rounded)
        static let callout = Font.system(size: 16, weight: .regular, design: .rounded)
        static let subheadline = Font.system(size: 15, weight: .regular, design: .rounded)
        static let footnote = Font.system(size: 13, weight: .regular, design: .rounded)
        static let caption = Font.system(size: 12, weight: .regular, design: .rounded)
        static let caption2 = Font.system(size: 11, weight: .regular, design: .rounded)

        // Price typography
        static let price = Font.system(size: 18, weight: .bold, design: .rounded)
        static let priceSmall = Font.system(size: 14, weight: .semibold, design: .rounded)
    }

    // MARK: - Spacing

    enum Spacing {
        static let xxs: CGFloat = 2
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
        static let xxxl: CGFloat = 32
    }

    // MARK: - Corner Radius

    enum CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let extraLarge: CGFloat = 24
        static let pill: CGFloat = 100
    }

    // MARK: - Shadows

    enum Shadow {
        static let small = ShadowStyle(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        static let medium = ShadowStyle(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        static let large = ShadowStyle(color: .black.opacity(0.12), radius: 16, x: 0, y: 8)
    }

    // MARK: - Animation

    enum Animation {
        static let quick = SwiftUI.Animation.easeInOut(duration: 0.2)
        static let standard = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let slow = SwiftUI.Animation.easeInOut(duration: 0.5)
        static let spring = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.7)
    }
}

// MARK: - Shadow Style

struct ShadowStyle {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - View Extensions

extension View {
    func cardStyle() -> some View {
        self
            .background(AppTheme.Colors.cardBackground)
            .cornerRadius(AppTheme.CornerRadius.medium)
            .shadow(
                color: AppTheme.Shadow.medium.color,
                radius: AppTheme.Shadow.medium.radius,
                x: AppTheme.Shadow.medium.x,
                y: AppTheme.Shadow.medium.y
            )
    }

    func primaryButtonStyle() -> some View {
        self
            .font(AppTheme.Typography.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.md)
            .background(AppTheme.Colors.primaryGradient)
            .cornerRadius(AppTheme.CornerRadius.medium)
    }

    func secondaryButtonStyle() -> some View {
        self
            .font(AppTheme.Typography.headline)
            .foregroundColor(AppTheme.Colors.primaryFallback)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.md)
            .background(AppTheme.Colors.primaryFallback.opacity(0.1))
            .cornerRadius(AppTheme.CornerRadius.medium)
    }

    func shimmer() -> some View {
        self.modifier(ShimmerModifier())
    }
}

// MARK: - Shimmer Effect

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        colors: [
                            .clear,
                            .white.opacity(0.4),
                            .clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width * 2)
                    .offset(x: -geometry.size.width + (geometry.size.width * 2 * phase))
                }
            )
            .clipped()
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}
