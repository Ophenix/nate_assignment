//
//  ProductCell.swift
//  Nate Assignment
//
//  Created by Kalin Spassov on 09/07/2022.
//

import UIKit
import SDWebImage

class ProductCell: UICollectionViewCell {
    // Consts
    static let identifier = "ProductCell"
    
    struct ViewModel {
        let images: [String]
        let topTitle: String
        let botTitle: String
    }
    
    // Outlets
    @IBOutlet private weak var image: UIImageView!
    @IBOutlet private weak var topText: UILabel!
    @IBOutlet private weak var botText: UILabel!
    
    // Variables
    private var imageNumber = 0
    private var shouldRefreshImage = false
    
    var viewModel: ViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            if let firstImage = viewModel.images.first, let url = URL(string: firstImage) {
                image.sd_setImage(with: url, placeholderImage: UIImage(named: Consts.noImagePlaceholder))
                
                setupImageRotation()
            } else {
                image.image = UIImage(named: Consts.noImagePlaceholder)
            }
            
            topText.text = viewModel.topTitle
            botText.text = viewModel.botTitle
        }
    }
}
// MARK: - Convenience
extension ProductCell {
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
                self.image.sd_setImage(with: nextImageUrl, placeholderImage: UIImage(named: Consts.noImagePlaceholder))
            }
            self.imageRotation()
        }
    }
    
    private func endImageRotation() {
        shouldRefreshImage = false
    }
}

// MARK: - Lifecycle
extension ProductCell {
    override func prepareForReuse() {
        endImageRotation()
        super.prepareForReuse()
    }
}
