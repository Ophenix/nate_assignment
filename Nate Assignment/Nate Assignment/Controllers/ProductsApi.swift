//
//  ProductsApi.swift
//  Nate Assignment
//
//  Created by Kalin Spassov on 09/07/2022.
//

import Foundation
import Alamofire

class ProductsApi {
    static func fetchProducts(_ number: Int, offset: Int, completion: @escaping (Swift.Result<[ProductsContainer.ProductModel], Error>) -> Void) {
        guard let url = URL(string: ApiConsts.getProductsWithOffset) else { return } /// TODO: Handle error
        
        let request = AF.request(url)
        
        request.responseDecodable(of: ProductsContainer.self) { response in
            guard let products = response.value?.Products else { return }
            
            completion(Result.success(products))
        }
    }
}
