//
//  ViewController.swift
//  Nate Assignment
//
//  Created by Kalin Spassov on 09/07/2022.
//

import UIKit

class ProductsViewController: UIViewController {
    // Outlets
    @IBOutlet weak var productsCollection: UICollectionView!
    @IBOutlet weak var updatingListView: UIView! /// This outlet isn't needed ATM but it's nice to have, i'd probably need it adding features in the future.
    @IBOutlet weak var updatingListHeightConst: NSLayoutConstraint!
    
    // Variables
    private var refresher: UIRefreshControl!
    private var refreshing = false
    private let numberOfItemsInChunk = 16
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
        
        updatingListHeightConst.constant = 0
        
        ProductsApi.fetchProducts(numberOfItemsInChunk, offset: 0, completion: fetchProductsCompletion)
        
        productsCollection.delegate = self
        productsCollection.dataSource = self
        
        refresher = UIRefreshControl()
        productsCollection.alwaysBounceVertical = true
        refresher.tintColor = UIColor.systemTeal
        refresher.addTarget(self, action: #selector(loadData), for: .valueChanged)
        productsCollection.refreshControl = refresher
        productsCollection.addSubview(refresher)
    }
}

// MARK: - Convenience methods
extension ProductsViewController {
    private func startRefreshingData() {
        if !refreshing {
            refreshing = true
            UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveEaseIn, animations:{
                self.updatingListHeightConst.constant = 30
                self.view.layoutIfNeeded()
            }, completion: { _ in
                ProductsApi.fetchProducts(self.numberOfItemsInChunk, offset: self.productsResults.count, completion: self.fetchProductsCompletion)
            })
        }
    }
    
    private func endRefreshingData() {
        if refreshing {
//            refreshing = false
            UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveEaseIn, animations:{
                self.updatingListHeightConst.constant = 0
                self.view.layoutIfNeeded()
            })
        }
        self.refreshData()
    }
    
    private func refreshData() {
        DispatchQueue.main.async {
            self.productsCollection.reloadItems(at: self.productsCollection.indexPathsForVisibleItems)
        }
    }
    
    private func stopRefresher() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.productsCollection.refreshControl?.endRefreshing()
        }
    }
}

// MARK: - Callbacks
extension ProductsViewController {
    func fetchProductsCompletion(_ result: Result<[ProductsModelContainer.ProductModel], Error>) {
        do {
            let output = try result.get()
            productsResults = productsResults.union(output)
            stopRefresher()
        }  catch let _ {
            return
        }
    }
    
    @objc func loadData() {
        self.productsCollection.refreshControl?.beginRefreshing()
        ProductsApi.fetchProducts(numberOfItemsInChunk, offset: 0, completion: fetchProductsCompletion)
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
        if indexPath.row >= productsResults.count - 1 && !refreshing {
            /// Are we in the last two items in the array?
            startRefreshingData()
        }
        
        let item = productsResults[productsResults.index(productsResults.startIndex, offsetBy: indexPath.item)]
        let viewModel = ProductCell.ViewModel(images: item.images, topTitle: item.title, botTitle: item.merchant ?? "🤔")
        cell.viewModel = viewModel
        return cell
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
                refreshing else { return }
        refreshing = false
    }
}
