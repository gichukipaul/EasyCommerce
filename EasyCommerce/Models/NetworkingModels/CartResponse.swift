//
//  CartResponse.swift
//  EasyCommerce
//
//  Created by Gichuki on 01/12/2023.
//

import Foundation
    //   let cartResponse = try? JSONDecoder().decode(CartResponse.self, from: jsonData)

    // MARK: - CartResponse
struct CartResponse: Codable {
    let id, userID: Int
    let date: String
    let products: [Product]
    let v: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case userID = "userId"
        case date, products
        case v = "__v"
    }
}

//    // MARK: - Product
//struct Product: Codable {
//    let productID, quantity: Int
//
//    enum CodingKeys: String, CodingKey {
//        case productID = "productId"
//        case quantity
//    }
//}
