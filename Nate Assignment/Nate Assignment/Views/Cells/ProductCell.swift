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
    private static let noImagePlaceholder = "no_image"
    
    struct ViewModel {
        let images: [String]
        let topTitle: String
        let botTitle: String
    }
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var topText: UILabel!
    @IBOutlet weak var botText: UILabel!
    
    var imageNumber = 0
    var shouldRefreshImage = false
    
    var viewModel: ViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            if let firstImage = viewModel.images.first, let url = URL(string: firstImage) {
                image.sd_setImage(with: url, placeholderImage: UIImage(named: ProductCell.noImagePlaceholder))
                
                setupImageRotation()
            } else {
                image.image = UIImage(named: ProductCell.noImagePlaceholder)
            }
            
            topText.text = viewModel.topTitle
            botText.text = viewModel.botTitle
        }
    }
    
    private func setupImageRotation() {
        guard let viewModel = viewModel,
        viewModel.images.count > 1 else {
            return
        }
        shouldRefreshImage = true
        imageRotation()
    }
    
    private func imageRotation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self,
                  let viewModel = self.viewModel,
                  self.shouldRefreshImage else {
                return
            }
            
            if self.imageNumber >= viewModel.images.count - 1 {
                self.imageNumber = 0
            } else {
                self.imageNumber += 1
            }
            if let nextImage = viewModel.images[safe: self.imageNumber],
               let nextImageUrl = URL(string: nextImage) {
                self.image.sd_setImage(with: nextImageUrl, placeholderImage: UIImage(named: ProductCell.noImagePlaceholder))
            }
            self.imageRotation()
        }
    }
    
    private func endImageRotation() {
        shouldRefreshImage = false
    }
    
    override func prepareForReuse() {
        endImageRotation()
        super.prepareForReuse()
    }
}
