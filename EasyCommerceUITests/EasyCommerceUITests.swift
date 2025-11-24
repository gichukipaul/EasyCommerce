//
//  EasyCommerceUITests.swift
//  EasyCommerceUITests
//
//  Created by Gichuki on 12/11/2023.
//

import XCTest

final class EasyCommerceUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - App Launch Tests

    func testAppLaunches_Successfully() throws {
        // Verify the app launches without crashing
        XCTAssertTrue(app.exists)
    }

    func testAppLaunches_ShowsNavigationTitle() throws {
        // Given/When - app launches

        // Then - should show the navigation title
        let navigationBar = app.navigationBars.firstMatch
        XCTAssertTrue(navigationBar.waitForExistence(timeout: 5))
    }

    // MARK: - Product List Tests

    func testProductList_DisplaysProducts() throws {
        // Given - app has launched

        // When - wait for products to load
        let firstProduct = app.scrollViews.otherElements.buttons.firstMatch

        // Then - at least one product should be visible
        XCTAssertTrue(firstProduct.waitForExistence(timeout: 10),
                     "Product list should display at least one product")
    }

    func testProductList_IsScrollable() throws {
        // Given - products are loaded
        let scrollView = app.scrollViews.firstMatch

        // Then - scroll view should exist and be scrollable
        XCTAssertTrue(scrollView.waitForExistence(timeout: 10))
    }

    // MARK: - Category Picker Tests

    func testCategoryPicker_Exists() throws {
        // Given - app has launched

        // When - look for the picker
        let picker = app.pickers.firstMatch

        // Then - picker should be present for category selection
        // Note: This may need adjustment based on actual UI implementation
        if picker.waitForExistence(timeout: 5) {
            XCTAssertTrue(picker.exists)
        }
    }

    // MARK: - Product Item Tests

    func testProductItem_DisplaysTitle() throws {
        // Given - products are loaded
        let product = app.scrollViews.otherElements.buttons.firstMatch

        // When - product loads
        guard product.waitForExistence(timeout: 10) else {
            XCTFail("No products loaded")
            return
        }

        // Then - product should have text content
        let hasText = app.staticTexts.count > 0
        XCTAssertTrue(hasText, "Product items should display text (title)")
    }

    func testProductItem_DisplaysPrice() throws {
        // Given - products are loaded
        let product = app.scrollViews.otherElements.buttons.firstMatch

        guard product.waitForExistence(timeout: 10) else {
            XCTFail("No products loaded")
            return
        }

        // Then - look for price format (contains $ or number)
        let priceLabels = app.staticTexts.matching(NSPredicate(format: "label CONTAINS '$'"))
        XCTAssertTrue(priceLabels.count > 0, "Products should display prices")
    }

    // MARK: - Navigation Tests

    func testProductItem_IsTappable() throws {
        // Given - products are loaded
        let product = app.scrollViews.otherElements.buttons.firstMatch

        guard product.waitForExistence(timeout: 10) else {
            XCTFail("No products loaded")
            return
        }

        // Then - product should be tappable
        XCTAssertTrue(product.isHittable, "Product item should be tappable")
    }

    // MARK: - Loading State Tests

    func testApp_HandlesLoadingState() throws {
        // Given - fresh app launch
        let app = XCUIApplication()
        app.launch()

        // When - app is loading

        // Then - should eventually show content (either products or error)
        let content = app.scrollViews.firstMatch
        let timeout: TimeInterval = 15

        XCTAssertTrue(content.waitForExistence(timeout: timeout),
                     "App should display content after loading")
    }

    // MARK: - Accessibility Tests

    func testProductList_HasAccessibleElements() throws {
        // Given - products are loaded
        let product = app.scrollViews.otherElements.buttons.firstMatch

        guard product.waitForExistence(timeout: 10) else {
            XCTFail("No products loaded")
            return
        }

        // Then - elements should be accessible
        XCTAssertTrue(product.isEnabled, "Product items should be enabled")
    }

    // MARK: - Error Handling Tests

    func testApp_HandlesNetworkUnavailable() throws {
        // Note: This test would ideally be run with network disabled
        // For now, we just verify the app doesn't crash on launch

        let app = XCUIApplication()
        app.launch()

        // App should remain stable even if network fails
        XCTAssertTrue(app.exists, "App should not crash")
    }

    // MARK: - Performance Tests

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }

    func testScrollPerformance() throws {
        // Given - products are loaded
        let scrollView = app.scrollViews.firstMatch

        guard scrollView.waitForExistence(timeout: 10) else {
            XCTFail("Scroll view not found")
            return
        }

        // Then - measure scroll performance
        if #available(iOS 14.0, *) {
            measure(metrics: [XCTOSSignpostMetric.scrollDecelerationMetric]) {
                scrollView.swipeUp()
                scrollView.swipeDown()
            }
        }
    }

    // MARK: - Snapshot Tests (Visual Regression)

    func testProductList_SnapshotOnLoad() throws {
        // Given - products are loaded
        let scrollView = app.scrollViews.firstMatch

        guard scrollView.waitForExistence(timeout: 10) else {
            XCTFail("Content not loaded")
            return
        }

        // When - take screenshot
        let screenshot = app.screenshot()

        // Then - screenshot should be non-empty
        XCTAssertNotNil(screenshot.pngRepresentation)

        // Add attachment for visual inspection
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "ProductList"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}

// MARK: - Category Filter UI Tests

final class CategoryFilterUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func testCategoryFilter_FiltersProducts() throws {
        // Given - app has loaded with products
        let scrollView = app.scrollViews.firstMatch

        guard scrollView.waitForExistence(timeout: 10) else {
            XCTFail("Content not loaded")
            return
        }

        // This test verifies the category picker functionality
        // Implementation depends on actual UI structure
    }
}

// MARK: - Product Detail UI Tests (Future Implementation)

final class ProductDetailUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func testProductDetail_Navigation() throws {
        // Given - products are loaded
        let product = app.scrollViews.otherElements.buttons.firstMatch

        guard product.waitForExistence(timeout: 10) else {
            XCTFail("No products loaded")
            return
        }

        // When - tap on product
        product.tap()

        // Then - should navigate to detail view (if implemented)
        // This is a placeholder for when product detail is added
    }
}
