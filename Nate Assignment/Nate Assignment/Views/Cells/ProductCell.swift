//
//  ProductCell.swift
//  Nate Assignment
//
//  Created by Kalin Spassov on 09/07/2022.
//

import UIKit

class ProductCell: UICollectionViewCell {
    static let identifier = "ProductCell"
    
    struct ViewModel {
        
    }
    
    var viewModel: ViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            
        }
    }
    
}
