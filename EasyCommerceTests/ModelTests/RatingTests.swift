//
//  RatingTests.swift
//  EasyCommerceTests
//
//  Unit tests for Rating model
//

import XCTest
@testable import EasyCommerce

final class RatingTests: XCTestCase {

    // MARK: - Initialization Tests

    func testRating_InitializesWithValues() {
        // Given/When
        let rating = Rating(rate: 4.5, count: 100)

        // Then
        XCTAssertEqual(rating.rate, 4.5)
        XCTAssertEqual(rating.count, 100)
    }

    func testRating_GeneratesUniqueID() {
        // Given/When
        let rating1 = Rating(rate: 4.5, count: 100)
        let rating2 = Rating(rate: 4.5, count: 100)

        // Then - each instance should have a unique ID
        XCTAssertNotEqual(rating1.id, rating2.id)
    }

    // MARK: - Decoding Tests

    func testRating_DecodesFromJSON() throws {
        // Given
        let json = """
        {
            "rate": 4.5,
            "count": 100
        }
        """.data(using: .utf8)!

        // When
        let rating = try JSONDecoder().decode(Rating.self, from: json)

        // Then
        XCTAssertEqual(rating.rate, 4.5)
        XCTAssertEqual(rating.count, 100)
    }

    func testRating_DecodesZeroValues() throws {
        // Given
        let json = """
        {
            "rate": 0.0,
            "count": 0
        }
        """.data(using: .utf8)!

        // When
        let rating = try JSONDecoder().decode(Rating.self, from: json)

        // Then
        XCTAssertEqual(rating.rate, 0.0)
        XCTAssertEqual(rating.count, 0)
    }

    func testRating_DecodesMaxValues() throws {
        // Given
        let json = """
        {
            "rate": 5.0,
            "count": 999999
        }
        """.data(using: .utf8)!

        // When
        let rating = try JSONDecoder().decode(Rating.self, from: json)

        // Then
        XCTAssertEqual(rating.rate, 5.0)
        XCTAssertEqual(rating.count, 999999)
    }

    func testRating_FailsOnMissingRate() {
        // Given
        let json = """
        {
            "count": 100
        }
        """.data(using: .utf8)!

        // When/Then
        XCTAssertThrowsError(try JSONDecoder().decode(Rating.self, from: json))
    }

    func testRating_FailsOnMissingCount() {
        // Given
        let json = """
        {
            "rate": 4.5
        }
        """.data(using: .utf8)!

        // When/Then
        XCTAssertThrowsError(try JSONDecoder().decode(Rating.self, from: json))
    }

    // MARK: - Encoding Tests

    func testRating_EncodesToJSON() throws {
        // Given
        let rating = Rating(rate: 3.5, count: 50)

        // When
        let data = try JSONEncoder().encode(rating)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        // Then
        XCTAssertNotNil(json)
        XCTAssertEqual(json?["rate"] as? Double, 3.5)
        XCTAssertEqual(json?["count"] as? Int, 50)
    }

    // MARK: - Identifiable Tests

    func testRating_IsIdentifiable() {
        let rating = Rating(rate: 4.0, count: 10)

        XCTAssertNotNil(rating.id)
        XCTAssertEqual(rating.id.count, 36) // UUID string length
    }

    // MARK: - Hashable Tests

    func testRating_IsHashable() {
        let rating = Rating(rate: 4.0, count: 10)

        var ratingSet: Set<Rating> = []
        ratingSet.insert(rating)

        XCTAssertEqual(ratingSet.count, 1)
    }

    // MARK: - Edge Cases

    func testRating_HandlesDecimalPrecision() throws {
        // Given
        let json = """
        {
            "rate": 3.14159265359,
            "count": 42
        }
        """.data(using: .utf8)!

        // When
        let rating = try JSONDecoder().decode(Rating.self, from: json)

        // Then
        XCTAssertEqual(rating.rate, 3.14159265359, accuracy: 0.0000001)
    }

    func testRating_HandlesNegativeRate() throws {
        // API might return invalid data - test how we handle it
        let json = """
        {
            "rate": -1.0,
            "count": 10
        }
        """.data(using: .utf8)!

        // When
        let rating = try JSONDecoder().decode(Rating.self, from: json)

        // Then - it decodes but the value is invalid
        XCTAssertEqual(rating.rate, -1.0)
    }

    func testRating_HandlesLargeCount() throws {
        // Given
        let json = """
        {
            "rate": 5.0,
            "count": 2147483647
        }
        """.data(using: .utf8)!

        // When
        let rating = try JSONDecoder().decode(Rating.self, from: json)

        // Then
        XCTAssertEqual(rating.count, 2147483647) // Int.max on 32-bit
    }
}
