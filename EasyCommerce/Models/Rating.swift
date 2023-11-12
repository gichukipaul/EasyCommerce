//
//  Rating.swift
//  EasyCommerce
//
//  Created by user on 12/11/2023.
//

import Foundation

struct Rating: Identifiable {
    let id = UUID().uuidString
    let rate: Double
    let count: Int
}
