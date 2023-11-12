//
//  Product.swift
//  EasyCommerce
//
//  Created by user on 12/11/2023.
//

import Foundation
//{
//    "id": 1,
//    "title": "Fjallraven - Foldsack No. 1 Backpack, Fits 15 Laptops",
//    "price": 109.95,
//    "description": "Your perfect pack for everyday use and walks in the forest. Stash your laptop (up to 15 inches) in the padded sleeve, your everyday",
//    "category": "men's clothing",
//    "image": "https://fakestoreapi.com/img/81fPKd-2AYL._AC_SL1500_.jpg",
//    "rating": {
//        "rate": 3.9,
//        "count": 120
//    }
//},

struct Product: Identifiable{
    let id: Int
    let title: String
    let price: Double
    let description: String
    let category: String
    let image: String
    let rating: Rating
}
