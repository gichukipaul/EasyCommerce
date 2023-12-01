//
//  Constants.swift
//  EasyCommerce
//
//  Created by Gichuki on 12/11/2023.
//

import Foundation

struct Constants {
    struct Urls {
        static let BASE_URL = "https://fakestoreapi.com"
        static let PRODUCTS_URL = BASE_URL + "/products"
        static let CATEGORY_URL =  PRODUCTS_URL + "/categories"
        static let CART_URL = "/carts/user/1"
        static let AUTH_URL = "/auth/login"
    }
}
