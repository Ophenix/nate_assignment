//
//  ProductModel.swift
//  Nate Assignment
//
//  Created by Kalin Spassov on 09/07/2022.
//

import Foundation

struct ProductsModelContainer: Codable {
    struct ProductModel: Codable, Hashable {
        /// Optional params where I'm not using the data.
        let id: String
        let createdAt: String?
        let updatedAt: String?
        let title: String
        let images: [String]
        let url: String
        let merchant: String?
    }
    
    let products: [ProductModel]
}
