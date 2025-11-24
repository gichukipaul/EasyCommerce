//
//  ProductTests.swift
//  EasyCommerceTests
//
//  Unit tests for Product model
//

import XCTest
@testable import EasyCommerce

final class ProductTests: XCTestCase {

    // MARK: - Decoding Tests

    func testProduct_DecodesFromJSON() throws {
        // Given
        let json = TestData.productJSON.data(using: .utf8)!

        // When
        let product = try JSONDecoder().decode(Product.self, from: json)

        // Then
        XCTAssertEqual(product.id, 1)
        XCTAssertEqual(product.title, "Test Product")
        XCTAssertEqual(product.price, 99.99)
        XCTAssertEqual(product.description, "A test product for unit testing")
        XCTAssertEqual(product.category, "electronics")
        XCTAssertEqual(product.image, "https://example.com/image.jpg")
    }

    func testProduct_DecodesNestedRating() throws {
        // Given
        let json = TestData.productJSON.data(using: .utf8)!

        // When
        let product = try JSONDecoder().decode(Product.self, from: json)

        // Then
        XCTAssertEqual(product.rating.rate, 4.5)
        XCTAssertEqual(product.rating.count, 100)
    }

    func testProductArray_DecodesFromJSON() throws {
        // Given
        let json = TestData.productArrayJSON.data(using: .utf8)!

        // When
        let products = try JSONDecoder().decode([Product].self, from: json)

        // Then
        XCTAssertEqual(products.count, 2)
        XCTAssertEqual(products[0].id, 1)
        XCTAssertEqual(products[1].id, 2)
    }

    func testProduct_FailsOnMissingRequiredField() {
        // Given - JSON missing "title"
        let json = """
        {
            "id": 1,
            "price": 99.99,
            "description": "Test",
            "category": "electronics",
            "image": "https://example.com/image.jpg",
            "rating": {"rate": 4.5, "count": 100}
        }
        """.data(using: .utf8)!

        // When/Then
        XCTAssertThrowsError(try JSONDecoder().decode(Product.self, from: json))
    }

    func testProduct_FailsOnMalformedJSON() {
        // Given
        let json = "{invalid}".data(using: .utf8)!

        // When/Then
        XCTAssertThrowsError(try JSONDecoder().decode(Product.self, from: json))
    }

    // MARK: - Encoding Tests

    func testProduct_EncodesToJSON() throws {
        // Given
        let product = TestData.sampleProduct

        // When
        let data = try JSONEncoder().encode(product)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        // Then
        XCTAssertNotNil(json)
        XCTAssertEqual(json?["id"] as? Int, 1)
        XCTAssertEqual(json?["title"] as? String, "Test Product")
        XCTAssertEqual(json?["price"] as? Double, 99.99)
    }

    // MARK: - Identifiable Tests

    func testProduct_IsIdentifiable() {
        let product = TestData.sampleProduct

        XCTAssertEqual(product.id, 1)
    }

    // MARK: - Hashable Tests

    func testProduct_IsHashable() {
        let product1 = TestData.sampleProduct
        let product2 = TestData.sampleProduct

        XCTAssertEqual(product1.hashValue, product2.hashValue)
    }

    func testProduct_DifferentProductsHaveDifferentHashes() {
        let product1 = TestData.sampleProduct
        let product2 = TestData.sampleProduct2

        XCTAssertNotEqual(product1.hashValue, product2.hashValue)
    }

    func testProduct_CanBeUsedInSet() {
        var productSet: Set<Product> = []

        productSet.insert(TestData.sampleProduct)
        productSet.insert(TestData.sampleProduct2)

        XCTAssertEqual(productSet.count, 2)
    }

    func testProduct_DuplicateNotAddedToSet() {
        var productSet: Set<Product> = []

        productSet.insert(TestData.sampleProduct)
        productSet.insert(TestData.sampleProduct) // Same product again

        XCTAssertEqual(productSet.count, 1)
    }

    // MARK: - Equatable Tests

    func testProduct_EqualityBasedOnHash() {
        let product1 = TestData.sampleProduct
        let product2 = TestData.sampleProduct

        XCTAssertEqual(product1, product2)
    }

    func testProduct_DifferentProductsAreNotEqual() {
        let product1 = TestData.sampleProduct
        let product2 = TestData.sampleProduct2

        XCTAssertNotEqual(product1, product2)
    }

    // MARK: - Edge Cases

    func testProduct_HandlesZeroPrice() throws {
        // Given
        let json = """
        {
            "id": 999,
            "title": "Free Item",
            "price": 0.0,
            "description": "A free item",
            "category": "electronics",
            "image": "https://example.com/free.jpg",
            "rating": {"rate": 5.0, "count": 1000}
        }
        """.data(using: .utf8)!

        // When
        let product = try JSONDecoder().decode(Product.self, from: json)

        // Then
        XCTAssertEqual(product.price, 0.0)
    }

    func testProduct_HandlesSpecialCharactersInTitle() throws {
        // Given
        let json = """
        {
            "id": 1,
            "title": "Men's \"Special\" Item <br> & More",
            "price": 10.0,
            "description": "Test",
            "category": "men's clothing",
            "image": "https://example.com/image.jpg",
            "rating": {"rate": 4.0, "count": 50}
        }
        """.data(using: .utf8)!

        // When
        let product = try JSONDecoder().decode(Product.self, from: json)

        // Then
        XCTAssertTrue(product.title.contains("Men's"))
        XCTAssertTrue(product.title.contains("\"Special\""))
    }

    func testProduct_HandlesUnicodeCharacters() throws {
        // Given
        let json = """
        {
            "id": 1,
            "title": "日本語製品 🎉",
            "price": 10.0,
            "description": "Test product with unicode",
            "category": "electronics",
            "image": "https://example.com/image.jpg",
            "rating": {"rate": 4.0, "count": 50}
        }
        """.data(using: .utf8)!

        // When
        let product = try JSONDecoder().decode(Product.self, from: json)

        // Then
        XCTAssertEqual(product.title, "日本語製品 🎉")
    }
}
