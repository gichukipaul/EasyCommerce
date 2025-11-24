//
//  OrderHistoryView.swift
//  EasyCommerce
//
//  User's order history and tracking
//

import SwiftUI

struct OrderHistoryView: View {
    @EnvironmentObject var orderManager: OrderManager
    @State private var selectedFilter: OrderFilter = .all

    enum OrderFilter: String, CaseIterable {
        case all = "All"
        case active = "Active"
        case completed = "Completed"
    }

    var filteredOrders: [Order] {
        switch selectedFilter {
        case .all: return orderManager.orders
        case .active: return orderManager.activeOrders
        case .completed: return orderManager.completedOrders
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Filter Tabs
                filterTabs

                if filteredOrders.isEmpty {
                    emptyView
                } else {
                    ordersList
                }
            }
            .navigationTitle("My Orders")
            .navigationBarTitleDisplayMode(.large)
            .background(AppTheme.Colors.background)
        }
    }

    private var filterTabs: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            ForEach(OrderFilter.allCases, id: \.self) { filter in
                Button {
                    withAnimation(AppTheme.Animation.quick) {
                        selectedFilter = filter
                    }
                } label: {
                    Text(filter.rawValue)
                        .font(AppTheme.Typography.subheadline.weight(selectedFilter == filter ? .semibold : .regular))
                        .foregroundColor(selectedFilter == filter ? .white : AppTheme.Colors.text)
                        .padding(.horizontal, AppTheme.Spacing.lg)
                        .padding(.vertical, AppTheme.Spacing.sm)
                        .background(
                            selectedFilter == filter ?
                            AnyView(AppTheme.Colors.primaryGradient) :
                            AnyView(AppTheme.Colors.secondaryBackground)
                        )
                        .clipShape(Capsule())
                }
            }
        }
        .padding(AppTheme.Spacing.lg)
    }

    private var emptyView: some View {
        VStack(spacing: AppTheme.Spacing.xl) {
            Spacer()

            Image(systemName: "shippingbox")
                .font(.system(size: 80))
                .foregroundColor(AppTheme.Colors.tertiaryText)

            Text("No orders yet")
                .font(AppTheme.Typography.title3)
                .foregroundColor(AppTheme.Colors.secondaryText)

            Text("When you place an order, it will appear here")
                .font(AppTheme.Typography.subheadline)
                .foregroundColor(AppTheme.Colors.tertiaryText)

            Spacer()
        }
    }

    private var ordersList: some View {
        ScrollView {
            LazyVStack(spacing: AppTheme.Spacing.md) {
                ForEach(filteredOrders) { order in
                    NavigationLink {
                        OrderDetailView(order: order)
                    } label: {
                        OrderCard(order: order)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(AppTheme.Spacing.lg)
        }
    }
}

// MARK: - Order Card

struct OrderCard: View {
    let order: Order

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
                    Text(order.orderNumber)
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(AppTheme.Colors.text)

                    Text(order.formattedDate)
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.Colors.secondaryText)
                }

                Spacer()

                // Status Badge
                HStack(spacing: AppTheme.Spacing.xs) {
                    Image(systemName: order.status.icon)
                    Text(order.status.rawValue)
                }
                .font(AppTheme.Typography.caption)
                .foregroundColor(order.status.color)
                .padding(.horizontal, AppTheme.Spacing.sm)
                .padding(.vertical, AppTheme.Spacing.xs)
                .background(order.status.color.opacity(0.1))
                .clipShape(Capsule())
            }

            Divider()

            // Items Preview
            HStack(spacing: AppTheme.Spacing.sm) {
                ForEach(order.items.prefix(3)) { item in
                    AsyncImage(url: URL(string: item.product.image)) { phase in
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
                    .frame(width: 50, height: 50)
                    .background(Color.white)
                    .cornerRadius(AppTheme.CornerRadius.small)
                }

                if order.items.count > 3 {
                    Text("+\(order.items.count - 3)")
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.Colors.secondaryText)
                        .frame(width: 50, height: 50)
                        .background(AppTheme.Colors.secondaryBackground)
                        .cornerRadius(AppTheme.CornerRadius.small)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: AppTheme.Spacing.xxs) {
                    Text("\(order.itemCount) items")
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.Colors.secondaryText)

                    PriceView(amount: order.total, size: .small)
                }
            }

            // Delivery info
            if let delivery = order.formattedEstimatedDelivery, order.status != .delivered {
                HStack {
                    Image(systemName: "truck.box")
                        .foregroundColor(AppTheme.Colors.secondaryText)
                    Text("Est. delivery: \(delivery)")
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.Colors.secondaryText)
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

// MARK: - Order Detail View

struct OrderDetailView: View {
    let order: Order

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.lg) {
                // Status Card
                VStack(spacing: AppTheme.Spacing.md) {
                    Image(systemName: order.status.icon)
                        .font(.system(size: 40))
                        .foregroundColor(order.status.color)

                    Text(order.status.rawValue)
                        .font(AppTheme.Typography.title3)
                        .foregroundColor(AppTheme.Colors.text)

                    if let delivery = order.formattedEstimatedDelivery {
                        Text("Estimated delivery: \(delivery)")
                            .font(AppTheme.Typography.subheadline)
                            .foregroundColor(AppTheme.Colors.secondaryText)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(AppTheme.Spacing.xl)
                .background(AppTheme.Colors.cardBackground)
                .cornerRadius(AppTheme.CornerRadius.large)

                // Order Items
                VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                    Text("Order Items")
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(AppTheme.Colors.text)

                    ForEach(order.items) { item in
                        OrderItemRow(item: item)
                    }
                }
                .padding(AppTheme.Spacing.lg)
                .background(AppTheme.Colors.cardBackground)
                .cornerRadius(AppTheme.CornerRadius.large)

                // Order Summary
                VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                    Text("Order Summary")
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(AppTheme.Colors.text)

                    summaryRow("Subtotal", value: order.subtotal)
                    summaryRow("Shipping", value: order.shippingCost, isFree: order.shippingCost == 0)
                    Divider()
                    HStack {
                        Text("Total")
                            .font(AppTheme.Typography.headline)
                        Spacer()
                        PriceView(amount: order.total, size: .medium)
                    }
                }
                .padding(AppTheme.Spacing.lg)
                .background(AppTheme.Colors.cardBackground)
                .cornerRadius(AppTheme.CornerRadius.large)

                // Order Info
                VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                    Text("Order Information")
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(AppTheme.Colors.text)

                    infoRow("Order Number", value: order.orderNumber)
                    infoRow("Order Date", value: order.formattedDate)
                    if let tracking = order.trackingNumber {
                        infoRow("Tracking Number", value: tracking)
                    }
                }
                .padding(AppTheme.Spacing.lg)
                .background(AppTheme.Colors.cardBackground)
                .cornerRadius(AppTheme.CornerRadius.large)
            }
            .padding(AppTheme.Spacing.lg)
        }
        .background(AppTheme.Colors.background)
        .navigationTitle(order.orderNumber)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func summaryRow(_ title: String, value: Double, isFree: Bool = false) -> some View {
        HStack {
            Text(title)
                .font(AppTheme.Typography.subheadline)
                .foregroundColor(AppTheme.Colors.secondaryText)
            Spacer()
            if isFree {
                Text("Free")
                    .font(AppTheme.Typography.subheadline)
                    .foregroundColor(AppTheme.Colors.success)
            } else {
                Text(CurrencyFormatter.shared.format(value))
                    .font(AppTheme.Typography.subheadline)
                    .foregroundColor(AppTheme.Colors.text)
            }
        }
    }

    private func infoRow(_ title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(AppTheme.Typography.subheadline)
                .foregroundColor(AppTheme.Colors.secondaryText)
            Spacer()
            Text(value)
                .font(AppTheme.Typography.subheadline)
                .foregroundColor(AppTheme.Colors.text)
        }
    }
}

// MARK: - Order Item Row

struct OrderItemRow: View {
    let item: OrderItem

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            AsyncImage(url: URL(string: item.product.image)) { phase in
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
            .frame(width: 60, height: 60)
            .background(Color.white)
            .cornerRadius(AppTheme.CornerRadius.small)

            VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
                Text(item.product.title)
                    .font(AppTheme.Typography.subheadline)
                    .foregroundColor(AppTheme.Colors.text)
                    .lineLimit(2)

                Text("Qty: \(item.quantity)")
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.Colors.secondaryText)
            }

            Spacer()

            PriceView(amount: item.total, size: .small)
        }
    }
}

// MARK: - Preview

struct OrderHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        OrderHistoryView()
            .environmentObject(OrderManager.shared)
    }
}
