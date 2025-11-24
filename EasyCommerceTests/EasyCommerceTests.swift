//
//  EasyCommerceTests.swift
//  EasyCommerceTests
//
//  Created by Gichuki on 12/11/2023.
//
//  This is the main test entry point. Tests are organized into the following modules:
//
//  - Mocks/
//    - MockNetworkService.swift - Mock implementation of NetworkService protocol
//    - MockAuthService.swift - Mock implementation of AuthService protocol
//
//  - Helpers/
//    - TestData.swift - Test fixtures and sample data
//
//  - ViewModelTests/
//    - ProductListingViewModelTests.swift - Tests for ProductListingViewModel
//    - AuthViewModelTests.swift - Tests for AuthViewModel
//
//  - ManagerTests/
//    - NetworkManagerTests.swift - Tests for NetworkManager
//    - AuthManagerTests.swift - Tests for AuthManager
//
//  - ModelTests/
//    - ProductTests.swift - Tests for Product model
//    - CartResponseTests.swift - Tests for CartResponse model
//    - CategoryTests.swift - Tests for Category model
//    - RatingTests.swift - Tests for Rating model
//

import XCTest
@testable import EasyCommerce

/// Main test class for EasyCommerce application
final class EasyCommerceTests: XCTestCase {

    override func setUpWithError() throws {
        // Setup code called before each test method
    }

    override func tearDownWithError() throws {
        // Teardown code called after each test method
    }

    // MARK: - Smoke Tests

    /// Verify the app module can be imported
    func testModuleImport() throws {
        // This test verifies that the @testable import works correctly
        XCTAssertTrue(true, "EasyCommerce module imported successfully")
    }

    /// Verify test data is accessible
    func testTestDataAccessible() throws {
        let product = TestData.sampleProduct
        XCTAssertEqual(product.id, 1)
        XCTAssertEqual(product.title, "Test Product")
    }

    /// Verify mock services can be instantiated
    func testMockServicesInstantiable() throws {
        let mockNetworkService = MockNetworkService()
        let mockAuthService = MockAuthService()

        XCTAssertNotNil(mockNetworkService)
        XCTAssertNotNil(mockAuthService)
    }

    // MARK: - Quick Sanity Checks

    /// Verify Product model conforms to required protocols
    func testProductProtocolConformance() {
        let product = TestData.sampleProduct

        // Identifiable
        XCTAssertEqual(product.id, 1)

        // Hashable
        var productSet: Set<Product> = []
        productSet.insert(product)
        XCTAssertEqual(productSet.count, 1)

        // Codable - tested in ProductTests.swift
    }

    /// Verify ViewModels accept dependency injection
    func testDependencyInjection() {
        let mockNetworkService = MockNetworkService()
        let mockAuthService = MockAuthService()

        let productVM = ProductListingViewModel(networkManager: mockNetworkService)
        let authVM = AuthViewModel(authManager: mockAuthService)

        XCTAssertNotNil(productVM)
        XCTAssertNotNil(authVM)
    }
}
