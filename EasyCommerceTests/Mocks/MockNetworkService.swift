//
//  MockNetworkService.swift
//  EasyCommerceTests
//
//  Created for testing purposes
//

import Foundation
@testable import EasyCommerce

final class MockNetworkService: NetworkService {

    // MARK: - Control Properties
    var shouldThrowError = false
    var errorToThrow: Error = EasyCommerceError.INVALID_URL

    // MARK: - Stub Data
    var stubbedProducts: [Product] = []
    var stubbedCategories: [Category] = []
    var stubbedCartResponse: CartResponse?

    // MARK: - Call Tracking
    var fetchProductsCalled = false
    var fetchCategoriesCalled = false
    var fetchProductsByCategoryCalled = false
    var fetchUserCartCalled = false
    var lastCategoryRequested: String?

    // MARK: - NetworkService Implementation

    func fetchProducts() async throws -> [Product] {
        fetchProductsCalled = true
        if shouldThrowError {
            throw errorToThrow
        }
        return stubbedProducts
    }

    func fetchCategories() async throws -> [Category] {
        fetchCategoriesCalled = true
        if shouldThrowError {
            throw errorToThrow
        }
        return stubbedCategories
    }

    func fetchProductsByCategory(category: String) async throws -> [Product] {
        fetchProductsByCategoryCalled = true
        lastCategoryRequested = category
        if shouldThrowError {
            throw errorToThrow
        }
        return stubbedProducts
    }

    func fetchUserCart() async throws -> CartResponse {
        fetchUserCartCalled = true
        if shouldThrowError {
            throw errorToThrow
        }
        guard let cartResponse = stubbedCartResponse else {
            throw EasyCommerceError.INVALID_URL
        }
        return cartResponse
    }

    // MARK: - Helper Methods

    func reset() {
        shouldThrowError = false
        errorToThrow = EasyCommerceError.INVALID_URL
        stubbedProducts = []
        stubbedCategories = []
        stubbedCartResponse = nil
        fetchProductsCalled = false
        fetchCategoriesCalled = false
        fetchProductsByCategoryCalled = false
        fetchUserCartCalled = false
        lastCategoryRequested = nil
    }
}
