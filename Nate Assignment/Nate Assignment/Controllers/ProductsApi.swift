//
//  ProductsApi.swift
//  Nate Assignment
//
//  Created by Kalin Spassov on 09/07/2022.
//

import Foundation
import Alamofire

class ProductsApi {
    private struct ProductsOffsetRequestBody: Encodable {
        let skip: Int
        let take: Int
    }
    
    static func fetchProducts(_ number: Int, offset: Int, completion: @escaping (Swift.Result<[ProductsModelContainer.ProductModel], Error>) -> Void) {
        guard let url = URL(string: ApiConsts.getProductsWithOffset) else { return } /// TODO: Handle error
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        
        let parameters = ProductsOffsetRequestBody(skip: offset, take: number)
        
        let request = AF.request(url, method: .post, parameters: parameters, encoder: JSONParameterEncoder.default, headers: headers)

        request.responseDecodable(of: ProductsModelContainer.self) { response in
            guard let products = response.value?.products else { return }
            
            completion(Result.success(products))
        }
    }
}
