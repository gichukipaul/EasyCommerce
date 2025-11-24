//
//  Category.swift
//  EasyCommerce
//
//  Created by Gichuki on 12/11/2023.
//

import Foundation

struct Category: Identifiable, Codable, Hashable{
    let id = UUID().uuidString
    let name: String

    enum CodingKeys: String, CodingKey {
        case name
    }
}
