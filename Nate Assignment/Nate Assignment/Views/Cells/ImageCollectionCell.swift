//
//  ImageCollectionCell.swift
//  Nate Assignment
//
//  Created by Kalin Spassov on 11/07/2022.
//

import Foundation
import UIKit

class ImageCollectionCell: UICollectionViewCell {
    static let identifier = "ImageCollectionCell"
    
    struct ViewModel {
        let image: String
    }
    
    @IBOutlet private weak var image: UIImageView!
    
    var viewModel: ViewModel? {
        didSet {
            guard let viewModel = viewModel else {
                return
            }
            if let url = URL(string: viewModel.image) {
                image.sd_setImage(with: url, placeholderImage: UIImage(named: Consts.noImagePlaceholder))
            } else {
                image.image = UIImage(named: Consts.noImagePlaceholder)
            }
        }
        
    }
}
