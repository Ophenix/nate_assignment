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
    
    // Variables
    private var refresher: UIRefreshControl!
    private let numberOfItemsInChunk = 16
    private var cellSize: CGSize {
        let halfWidth = productsCollection.frame.size.width / 2 - 10
        return CGSize(width: halfWidth, height: halfWidth)
    }
    private var productsResultsArray: Array<ProductsModelContainer.ProductModel> = [] {
        didSet {
            refreshData()
        }
    }
    
}

// MARK: - Lifecycle methods
extension ProductsViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            productsResultsArray = output
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
        return productsResultsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ProductCell.identifier,
            for: indexPath) as? ProductCell else { return UICollectionViewCell() }
        let item = productsResultsArray[indexPath.item] // TODO: Add safe
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
