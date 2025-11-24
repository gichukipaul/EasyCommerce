//
//  ProductListingViewModelTests.swift
//  EasyCommerceTests
//
//  Unit tests for ProductListingViewModel
//

import XCTest
@testable import EasyCommerce

@MainActor
final class ProductListingViewModelTests: XCTestCase {

    var sut: ProductListingViewModel!
    var mockNetworkService: MockNetworkService!

    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        sut = ProductListingViewModel(networkManager: mockNetworkService)
    }

    override func tearDown() {
        sut = nil
        mockNetworkService = nil
        super.tearDown()
    }

    // MARK: - Initial State Tests

    func testInitialState_ProductsArrayIsEmpty() {
        XCTAssertTrue(sut.products.isEmpty)
    }

    func testInitialState_CategoriesArrayIsEmpty() {
        XCTAssertTrue(sut.categories.isEmpty)
    }

    func testInitialState_ErrorIsNil() {
        XCTAssertNil(sut.error)
    }

    // MARK: - fetchProducts Tests

    func testFetchProducts_CallsNetworkService() async {
        // Given
        mockNetworkService.stubbedProducts = TestData.productList

        // When
        await sut.fetchProducts()

        // Then
        XCTAssertTrue(mockNetworkService.fetchProductsCalled)
    }

    func testFetchProducts_UpdatesProductsArray() async {
        // Given
        mockNetworkService.stubbedProducts = TestData.productList

        // When
        await sut.fetchProducts()

        // Allow main queue to process
        await Task.yield()

        // Then
        XCTAssertEqual(sut.products.count, TestData.productList.count)
    }

    func testFetchProducts_ClearsErrorBeforeFetch() async {
        // Given
        sut.error = EasyCommerceError.INVALID_URL
        mockNetworkService.stubbedProducts = TestData.productList

        // When
        await sut.fetchProducts()

        // Then - error should be cleared on successful fetch
        XCTAssertNil(sut.error)
    }

    func testFetchProducts_SetsErrorOnFailure() async {
        // Given
        mockNetworkService.shouldThrowError = true
        mockNetworkService.errorToThrow = EasyCommerceError.INVALID_URL

        // When
        await sut.fetchProducts()

        // Then
        XCTAssertNotNil(sut.error)
    }

    func testFetchProducts_ProductsRemainEmptyOnError() async {
        // Given
        mockNetworkService.shouldThrowError = true

        // When
        await sut.fetchProducts()

        // Then
        XCTAssertTrue(sut.products.isEmpty)
    }

    // MARK: - fetchCategories Tests

    func testFetchCategories_CallsNetworkService() async {
        // Given
        mockNetworkService.stubbedCategories = TestData.categoryList

        // When
        await sut.fetchCategories()

        // Then
        XCTAssertTrue(mockNetworkService.fetchCategoriesCalled)
    }

    func testFetchCategories_UpdatesCategoriesArray() async {
        // Given
        mockNetworkService.stubbedCategories = TestData.categoryList

        // When
        await sut.fetchCategories()

        // Allow main queue to process
        await Task.yield()

        // Then
        XCTAssertEqual(sut.categories.count, TestData.categoryList.count)
    }

    func testFetchCategories_ClearsErrorBeforeFetch() async {
        // Given
        sut.error = EasyCommerceError.INVALID_URL
        mockNetworkService.stubbedCategories = TestData.categoryList

        // When
        await sut.fetchCategories()

        // Then
        XCTAssertNil(sut.error)
    }

    func testFetchCategories_SetsErrorOnFailure() async {
        // Given
        mockNetworkService.shouldThrowError = true

        // When
        await sut.fetchCategories()

        // Then
        XCTAssertNotNil(sut.error)
    }

    // MARK: - fetchProductsForCategory Tests

    func testFetchProductsForCategory_CallsNetworkServiceWithCorrectCategory() async {
        // Given
        let category = TestData.electronicsCategory
        mockNetworkService.stubbedProducts = [TestData.sampleProduct]

        // When
        await sut.fetchProductsFor(category: category)

        // Then
        XCTAssertTrue(mockNetworkService.fetchProductsByCategoryCalled)
        XCTAssertEqual(mockNetworkService.lastCategoryRequested, category.name)
    }

    func testFetchProductsForCategory_UpdatesProductsArray() async {
        // Given
        let category = TestData.electronicsCategory
        let expectedProducts = [TestData.sampleProduct]
        mockNetworkService.stubbedProducts = expectedProducts

        // When
        await sut.fetchProductsFor(category: category)

        // Allow main queue to process
        await Task.yield()

        // Then
        XCTAssertEqual(sut.products.count, expectedProducts.count)
    }

    func testFetchProductsForCategory_ClearsErrorBeforeFetch() async {
        // Given
        sut.error = EasyCommerceError.INVALID_URL
        let category = TestData.electronicsCategory
        mockNetworkService.stubbedProducts = [TestData.sampleProduct]

        // When
        await sut.fetchProductsFor(category: category)

        // Then
        XCTAssertNil(sut.error)
    }

    func testFetchProductsForCategory_SetsErrorOnFailure() async {
        // Given
        mockNetworkService.shouldThrowError = true
        let category = TestData.electronicsCategory

        // When
        await sut.fetchProductsFor(category: category)

        // Then
        XCTAssertNotNil(sut.error)
    }

    func testFetchProductsForCategory_HandlesSpecialCharacters() async {
        // Given
        let category = TestData.mensClothingCategory // "men's clothing"
        mockNetworkService.stubbedProducts = [TestData.mensClothingProduct]

        // When
        await sut.fetchProductsFor(category: category)

        // Then
        XCTAssertEqual(mockNetworkService.lastCategoryRequested, "men's clothing")
    }

    // MARK: - Multiple Operations Tests

    func testMultipleFetches_UpdateCorrectly() async {
        // Given
        mockNetworkService.stubbedCategories = TestData.categoryList
        mockNetworkService.stubbedProducts = TestData.productList

        // When
        await sut.fetchCategories()
        await sut.fetchProducts()

        // Allow main queue to process
        await Task.yield()

        // Then
        XCTAssertEqual(sut.categories.count, TestData.categoryList.count)
        XCTAssertEqual(sut.products.count, TestData.productList.count)
    }

    func testFetchAfterError_ClearsErrorAndFetchesSuccessfully() async {
        // Given - first call fails
        mockNetworkService.shouldThrowError = true
        await sut.fetchProducts()
        XCTAssertNotNil(sut.error)

        // When - second call succeeds
        mockNetworkService.shouldThrowError = false
        mockNetworkService.stubbedProducts = TestData.productList
        await sut.fetchProducts()

        // Allow main queue to process
        await Task.yield()

        // Then
        XCTAssertNil(sut.error)
        XCTAssertFalse(sut.products.isEmpty)
    }
}
