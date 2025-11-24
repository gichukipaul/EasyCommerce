//
//  CategoryTests.swift
//  EasyCommerceTests
//
//  Unit tests for Category model
//

import XCTest
@testable import EasyCommerce

final class CategoryTests: XCTestCase {

    // MARK: - Initialization Tests

    func testCategory_InitializesWithName() {
        // Given/When
        let category = Category(name: "electronics")

        // Then
        XCTAssertEqual(category.name, "electronics")
    }

    func testCategory_GeneratesUniqueID() {
        // Given/When
        let category1 = Category(name: "electronics")
        let category2 = Category(name: "electronics")

        // Then - each instance should have a unique ID
        XCTAssertNotEqual(category1.id, category2.id)
    }

    func testCategory_IDIsUUIDString() {
        // Given/When
        let category = Category(name: "test")

        // Then
        XCTAssertFalse(category.id.isEmpty)
        // UUID strings are 36 characters (32 hex + 4 dashes)
        XCTAssertEqual(category.id.count, 36)
    }

    // MARK: - Identifiable Tests

    func testCategory_IsIdentifiable() {
        let category = Category(name: "test")

        // Should be usable as Identifiable
        XCTAssertNotNil(category.id)
    }

    // MARK: - Hashable Tests

    func testCategory_IsHashable() {
        let category = Category(name: "electronics")

        // Should be usable in hashed collections
        var categorySet: Set<Category> = []
        categorySet.insert(category)

        XCTAssertEqual(categorySet.count, 1)
    }

    func testCategory_SameNameDifferentInstances_AreNotEqual() {
        // Due to unique UUID generation, two categories with same name are different
        let category1 = Category(name: "electronics")
        let category2 = Category(name: "electronics")

        // They should NOT be equal because IDs are different
        XCTAssertNotEqual(category1, category2)
    }

    // MARK: - Special Characters Tests

    func testCategory_HandlesSpecialCharacters() {
        // Given/When
        let category = Category(name: "men's clothing")

        // Then
        XCTAssertEqual(category.name, "men's clothing")
    }

    func testCategory_HandlesUnicode() {
        // Given/When
        let category = Category(name: "日本語カテゴリ")

        // Then
        XCTAssertEqual(category.name, "日本語カテゴリ")
    }

    func testCategory_HandlesEmptyName() {
        // Given/When
        let category = Category(name: "")

        // Then
        XCTAssertEqual(category.name, "")
    }

    // MARK: - Collection Usage Tests

    func testCategory_CanBeUsedInArray() {
        // Given
        let categories = [
            Category(name: "electronics"),
            Category(name: "jewelery"),
            Category(name: "men's clothing"),
            Category(name: "women's clothing")
        ]

        // Then
        XCTAssertEqual(categories.count, 4)
    }

    func testCategory_CanBeFilteredByName() {
        // Given
        let categories = TestData.categoryList

        // When
        let filtered = categories.filter { $0.name.contains("clothing") }

        // Then
        XCTAssertEqual(filtered.count, 2)
    }

    // MARK: - Note on Codable

    // Note: Category has a generated UUID which makes encoding/decoding tricky
    // When decoded, the UUID will be regenerated, making round-trip encoding
    // produce different objects. This is by design for this use case.

    func testCategory_EncodesCorrectly() throws {
        // Given
        let category = Category(name: "electronics")

        // When
        let data = try JSONEncoder().encode(category)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        // Then
        XCTAssertNotNil(json)
        XCTAssertEqual(json?["name"] as? String, "electronics")
        XCTAssertNotNil(json?["id"]) // ID should be encoded
    }
}
