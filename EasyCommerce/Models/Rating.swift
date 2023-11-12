//
//  Rating.swift
//  EasyCommerce
//
//  Created by Gichuki on 12/11/2023.
//

import Foundation

struct Rating: Identifiable, Codable, Hashable {
    let id = UUID().uuidString
    let rate: Double
    let count: Int
}
