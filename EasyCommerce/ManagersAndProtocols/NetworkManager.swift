//
//  NetworkManager.swift
//  EasyCommerce
//
//  Created by Gichuki on 12/11/2023.
//

import Foundation

protocol NetworkService {
    func fetchProducts() async throws -> [Product]
    func fetchCategories() async throws -> [Category]
}

class NetworkManager: NetworkService {
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
}
