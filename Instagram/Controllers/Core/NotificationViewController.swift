//
//  NotificationViewController.swift
//  Instagram
//
//  Created by Anh Dinh on 4/13/21.
//

import UIKit

class NotificationViewController: UIViewController {

    private let noActivityLabel: UILabel = {
        let label = UILabel()
        label.text = "No Notifications"
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.isHidden = true
        table.register(LikeNotificationTableViewCell.self,
                       forCellReuseIdentifier:LikeNotificationTableViewCell.identifier)
        table.register(CommentNotificationTableViewCell.self,
                       forCellReuseIdentifier:CommentNotificationTableViewCell.identifier)
        table.register(FollowNotificationTableViewCell.self,
                       forCellReuseIdentifier:FollowNotificationTableViewCell.identifier)
        return table
    }()
    
    private var viewModels: [NotificationCellType] = []
  
//MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Notifications"
        view.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(noActivityLabel)
        
        fetchNotifications()
        
        mockData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.frame = view.bounds
        
        noActivityLabel.sizeToFit()
        noActivityLabel.center = view.center
    }
    
    private func fetchNotifications(){
//        noActivityLabel.isHidden = false
    }
    
    private func mockData(){
        tableView.isHidden = false
        guard let postUrlString = URL(string: "https://iosacademy.io/assets/images/courses/swiftui.png") else {return}
        guard let iconUrlString = URL(string:"https://iosacademy.io/assets/images/brand/icon.jpg") else {return}
        
        viewModels = [
            .like(viewModel: LikeNotificationCellViewModel(username: "",
                                                           profilePictureUrl: iconUrlString,
                                                           postUrl: postUrlString)),
            .comment(viewModel: CommentNotificationCellViewModel(username: "jeffbazos",
                                                                 profilePictureUrl: iconUrlString,
                                                                 postUrl: postUrlString)),
            .follow(viewModel: FollowNotificationCellViewModel(username: "zuck21",
                                                               profilePictureUrl: iconUrlString,
                                                               isCurrentUserFollowing: true))
        ]
        
        tableView.reloadData()
    }

}

//MARK: - TableView Delegate and DataSource
extension NotificationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = viewModels[indexPath.row]
        switch cellType {
        case .follow(let viewModel):
            guard let cell = tableView.dequeueReusableCell(
                                        withIdentifier: FollowNotificationTableViewCell.identifier,
                                        for: indexPath) as? FollowNotificationTableViewCell
            else {
                fatalError()
            }
//            cell.backgroundColor = .red
            cell.configure(with: viewModel)
            return cell
        case .like(let viewModel):
            guard let cell = tableView.dequeueReusableCell(
                                        withIdentifier: LikeNotificationTableViewCell.identifier,
                                        for: indexPath) as? LikeNotificationTableViewCell
            else {
                fatalError()
            }
            cell.backgroundColor = .green
            cell.configure(with: viewModel)
            return cell
        case .comment(let viewModel):
            guard let cell = tableView.dequeueReusableCell(
                                        withIdentifier: CommentNotificationTableViewCell.identifier,
                                        for: indexPath) as? CommentNotificationTableViewCell
            else {
                fatalError()
            }
            cell.backgroundColor = .yellow
            cell.configure(with: viewModel)
            return cell

        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}
