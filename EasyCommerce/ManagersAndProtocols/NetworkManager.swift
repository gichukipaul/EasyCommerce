//
//  NetworkManager.swift
//  EasyCommerce
//
//  Created by Gichuki on 12/11/2023.
//

import Foundation

enum EasyCommerceError : Error {
    case INVALID_URL
}

protocol NetworkService {
    func fetchProducts() async throws -> [Product]
    func fetchCategories() async throws -> [Category]
    func fetchProductsByCategory(category: String) async throws -> [Product]
    func fetchUserCart() async throws -> CartResponse
}

final class NetworkManager: NetworkService {
    
    static let shared = NetworkManager()
    private init() { }
    
    func fetchCategories() async throws -> [Category] {
        let url = Constants.Urls.CATEGORY_URL
        
        guard let url = URL(string: url) else {
            print(" INVALID URL")
            return []
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        let list = try JSONDecoder().decode([String].self, from: data)
            // Create an array of Category objects using the names from the response
        let categories = list.map { Category(name: $0) }
        
        return categories
    }
    
    func fetchProducts() async throws-> [Product] {
        let url = Constants.Urls.PRODUCTS_URL
        
        guard let url = URL(string: url) else {
            print("ERROR : INVALID URL")
            return []
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        let products = try JSONDecoder().decode([Product].self, from: data)
        
        return products
    }
    
    func fetchProductsByCategory(category: String) async throws -> [Product] {
        let url =  Constants.Urls.PRODUCTS_URL
        var finalUrl: String {
            switch category {
                case "electronics":
                    return url + "/category/electronics"
                case "jewelery":
                    return url + "/category/jewelery"
                case "men's clothing":
                    return url + "/category/" + category.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
                case "women's clothing":
                    return url + "/category/" + category.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
                default:
                    return url
            }
        }
        
        guard let url = URL(string: finalUrl) else {
            print("ERROR: invalid url")
            return []
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        return try JSONDecoder().decode([Product].self, from: data)
    }
    
    func fetchUserCart() async throws -> CartResponse {
        guard let url = URL(string: Constants.Urls.CART_URL) else {
            print("Eror: NO VALI URL")
            throw EasyCommerceError.INVALID_URL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        return try JSONDecoder().decode(CartResponse.self, from: data)
    }
}
