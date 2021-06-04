//
//  ExploreViewController.swift
//  Instagram
//
//  Created by Anh Dinh on 4/13/21.
//

import UIKit

class ExploreViewController: UIViewController, UISearchResultsUpdating {

    private let searchVC = UISearchController(searchResultsController: SearchResultViewController())
    
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
}

extension ExploreViewController: SearchResultViewControllerDelegate {
    func searchResultViewController(_ vc: SearchResultViewController, didSelectResultWith user: User) {
        let vc = ProfileViewController(user: user)
        navigationController?.pushViewController(vc, animated: true)
    }
}
