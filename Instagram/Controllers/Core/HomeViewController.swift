//
//  ViewController.swift
//  Instagram
//
//  Created by Anh Dinh on 4/12/21.
//

import UIKit

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    private var collectionView: UICollectionView?
    
    private var viewModels = [[HomeFeedCellType]]()

//MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Instagram"
        view.backgroundColor = .systemBackground
        
        print("This is HomeViewVC")
        
       // collectionView?.reloadData()
        
        configureCollectionView()
        
        fetchPosts()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = view.bounds
    }
    
    // mocking data
    private func fetchPosts(){
        guard let username = UserDefaults.standard.string(forKey: "username") else {return}
        
        DatabaseManager.shared.posts(for: username) { [weak self](result) in
            switch result {
            case .success(let posts):
                print("\n\n\n\n There are \(posts.count) \n\n\n \(posts)")
                
                let group = DispatchGroup()
                // với mỗi post của thằng array từ FB này
                posts.forEach { (model) in
                    group.enter()
                    self?.createViewModel(model: model,username: username, completion: { (success) in
                        defer{
                            group.leave()
                        }
                        if !success {
                            print("Failed to create view model")
                        }
                    })
                }
                
                group.notify(queue: .main) {
                    self?.collectionView?.reloadData()
                }
                
            case .failure(let error):
                print("Error in DatabaseManager.posts: \(error)")
            }
        }
    }
    
    private func createViewModel(model: Post,
                                 username: String,
                                 completion: @escaping (Bool)->Void){
        StorageManager.shared.profilePictureURL(username: username) { [weak self](profilePictureURL) in
            guard let postUrl = URL(string: model.postUrlString),
                  let profilePictureUrl = profilePictureURL else{
                return
            }
            
            let postData: [HomeFeedCellType] = [
                .poster(
                    viewModel: PosterCollectionViewCellViewModel(
                        username: username,
                        profilePictureURL:profilePictureUrl)),
                .post(viewModel: PostCollectionViewCellViewModel(postUrl: postUrl)),
                .actions(viewModel: PostActionsCollectionViewCellViewModel(isLiked: false)),
                .likeCount(viewModel: PostLikesCollectionViewCellViewModel(likers: [])),
                .caption(viewModel: PostCaptionCollectionViewCellViewModel(
                            username: username,
                            caption: model.caption)),
                .timestamp(viewModel: PostDatetimeCollectionViewCellViewModel(
                            date: DateFormatter.formatter.date(from: model.postedDate) ?? Date()))
            ]
            
            // add to array viewModels
            self?.viewModels.append(postData)
            completion(true)
        }
    }
    
//MARK: - COllectionView delegate/dataSource funcs
    
    // number of sections
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModels.count
    }
    
    // number of cell in each section
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels[section].count // number of cells
    }
    
    let colors: [UIColor] = [.red,.green,.blue,.yellow,.systemPink,.orange]
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // hiểu: cái này là 1 cell trong 1 section và set case cho cell đó bởi vì 1 cell là 1 enum của HomeFeedCellType
        let cellType = viewModels[indexPath.section][indexPath.row]
        switch cellType {
        case .poster(let viewModel):
            // cast cell to customized cell file
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PosterCollectionViewCell.identifier,
                    for: indexPath) as? PosterCollectionViewCell else {
                fatalError()
            }
            
            // delegate to tap on username and more button
            cell.delegate = self
            
            cell.configure(with: viewModel) // excute configure() func to pass data to Cell to display UI
            cell.contentView.backgroundColor = colors[indexPath.row]
            return cell
        case .post(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PostCollectionViewCell.identifier,
                    for: indexPath) as? PostCollectionViewCell else {
                fatalError()
            }
            cell.delegate = self
            cell.configure(with: viewModel)
            cell.contentView.backgroundColor = colors[indexPath.row]
            return cell
        case .actions(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PostActionsCollectionViewCell.identifier,
                    for: indexPath) as? PostActionsCollectionViewCell else {
                fatalError()
            }
            cell.delegate = self
            cell.configure(with: viewModel)
            cell.contentView.backgroundColor = colors[indexPath.row]
            return cell
        case .likeCount(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PostLikesCollectionViewCell.identifier,
                    for: indexPath) as? PostLikesCollectionViewCell else {
                fatalError()
            }
            cell.delegate = self
            cell.configure(with: viewModel)
            cell.contentView.backgroundColor = colors[indexPath.row]
            return cell
        case .caption(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PostCaptionCollectionViewCell.identifier,
                    for: indexPath) as? PostCaptionCollectionViewCell else {
                fatalError()
            }
            cell.delegate = self
            cell.configure(with: viewModel)
            cell.contentView.backgroundColor = colors[indexPath.row]
            return cell
        case .timestamp(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PostDateTimeCollectionViewCell.identifier,
                    for: indexPath) as? PostDateTimeCollectionViewCell else {
                fatalError()
            }
            cell.configure(with: viewModel)
            cell.contentView.backgroundColor = colors[indexPath.row]
            return cell
        }
        
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 1
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 1
//    }
}





//MARK: - Delegate for tapping username and more button
extension HomeViewController: PosterCollectionViewCellDelegate {
    func posterCollectionViewCellDidTapMore(_ cell: PosterCollectionViewCell) {
        // sheet for options when clicking on more button
        let sheet = UIAlertController(title: "Post Actions", message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        sheet.addAction(UIAlertAction(title: "Share Posts", style: .default, handler: { (_) in
                
        }))
        sheet.addAction(UIAlertAction(title: "Report Post", style: .destructive, handler: { (_) in
                
        }))
        present(sheet,animated: true)
    }
    
    func posterCollectionViewCellDidTapUsername(_ cell: PosterCollectionViewCell) {
        print("Tapped Username")
        let vc = ProfileViewController(user: User(username: "Alex Dinh", email: "alexdinh@gmail.com"))
        navigationController?.pushViewController(vc, animated: true)
        
    }

}

//MARK: - Delegate for imageView Double Tap
extension HomeViewController: PostCollectionViewCellDelegate {
    func postCollectionViewCellDidLike(_ cell: PostCollectionViewCell) {
        print("Double Tap")
    }

}


//MARK: - Delegate for postActions:
extension HomeViewController: PostActionsCollectionViewCellDelegate {
    
    func postActionsCollectionViewCellDidTapLike(_ cell: PostActionsCollectionViewCell, isLiked: Bool) {
      
    }
    
    func postActionsCollectionViewCellDidTapComment(_ cell: PostActionsCollectionViewCell) {
        
        // dùng navigationContrller để mở postVC
        let vc = PostViewController()
        vc.title = "Post" // set title for new vc
        vc.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func postActionsCollectionViewCellDidTapShare(_ cell: PostActionsCollectionViewCell) {
        
        // SKILL MỚI: tạo sharing sheet
        let vc = UIActivityViewController(activityItems: ["Sharing from Instagram"],
                                          applicationActivities: [])
        present(vc,animated: true)
    }
}


//MARK: - Delegate for likeCount
extension HomeViewController: PostLikesCollectionViewCellDelegate{
    func postLikesCollectionViewCellDidTapLikeCount(_ cell: PostLikesCollectionViewCell) {
        let vc = ListViewController()
        vc.title = "Liked by"
        navigationController?.pushViewController(vc, animated: true)
    }
}


//MARK: - Delegate for Caption
extension HomeViewController: PostCaptionCollectionViewCellDelegate {
    func postCaptionCollectionViewCellDidTapCaption(_ cell: PostCaptionCollectionViewCell) {
        print("Did tap caption")
    }
}

//MARK: - configure for collectionView
extension HomeViewController {
    func configureCollectionView(){
        
        // sectionHeight =  total height of the cells
        // view.width là height của thằng posterItem
        let sectionHeight:CGFloat = 240 + view.width
        
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { (index,_) -> NSCollectionLayoutSection? in
                
                
                //ITEM
                // each item is 1 cell
                // fractionalWidth/Height is the % of the width/height relative the container
                // .absolute() is a fixed number
                let posterItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
                                                    widthDimension: .fractionalWidth(1),
                                                    heightDimension: .absolute(60)))
                
                let postItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
                                                        widthDimension: .fractionalWidth(1),
                                                        heightDimension: .fractionalWidth(1)))
                
                let actionsItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
                                                    widthDimension: .fractionalWidth(1),
                                                    heightDimension: .absolute(40)))
                
                let likeCountItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
                                                    widthDimension: .fractionalWidth(1),
                                                    heightDimension: .absolute(40)))
                
                let captionItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
                                                    widthDimension: .fractionalWidth(1),
                                                    heightDimension: .absolute(60)))
                
                let timestampItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
                                                    widthDimension: .fractionalWidth(1),
                                                    heightDimension: .absolute(40)))
                
                
                // GROUP
                // add items(cells) to group vertically
                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(sectionHeight)),
                   subitems: [
                    posterItem,
                    postItem,
                    actionsItem,
                    likeCountItem,
                    captionItem,
                    timestampItem
                   ]
                )
                
                // SECTION
                // add the group to section and return the section
                let section = NSCollectionLayoutSection(group: group)
                // add space to top and bottom for each section so they can be seperated
                section.contentInsets = NSDirectionalEdgeInsets(top: 3, leading: 0, bottom: 10, trailing: 0)
                return section
            }))
        view.addSubview(collectionView)
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Register all the cells
        collectionView.register(PosterCollectionViewCell.self,
                                forCellWithReuseIdentifier: PosterCollectionViewCell.identifier)
        collectionView.register(PostCollectionViewCell.self,
                                forCellWithReuseIdentifier: PostCollectionViewCell.identifier)
        collectionView.register(PostActionsCollectionViewCell.self,
                                forCellWithReuseIdentifier: PostActionsCollectionViewCell.identifier)
        collectionView.register(PostLikesCollectionViewCell.self,
                                forCellWithReuseIdentifier: PostLikesCollectionViewCell.identifier)
        collectionView.register(PostCaptionCollectionViewCell.self,
                                forCellWithReuseIdentifier: PostCaptionCollectionViewCell.identifier)
        collectionView.register(PostDateTimeCollectionViewCell.self,
                                forCellWithReuseIdentifier: PostDateTimeCollectionViewCell.identifier)
        
        // set this collectionView equal to global collectionView
        self.collectionView = collectionView
    }
}
