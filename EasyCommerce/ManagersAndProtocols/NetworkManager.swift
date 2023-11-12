//
//  NetworkManager.swift
//  EasyCommerce
//
//  Created by Gichuki on 12/11/2023.
//

import Foundation

protocol NetworkService {
    func fetchProducts() async throws -> [Product]
}

class NetworkManager: NetworkService {
    static let shared = NetworkManager()
    private init() { }
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
