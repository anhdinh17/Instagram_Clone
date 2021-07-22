//
//  SearchResultViewController.swift
//  Instagram
//
//  Created by Anh Dinh on 6/2/21.
//

import UIKit

protocol SearchResultViewControllerDelegate: AnyObject {
    func searchResultViewController(_ vc: SearchResultViewController, didSelectResultWith user: User)
}

class SearchResultViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    // delegate
    public weak var delegate: SearchResultViewControllerDelegate?
    
    // create an array to store [User]
    private var users = [User]()
    
    // create tableView
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    public func update(with results: [User]){
        self.users = results
        tableView.reloadData()
        tableView.isHidden = users.isEmpty // if array is empty, tableView is hidden and vice versa
    }
    
    //MARK: - TableView DataSource and Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = users[indexPath.row].username
        return cell
    }
    
    // Hiểu là: khi search ra 1 list results, bấm vào 1 result, kick off protocol. In this case, ExploreVC là delegate của class này nên sẽ execute protocol func ở bên ExploreVC.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.delegate?.searchResultViewController(self, didSelectResultWith: users[indexPath.row])
    }
}
