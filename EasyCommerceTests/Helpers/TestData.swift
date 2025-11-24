//
//  TestData.swift
//  EasyCommerceTests
//
//  Test fixtures and sample data for unit tests
//

import Foundation
@testable import EasyCommerce

enum TestData {

    // MARK: - Sample Rating
    static let sampleRating = Rating(rate: 4.5, count: 100)
    static let lowRating = Rating(rate: 2.0, count: 10)

    // MARK: - Sample Products
    static let sampleProduct = Product(
        id: 1,
        title: "Test Product",
        price: 99.99,
        description: "A test product for unit testing",
        category: "electronics",
        image: "https://example.com/image.jpg",
        rating: sampleRating
    )

    static let sampleProduct2 = Product(
        id: 2,
        title: "Another Product",
        price: 49.99,
        description: "Another test product",
        category: "jewelery",
        image: "https://example.com/image2.jpg",
        rating: lowRating
    )

    static let mensClothingProduct = Product(
        id: 3,
        title: "Men's Shirt",
        price: 29.99,
        description: "A nice shirt",
        category: "men's clothing",
        image: "https://example.com/shirt.jpg",
        rating: sampleRating
    )

    static let womensClothingProduct = Product(
        id: 4,
        title: "Women's Dress",
        price: 59.99,
        description: "A beautiful dress",
        category: "women's clothing",
        image: "https://example.com/dress.jpg",
        rating: sampleRating
    )

    static let productList: [Product] = [
        sampleProduct,
        sampleProduct2,
        mensClothingProduct,
        womensClothingProduct
    ]

    // MARK: - Sample Categories
    static let electronicsCategory = Category(name: "electronics")
    static let jeweleryCategory = Category(name: "jewelery")
    static let mensClothingCategory = Category(name: "men's clothing")
    static let womensClothingCategory = Category(name: "women's clothing")

    static let categoryList: [Category] = [
        electronicsCategory,
        jeweleryCategory,
        mensClothingCategory,
        womensClothingCategory
    ]

    // MARK: - Sample Cart Response
    static let sampleCartResponse = CartResponse(
        id: 1,
        userID: 1,
        date: "2023-12-01",
        products: [sampleProduct, sampleProduct2],
        v: 0
    )

    // MARK: - Sample Login Response
    static let sampleLoginResponse = LogInResponse(token: "test-jwt-token-12345")

    // MARK: - JSON Strings for Serialization Tests

    static let productJSON = """
    {
        "id": 1,
        "title": "Test Product",
        "price": 99.99,
        "description": "A test product for unit testing",
        "category": "electronics",
        "image": "https://example.com/image.jpg",
        "rating": {
            "rate": 4.5,
            "count": 100
        }
    }
    """

    static let productArrayJSON = """
    [
        {
            "id": 1,
            "title": "Test Product",
            "price": 99.99,
            "description": "A test product",
            "category": "electronics",
            "image": "https://example.com/image.jpg",
            "rating": {"rate": 4.5, "count": 100}
        },
        {
            "id": 2,
            "title": "Another Product",
            "price": 49.99,
            "description": "Another test product",
            "category": "jewelery",
            "image": "https://example.com/image2.jpg",
            "rating": {"rate": 2.0, "count": 10}
        }
    ]
    """

    static let categoriesJSON = """
    ["electronics", "jewelery", "men's clothing", "women's clothing"]
    """

    static let cartResponseJSON = """
    {
        "id": 1,
        "userId": 1,
        "date": "2023-12-01",
        "products": [
            {
                "id": 1,
                "title": "Test Product",
                "price": 99.99,
                "description": "A test product",
                "category": "electronics",
                "image": "https://example.com/image.jpg",
                "rating": {"rate": 4.5, "count": 100}
            }
        ],
        "__v": 0
    }
    """

    static let loginResponseJSON = """
    {
        "token": "test-jwt-token-12345"
    }
    """

    static let loginRequestJSON = """
    {
        "username": "testuser",
        "password": "testpass"
    }
    """
}
