//
//  ListViewController.swift
//  Instagram
//
//  Created by Anh Dinh on 4/13/21.
//

import UIKit

class ListViewController: UIViewController {
    
//MARK: - Variables
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(ListUserTableViewCell.self, forCellReuseIdentifier: ListUserTableViewCell.identifier)
        return tableView
    }()
    
    enum ListType {
        case followers(user: User)
        case following(user: User)
        case likers(usernames: [String])
        
        var title: String {
            switch  self {
            case .followers:
                return "Followers"
            case .following:
                return "Following"
            case .likers:
                return "Liked by"
            }
        }
    }
    
    let type: ListType
    
    var viewModel: [ListUserTableViewCellViewModel] = []
   
//MARK: - Init
    init(type: ListType){
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
  
//MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        
        title = type.title
       
        tableView.delegate = self
        tableView.dataSource = self
        
        configureViewModels()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    private func configureViewModels(){
        switch type {
        case .likers(let usernames):
            viewModel = usernames.compactMap({
                ListUserTableViewCellViewModel(imageUrl: nil, username: $0)
            })
            tableView.reloadData()
        case .followers(let targetUser):
            DatabaseManager.shared.followers(for: targetUser.username) {[weak self] usernames in
                self?.viewModel = usernames.compactMap({
                    ListUserTableViewCellViewModel(imageUrl: nil, username: $0)
                })
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        case .following(let targetUser):
            DatabaseManager.shared.following(for: targetUser.username) {[weak self] usernames in
                self?.viewModel = usernames.compactMap({
                    ListUserTableViewCellViewModel(imageUrl: nil, username: $0)
                })
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        }
    }

    
}

//MARK: - TableView DataSource and Delegate
extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ListUserTableViewCell.identifier, for: indexPath) as? ListUserTableViewCell else {
            fatalError()
        }
        cell.configure(with: viewModel[indexPath.row])
        return cell
    }
    
    // Click on the row to go the profile
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let username = viewModel[indexPath.row].username
        DatabaseManager.shared.findUser(username: username) { [weak self] user in
            if let user = user {
                DispatchQueue.main.async {
                    let vc = ProfileViewController(user: user)
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
}
