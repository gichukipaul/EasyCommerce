//
//  OnboardingView.swift
//  EasyCommerce
//
//  First-time user onboarding flow
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var userManager: UserManager
    @State private var currentPage = 0

    let pages: [OnboardingPage] = [
        OnboardingPage(
            image: "cart.fill",
            title: "Shop the World",
            description: "Discover millions of products from sellers around the globe. Your perfect item is just a tap away.",
            color: Color(hex: "6C5CE7")
        ),
        OnboardingPage(
            image: "globe.americas.fill",
            title: "International Shipping",
            description: "We ship to over 200 countries. No matter where you are, we'll deliver to your doorstep.",
            color: Color(hex: "00CEC9")
        ),
        OnboardingPage(
            image: "lock.shield.fill",
            title: "Secure Payments",
            description: "Shop with confidence. Your payment information is always protected with bank-level security.",
            color: Color(hex: "FD79A8")
        ),
        OnboardingPage(
            image: "star.fill",
            title: "Earn Rewards",
            description: "Get points on every purchase. Redeem them for discounts, free shipping, and exclusive deals.",
            color: Color(hex: "FDCB6E")
        )
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Page Content
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    OnboardingPageView(page: pages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentPage)

            // Bottom Section
            VStack(spacing: AppTheme.Spacing.xl) {
                // Page Indicator
                HStack(spacing: AppTheme.Spacing.sm) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Capsule()
                            .fill(index == currentPage ? AppTheme.Colors.primaryFallback : AppTheme.Colors.secondaryText.opacity(0.3))
                            .frame(width: index == currentPage ? 24 : 8, height: 8)
                            .animation(.spring(), value: currentPage)
                    }
                }

                // Buttons
                VStack(spacing: AppTheme.Spacing.md) {
                    if currentPage == pages.count - 1 {
                        // Last page - show Get Started
                        Button {
                            userManager.completeOnboarding()
                        } label: {
                            Text("Get Started")
                                .primaryButtonStyle()
                        }
                    } else {
                        // Continue button
                        Button {
                            withAnimation {
                                currentPage += 1
                            }
                        } label: {
                            Text("Continue")
                                .primaryButtonStyle()
                        }
                    }

                    // Skip button
                    if currentPage < pages.count - 1 {
                        Button {
                            userManager.completeOnboarding()
                        } label: {
                            Text("Skip")
                                .font(AppTheme.Typography.subheadline)
                                .foregroundColor(AppTheme.Colors.secondaryText)
                        }
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.lg)
            }
            .padding(.bottom, AppTheme.Spacing.xxxl)
        }
        .background(AppTheme.Colors.background)
    }
}

// MARK: - Onboarding Page Model

struct OnboardingPage {
    let image: String
    let title: String
    let description: String
    let color: Color
}

// MARK: - Onboarding Page View

struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: AppTheme.Spacing.xxl) {
            Spacer()

            // Icon
            ZStack {
                Circle()
                    .fill(page.color.opacity(0.15))
                    .frame(width: 200, height: 200)

                Circle()
                    .fill(page.color.opacity(0.3))
                    .frame(width: 150, height: 150)

                Image(systemName: page.image)
                    .font(.system(size: 70))
                    .foregroundColor(page.color)
            }

            // Text Content
            VStack(spacing: AppTheme.Spacing.md) {
                Text(page.title)
                    .font(AppTheme.Typography.title)
                    .foregroundColor(AppTheme.Colors.text)
                    .multilineTextAlignment(.center)

                Text(page.description)
                    .font(AppTheme.Typography.body)
                    .foregroundColor(AppTheme.Colors.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppTheme.Spacing.xl)
            }

            Spacer()
            Spacer()
        }
    }
}

// MARK: - Preview

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
            .environmentObject(UserManager.shared)
    }
}
