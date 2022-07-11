//
//  ViewController.swift
//  Nate Assignment
//
//  Created by Kalin Spassov on 09/07/2022.
//

import UIKit
import SafariServices

class ProductsViewController: UIViewController {
    // Consts
    private static let numberOfItemsInChunk = 16
    private static let animationDuration = 0.3
    
    // Outlets
    @IBOutlet weak var productsCollection: UICollectionView!
    @IBOutlet weak var updatingListView: UIView! /// This outlet isn't needed ATM but i'd probably need it adding features in the future.
    @IBOutlet weak var updatingListHeightConst: NSLayoutConstraint!
    
    // Variables
    private var refreshControl: UIRefreshControl!
    private var currentlyRefreshing = false
    
    private var cellSize: CGSize {
        let halfWidth = productsCollection.frame.size.width / 2 - 10
        return CGSize(width: halfWidth, height: halfWidth)
    }
    private var productsResults: Set<ProductsModelContainer.ProductModel> = [] {
        didSet {
            endRefreshingData()
        }
    }
}

// MARK: - Lifecycle methods
extension ProductsViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// I could set this in storyboard but it won't be visible to other devs which defeats the point.
        updatingListHeightConst.constant = 0
        
        ProductsApi.fetchProducts(Self.numberOfItemsInChunk, offset: 0, completion: fetchProductsCompletion)
        
        productsCollection.delegate = self
        productsCollection.dataSource = self
        
        setupRefreshControl()
    }
}

// MARK: - Convenience methods
extension ProductsViewController {
    private func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        productsCollection.alwaysBounceVertical = true
        refreshControl.tintColor = UIColor.systemTeal
        refreshControl.addTarget(self, action: #selector(loadData), for: .valueChanged)
        productsCollection.refreshControl = refreshControl
        productsCollection.addSubview(refreshControl)
    }
    
    private func fetchAdditionalData() {
        if !currentlyRefreshing {
            currentlyRefreshing = true
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseIn, animations: { [weak self] in
                guard let self = self else { return }
                self.updatingListHeightConst.constant = 30
                self.view.layoutIfNeeded()
            }, completion: { _ in
                ProductsApi.fetchProducts(Self.numberOfItemsInChunk, offset: self.productsResults.count, completion: self.fetchProductsCompletion)
            })
        }
    }
    
    private func endRefreshingData() {
        if currentlyRefreshing {
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseIn, animations: { [weak self] in
                guard let self = self else { return }
                self.updatingListHeightConst.constant = 0
                self.view.layoutIfNeeded()
            })
        }
        self.refreshCollection()
    }
    
    private func refreshCollection() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.productsCollection.reloadItems(at: self.productsCollection.indexPathsForVisibleItems)
        }
    }
    
    private func stopRefresher() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            self.productsCollection.refreshControl?.endRefreshing()
        }
    }
}

// MARK: - Callbacks
extension ProductsViewController {
    private func fetchProductsCompletion(_ result: Result<[ProductsModelContainer.ProductModel], Error>) {
        do {
            let output = try result.get()
            productsResults = productsResults.union(output)
            stopRefresher()
        }  catch let _ { // TODO: Handle errors
            return
        }
    }
    
    @objc func loadData() {
        self.productsCollection.refreshControl?.beginRefreshing()
        ProductsApi.fetchProducts(Self.numberOfItemsInChunk, offset: 0, completion: fetchProductsCompletion)
    }
}

// MARK: - UICollectionViewDataSource
extension ProductsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return productsResults.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ProductCell.identifier,
            for: indexPath) as? ProductCell else { return UICollectionViewCell() }
        if indexPath.row >= productsResults.count - 1 && !currentlyRefreshing {
            /// Are we in the last items in the array?
            fetchAdditionalData()
        }
        
        let item = productsResults[productsResults.index(productsResults.startIndex, offsetBy: indexPath.item)]
        let viewModel = ProductCell.ViewModel(images: item.images, topTitle: item.title, botTitle: item.merchant ?? "🤔")
        cell.viewModel = viewModel
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let url = URL(string: productsResults[productsResults.index(productsResults.startIndex, offsetBy: indexPath.item)].url) else { return }
        let safariVC = SFSafariViewController(url: url)
        self.present(safariVC, animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ProductsViewController: UICollectionViewDelegateFlowLayout {
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

// MARK: - UIScrollViewDelegate
extension ProductsViewController: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollViewDidEndDecelerating(scrollView)
        }
    }
    
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        scrollViewDidEndDecelerating(scrollView)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let last = productsCollection.indexPathsForVisibleItems.last,
              last.item < productsResults.count - 2,
              currentlyRefreshing else { return }
        currentlyRefreshing = false
    }
}
