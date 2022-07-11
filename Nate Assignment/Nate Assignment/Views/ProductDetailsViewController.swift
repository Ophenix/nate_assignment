//
//  ProductDetailsViewController.swift
//  Nate Assignment
//
//  Created by Kalin Spassov on 11/07/2022.
//

import UIKit
import SafariServices


class ProductDetailsViewController: UIViewController {
    // Consts
    static let identifier = "ProductDetailsViewController"
    private var cellSize: CGSize {
        return CGSize(width: imagesCollection.frame.size.width, height: imagesCollection.frame.size.height)
    }
    
    struct ViewModel { // Yes, this is a bit of an overkill on the naming but might as well /shrug
        let images: [String]
        let topTitle: String
        let topSubTitle: String?
        let botTitle: String?
        let botSubtitle: String?
        let link: String
    }
    
    // Outlets
    @IBOutlet private weak var imagesCollection: UICollectionView!
    @IBOutlet private weak var linkButton: UIButton!
    @IBOutlet private weak var topTitle: UILabel!
    @IBOutlet private weak var topSubtitleTitle: UILabel!
    @IBOutlet private weak var botTitle: UILabel!
    @IBOutlet private weak var botSubtitleTitle: UILabel!
    
    // Actions
    @IBAction func linkTapped(_ sender: Any) {
        guard let viewModel = viewModel,
              let url = URL(string: viewModel.link) else { return }
        let safariVC = SFSafariViewController(url: url)
        self.present(safariVC, animated: true)
    }
    
    @IBAction func doneTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    
    // Variables
    var viewModel: ViewModel?
}

// MARK: - Lifecycle methods
extension ProductDetailsViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagesCollection.delegate = self
        imagesCollection.dataSource = self
        imagesCollection.isPagingEnabled = true
        
        setupViews()
    }
}

// MARK: - Convenience methods
extension ProductDetailsViewController {
    func setupViews() {
        guard let viewModel = viewModel else { return }
        topTitle.text = viewModel.topTitle
        topSubtitleTitle.text = viewModel.topSubTitle
        botTitle.text = viewModel.botTitle
        botSubtitleTitle.text = viewModel.botSubtitle
    }
}

// MARK: - UICollectionViewDataSource
extension ProductDetailsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let viewModel = viewModel else { return 0 }
        return viewModel.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ImageCollectionCell.identifier,
            for: indexPath) as? ImageCollectionCell,
        let viewModel = viewModel else { return UICollectionViewCell() }
        
        let cellViewModel = ImageCollectionCell.ViewModel(image: viewModel.images[safe: indexPath.item] ?? Consts.noImagePlaceholder)
        cell.viewModel = cellViewModel
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ProductDetailsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
}
