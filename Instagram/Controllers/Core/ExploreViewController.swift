//
//  ExploreViewController.swift
//  Instagram
//
//  Created by Anh Dinh on 4/13/21.
//

import UIKit

class ExploreViewController: UIViewController, UISearchResultsUpdating {

    // Search bar
    private let searchVC = UISearchController(searchResultsController: SearchResultViewController())
    
    // CollectionView
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewCompositionalLayout { (index, _) -> NSCollectionLayoutSection? in
            let item = NSCollectionLayoutItem(
                layoutSize:NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
                                                  heightDimension: .fractionalHeight(1)))
            
            let fullItem = NSCollectionLayoutItem(
                layoutSize:NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                  heightDimension: .fractionalHeight(0.5)))
            
            let tripletItem = NSCollectionLayoutItem(
                layoutSize:NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.33),
                                                  heightDimension: .fractionalHeight(1)))
            
            // group này xài 2 fullItem
            let verticalGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
                                                   heightDimension: .fractionalHeight(1)),
                subitem: fullItem,
                count: 2)
            
            let horizontalGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(160)),
                    subitems: [item, verticalGroup])
            
            let threeItemGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(160)),
                    subitem: tripletItem,
                    count: 3
            )
                
            let finalGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(320)),
                    subitems: [horizontalGroup,threeItemGroup]
            )
            
            // return as 1 section
            return NSCollectionLayoutSection(group: finalGroup)
        }
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.register(PhotoCollectionViewCell.self,
                                forCellWithReuseIdentifier: PhotoCollectionViewCell.identifier)
        return collectionView
    }()
    
    // create an array of [Post] to receive data from FB khi chạy DatabaseManager.explorePosts
    private var posts = [Post]()
    
    
//MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Explore"
        view.backgroundColor = .systemBackground
        
        // ko hiểu dòng này ----> delegate để xài protocol của thằng SearchResultVC
        (searchVC.searchResultsController as? SearchResultViewController)?.delegate = self
        
        // delegate for protocol used for searchController
        searchVC.searchResultsUpdater = self
        
        searchVC.searchBar.placeholder = "Search For User"
        // add searchVC to navigation bar, add search bar lên nav bar
        navigationItem.searchController = searchVC
        
        // add subviews of CollectionView
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Fetchdata
        fetchdata()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
  
    // Delegate func for UISearchResultsUpdating
    // this is called every time users tap on keyboard key
    func updateSearchResults(for searchController: UISearchController) {
        guard let resultsVC = searchController.searchResultsController as? SearchResultViewController,
              let query = searchController.searchBar.text,// text from search bar
              !query.trimmingCharacters(in: .whitespaces).isEmpty // make sure query is not empty
        else
        { return}
        
        DatabaseManager.shared.findUsers(with: query) { (results) in
            DispatchQueue.main.async {
                resultsVC.update(with: results)
            }
        }
    }
    
    //MARK: - FetchData
    func fetchdata(){
        DatabaseManager.shared.explorePosts { [weak self] (posts) in
            self?.posts = posts
            self?.collectionView.reloadData()
        }
    }
    
}

// Protocol from SearchResultViewControllerDelegate
extension ExploreViewController: SearchResultViewControllerDelegate {
    func searchResultViewController(_ vc: SearchResultViewController, didSelectResultWith user: User) {
        let vc = ProfileViewController(user: user)
        navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: - Delegate and DataSoure of collectionView
extension ExploreViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.identifier, for: indexPath) as? PhotoCollectionViewCell else{
            fatalError()
        }
        // mỗi item của posts array là 1 Post instance
        var model = posts[indexPath.row]
        
        cell.configure(with: URL(string: model.postUrlString))
        return cell
    }
    
    // Tap on a cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let post = posts[indexPath.row]
        var vc = PostViewController(post: post)
        navigationController?.pushViewController(vc, animated: true)
    }
}
