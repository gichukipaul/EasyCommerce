//
//  CartResponseTests.swift
//  EasyCommerceTests
//
//  Unit tests for CartResponse model
//

import XCTest
@testable import EasyCommerce

final class CartResponseTests: XCTestCase {

    // MARK: - Decoding Tests

    func testCartResponse_DecodesFromJSON() throws {
        // Given
        let json = TestData.cartResponseJSON.data(using: .utf8)!

        // When
        let cart = try JSONDecoder().decode(CartResponse.self, from: json)

        // Then
        XCTAssertEqual(cart.id, 1)
        XCTAssertEqual(cart.userID, 1)
        XCTAssertEqual(cart.date, "2023-12-01")
        XCTAssertEqual(cart.v, 0)
    }

    func testCartResponse_DecodesNestedProducts() throws {
        // Given
        let json = TestData.cartResponseJSON.data(using: .utf8)!

        // When
        let cart = try JSONDecoder().decode(CartResponse.self, from: json)

        // Then
        XCTAssertEqual(cart.products.count, 1)
        XCTAssertEqual(cart.products[0].id, 1)
    }

    func testCartResponse_DecodesCodingKeys() throws {
        // Given - JSON uses "userId" and "__v" keys
        let json = """
        {
            "id": 5,
            "userId": 42,
            "date": "2024-01-15",
            "products": [],
            "__v": 3
        }
        """.data(using: .utf8)!

        // When
        let cart = try JSONDecoder().decode(CartResponse.self, from: json)

        // Then
        XCTAssertEqual(cart.userID, 42)
        XCTAssertEqual(cart.v, 3)
    }

    func testCartResponse_FailsOnMissingUserID() {
        // Given
        let json = """
        {
            "id": 1,
            "date": "2023-12-01",
            "products": [],
            "__v": 0
        }
        """.data(using: .utf8)!

        // When/Then
        XCTAssertThrowsError(try JSONDecoder().decode(CartResponse.self, from: json))
    }

    func testCartResponse_FailsOnMissingProducts() {
        // Given
        let json = """
        {
            "id": 1,
            "userId": 1,
            "date": "2023-12-01",
            "__v": 0
        }
        """.data(using: .utf8)!

        // When/Then
        XCTAssertThrowsError(try JSONDecoder().decode(CartResponse.self, from: json))
    }

    // MARK: - Encoding Tests

    func testCartResponse_EncodesToJSON() throws {
        // Given
        let cart = TestData.sampleCartResponse

        // When
        let data = try JSONEncoder().encode(cart)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        // Then
        XCTAssertNotNil(json)
        XCTAssertEqual(json?["id"] as? Int, 1)
        XCTAssertEqual(json?["userId"] as? Int, 1)
    }

    func testCartResponse_EncodesWithCorrectKeys() throws {
        // Given
        let cart = TestData.sampleCartResponse

        // When
        let data = try JSONEncoder().encode(cart)
        let jsonString = String(data: data, encoding: .utf8)!

        // Then - verify correct key names are used
        XCTAssertTrue(jsonString.contains("\"userId\""))
        XCTAssertTrue(jsonString.contains("\"__v\""))
        XCTAssertFalse(jsonString.contains("\"userID\""))
    }

    // MARK: - Empty Products Tests

    func testCartResponse_HandlesEmptyProducts() throws {
        // Given
        let json = """
        {
            "id": 1,
            "userId": 1,
            "date": "2023-12-01",
            "products": [],
            "__v": 0
        }
        """.data(using: .utf8)!

        // When
        let cart = try JSONDecoder().decode(CartResponse.self, from: json)

        // Then
        XCTAssertTrue(cart.products.isEmpty)
    }

    // MARK: - Multiple Products Tests

    func testCartResponse_HandlesMultipleProducts() throws {
        // Given
        let json = """
        {
            "id": 1,
            "userId": 1,
            "date": "2023-12-01",
            "products": [
                {
                    "id": 1,
                    "title": "Product 1",
                    "price": 10.0,
                    "description": "First",
                    "category": "cat1",
                    "image": "img1.jpg",
                    "rating": {"rate": 4.0, "count": 10}
                },
                {
                    "id": 2,
                    "title": "Product 2",
                    "price": 20.0,
                    "description": "Second",
                    "category": "cat2",
                    "image": "img2.jpg",
                    "rating": {"rate": 5.0, "count": 20}
                }
            ],
            "__v": 0
        }
        """.data(using: .utf8)!

        // When
        let cart = try JSONDecoder().decode(CartResponse.self, from: json)

        // Then
        XCTAssertEqual(cart.products.count, 2)
        XCTAssertEqual(cart.products[0].title, "Product 1")
        XCTAssertEqual(cart.products[1].title, "Product 2")
    }

    // MARK: - Date Format Tests

    func testCartResponse_HandlesISODateFormat() throws {
        // Given
        let json = """
        {
            "id": 1,
            "userId": 1,
            "date": "2023-12-25T10:30:00.000Z",
            "products": [],
            "__v": 0
        }
        """.data(using: .utf8)!

        // When
        let cart = try JSONDecoder().decode(CartResponse.self, from: json)

        // Then
        XCTAssertEqual(cart.date, "2023-12-25T10:30:00.000Z")
    }
}
