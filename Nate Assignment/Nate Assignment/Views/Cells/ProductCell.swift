//
//  ProductCell.swift
//  Nate Assignment
//
//  Created by Kalin Spassov on 09/07/2022.
//

import UIKit
import SDWebImage

class ProductCell: UICollectionViewCell {
    static let identifier = "ProductCell"
    
    struct ViewModel {
        let images: [String]
        let topTitle: String
        let botTitle: String
    }
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var topText: UILabel!
    @IBOutlet weak var botText: UILabel!
    
    
    var viewModel: ViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            if let firstImage = viewModel.images.first, let url = URL(string: firstImage) {
            image.sd_setImage(with: url)
            }
            
            topText.text = viewModel.topTitle
            botText.text = viewModel.botTitle
        }
    }
}
