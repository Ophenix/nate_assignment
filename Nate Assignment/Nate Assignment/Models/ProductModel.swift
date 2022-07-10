//
//  ProductModel.swift
//  Nate Assignment
//
//  Created by Kalin Spassov on 09/07/2022.
//

import Foundation

struct ProductsModelContainer: Codable {
    struct ProductModel: Codable, Hashable {
        /// Optional params are a guess, I want the init to fail if I don't have the bare minimum needed for a product (Id, Title, Url, Images)
        /// So in case the server doesn't return the info I don't need I don't want the init to fail.
        ///
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
