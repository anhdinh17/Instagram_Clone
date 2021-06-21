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
    
    private var models: [IGNotification] = []
    // The number of items of viewModels = models
    
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
        
        //mockData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.frame = view.bounds
        
        noActivityLabel.sizeToFit()
        noActivityLabel.center = view.center
    }
    
    private func fetchNotifications(){
        // models in the completion is an array of IGNotification
        // nên nhớ IGNotification là của người khác
        NotificationsManager.shared.getNotifications { [weak self](models) in
            DispatchQueue.main.async {
                print("\n\n Array of Notificaions from Firebase: \(models.count)")
                self?.models = models // store vào models của viewController này
                self?.createViewModels()
            }
        }
    }
    
    private func createViewModels(){
        print("\n\n models before forEach func: \(models.count)")
        models.forEach { (model) in
            // cái này khá hay mà mình chưa biết, đó là lấy value của model.notificationType which is an Int, sau đó IGType(rawValue:) để xét xem nếu đó là 1 thì .like, 2 là .comment, etc. Dẩn tới "type" cũng sẽ là .like,.comment or .follow
            guard let type = NotificationsManager.IGType(rawValue: model.notificationType) else {
                return
            }
            let username = model.username // tên của người like/comment/follow mình
            guard let profilePictureUrl = URL(string: model.profilePictureUrl) else {
                return
            }
            switch type {
            case .like:
                guard let postUrl = URL(string: model.postUrl ?? "") else {
                    return
                }
                // add case này vô viewModels
                // syntax để add 1 case vô array của enum:
                viewModels.append(.like(viewModel: LikeNotificationCellViewModel(
                                            username: username,
                                            profilePictureUrl: profilePictureUrl,
                                            postUrl: postUrl,
                                            date: model.dateString)
                                                        )
                                                    )
            case .comment:
                guard let postUrl = URL(string: model.postUrl ?? "") else {
                    return
                }
                viewModels.append(.comment(viewModel: CommentNotificationCellViewModel(
                                            username: username,
                                            profilePictureUrl: profilePictureUrl,
                                            postUrl: postUrl,
                                            date: model.dateString)
                                                        )
                                                    )
            case .follow:
                guard let isFollowing = model.isFollowing else {
                    return
                }
                viewModels.append(.follow(viewModel: FollowNotificationCellViewModel(
                                            username: username,
                                            profilePictureUrl: profilePictureUrl,
                                            isCurrentUserFollowing: isFollowing,
                                            date: model.dateString)
                                                        )
                                                    )
            }
        }
        
        if viewModels.isEmpty {
            noActivityLabel.isHidden = false
            tableView.isHidden = true
        }else{
            noActivityLabel.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
            print("\n\n\n\n \(viewModels) \n viewModels.count is: \(viewModels.count)")
        }
    }
    
    private func mockData(){
        tableView.isHidden = false
        guard let postUrlString = URL(string: "https://iosacademy.io/assets/images/courses/swiftui.png") else {return}
        guard let iconUrlString = URL(string:"https://iosacademy.io/assets/images/brand/icon.jpg") else {return}
        
        viewModels = [
            .like(viewModel: LikeNotificationCellViewModel(username: "",
                                                           profilePictureUrl: iconUrlString,
                                                           postUrl: postUrlString,
                                                           date: "March 12")),
            .comment(viewModel: CommentNotificationCellViewModel(username: "jeffbazos",
                                                                 profilePictureUrl: iconUrlString,
                                                                 postUrl: postUrlString,
                                                                 date: "April 1")),
            .follow(viewModel: FollowNotificationCellViewModel(username: "zuck21",
                                                               profilePictureUrl: iconUrlString,
                                                               isCurrentUserFollowing: true,
                                                               date: "May 11"))
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
            cell.delegate = self
            return cell
        case .like(let viewModel):
            guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: LikeNotificationTableViewCell.identifier,
                    for: indexPath) as? LikeNotificationTableViewCell
            else {
                fatalError()
            }
            cell.configure(with: viewModel)
            cell.delegate = self
            cell.backgroundColor = .green
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
            cell.delegate = self
            return cell
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // get the cell type from each item and check case for each one
        let cellType = viewModels[indexPath.row]
        let username: String
        switch cellType {
        case .follow(let viewModel):
            username = viewModel.username
        case .like(let viewModel):
            username = viewModel.username
        case .comment(let viewModel):
            username = viewModel.username
        }
        
        DatabaseManager.shared.findUser(with: username) { [weak self](user) in
            guard let user = user else {return}
            
            DispatchQueue.main.async {
                let vc = ProfileViewController(user: user)
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

//MARK: - Protocols
extension NotificationViewController: LikeNotificationTableViewCellDelegate,CommentNotificationTableViewCellDelegate,FollowNotificationTableViewCellDelegate {
    
    func followNotificationTableViewCell(_ cell: FollowNotificationTableViewCell,
                                         didTapButton isFollowing: Bool,
                                         viewModel: FollowNotificationCellViewModel) {
        let username = viewModel.username
    }
    
    func likeNotificationTableViewCell(_ cell: LikeNotificationTableViewCell, didTapPostWith viewModel: LikeNotificationCellViewModel) {
        guard let index = viewModels.firstIndex(where: {
            switch($0){
            case .follow, .comment:
                return false
            case .like(let current):
                return current == viewModel
            }
        }) else {return}
        
        openPost(with: index,username: viewModel.username)
        
        // Find post by id from particular
    }
    
    func commentNotificationTableViewCell(_ cell: CommentNotificationTableViewCell, didTapPostWith viewModel: CommentNotificationCellViewModel) {
        
        // viewModels là 1 array của enum
        // xét xem thằng index này là của case enum nào
        guard let index = viewModels.firstIndex(where: {
            switch($0){
            case .follow, .like:
                return false
            case .comment(let current):
                return current == viewModel
            }
        }) else {return}
        
        openPost(with: index, username: viewModel.username)
    }
    
    func openPost(with index: Int, username: String){
        print(index)
        
        guard index < models.count else {
            return
        }
        
        let model = models[index]
        let username = username
        guard let postID = model.postId else {
            return
        }
    }
}
