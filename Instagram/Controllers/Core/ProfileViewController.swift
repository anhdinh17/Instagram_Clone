//
//  ProfileViewController.swift
//  Instagram
//
//  Created by Anh Dinh on 4/13/21.
//

import UIKit

class ProfileViewController: UIViewController {

    private let user: User

    private var isCurrentUser: Bool {
        return user.username.lowercased() == UserDefaults.standard.string(forKey: "username")?.lowercased() ?? ""
    }
    
    // CollectionView
    private var collectionView: UICollectionView?
    
    // Header
    private var headerViewModel: ProfileHeaderViewModel?
    
    // Array of Post to fetch data to cells
    private var posts: [Post] = []
    
//MARK: - Init
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
  
//MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = user.username.uppercased()
        view.backgroundColor = .systemBackground
        
        configureNavBar()
        
        configureCollectionView()
        
        fetchProfileInfo()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = view.bounds
    }
    
    private func configureNavBar(){
        if isCurrentUser {
            // create an bar button on navigation bar
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear"),
                                                                style: .done,
                                                                target: self,
                                                                action: #selector(didTapSettings))
        }
    }
    
    @objc func didTapSettings(){
        let vc = SettingsViewController()
        // pop up new VC with using UINavigationController
        present(UINavigationController(rootViewController: vc), animated: true)
        //navigationController?.pushViewController(vc, animated: true)
    }
    
//MARK: - fetchProfileInfo
    private func fetchProfileInfo(){
        
        let username = user.username
        
        let group = DispatchGroup()
        
        // Fetch data from FB to get the posts from FB
        group.enter()
        DatabaseManager.shared.posts(for: username) { [weak self] (result) in
            defer{
                group.leave()
            }
            switch result {
            case .success(let post):
                self?.posts = post
            case .failure:
                break
            }
        }
        
        
        // These variables are for fetching Header info
        var profilePictureUrl: URL?
        var buttonType: ProfileButtonType = .edit
        var posts = 0
        var followers = 0
        var following = 0
        var name: String?
        var bio: String?

        group.enter()
        DatabaseManager.shared.getUserCounts(username: user.username) { (result) in
            defer{
                group.leave()
            }
            posts = result.posts
            followers = result.followers
            following = result.following
        }
        
        // Bio, name
        DatabaseManager.shared.getUserInfo(username: user.username) { (userInfo) in
            name = userInfo?.name
            bio = userInfo?.bio
        }
        
        
        // Profile picture url
        group.enter()
        StorageManager.shared.profilePictureURL(username: user.username) { (url) in
            defer{
                group.leave()
            }
            profilePictureUrl = url
        }
        
        // if profie is not for current user
        if !isCurrentUser {
            group.enter()
            DatabaseManager.shared.isFollowing(targetUsername: user.username) { (isFollowing) in
                defer{
                    group.leave()
                }
                buttonType = .follow(isFollowing: true)
            }
        }
        
        group.notify(queue: .main) {
            // Sau khi leave thì modify Header
            self.headerViewModel = ProfileHeaderViewModel(
                profilePicture: profilePictureUrl,
                followerCount: followers,
                followingCount: following,
                postCount: posts,
                buttonType: buttonType,
                name: name,
                bio: bio)
            
            self.collectionView?.reloadData() // Reload collectionView cho Header and display posts in cells
        }
    }
}

//MARK: - Setup CollectionView
extension ProfileViewController {
    
    func configureCollectionView(){
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { (index,_) -> NSCollectionLayoutSection? in
            
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),heightDimension: .fractionalHeight(1)))
            
            //padding between items
            item.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1)
            
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),heightDimension: .fractionalWidth(0.33)),
                subitem: item,
                count: 3)
            
            let section = NSCollectionLayoutSection(group: group)
            
            // this one is used for header
            section.boundarySupplementaryItems = [
                NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .fractionalWidth(0.66)),
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top) //.top because the header is at the top of the view
            ]
            
            return section
        }))
        // Register the cell file
        collectionView.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: PhotoCollectionViewCell.identifier)
        // Register the header
        collectionView.register(
            ProfileHeaderCollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: ProfileHeaderCollectionReusableView.identifier)
        
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        self.collectionView = collectionView
    }
}

//MARK: - CollectionView Delegate and  DataSource
extension ProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PhotoCollectionViewCell.identifier,
                for: indexPath) as? PhotoCollectionViewCell else {
            fatalError()
        }
        // lấy postURL từ post rồi display lên cells
        cell.configure(with: URL(string: posts[indexPath.row].postUrlString))
        return cell
    }
    
    // FUNC TO DISPLAY HEADER
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard kind == UICollectionView.elementKindSectionHeader,
              let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: ProfileHeaderCollectionReusableView.identifier,
                for: indexPath) as? ProfileHeaderCollectionReusableView else {
            return UICollectionReusableView()
        }
        
        if let viewModel = headerViewModel {
            // Delegate for protocol
            headerView.countContainerView.delegate = self
            
            headerView.configure(with: viewModel)
        }

        // Delegate for protocol
        headerView.delegate = self
        
        return headerView
    }
    
    // Tap on 1 item
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let post = posts[indexPath.row]
        let vc = PostViewController(post: post)
        navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: - Protocol form ProfileHeaderCollectionReusableView
extension ProfileViewController: ProfileHeaderCollectionReusableViewDelegate {
    func profileHeaderCollectionReusableViewDidTapProfilePicture(_ header: ProfileHeaderCollectionReusableView) {
        
        // Check if current user is me so that if I click on other user's profile image, I can't change it
        guard isCurrentUser else {
            return
        }
        
        let sheet = UIAlertController(title: "Change Picture",
                                      message: "Change your profile picture.",
                                      preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        sheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { [weak self] (_) in
            DispatchQueue.main.async {
                //view controller that manages the system interfaces for taking pictures, recording movies, and choosing items from the user's media library.
                let picker = UIImagePickerController()
                picker.allowsEditing = true // this one is for cropping the image to make it square
                picker.sourceType = .camera
                picker.delegate = self
                self?.present(picker, animated: true)
            }
        }))
        sheet.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { [weak self] (_) in
            DispatchQueue.main.async {
                let picker = UIImagePickerController()
                picker.allowsEditing = true
                picker.sourceType = .photoLibrary
                picker.delegate = self
                self?.present(picker, animated: true)
            }
        }))
        
        present(sheet, animated: true, completion: nil)
    }
}

//MARK: - Conform to UIImagePickerControllerDelegate, UINavigationControllerDelegate to choose photos or take photos
extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        // Upload image to FB for a new profile picture
        StorageManager.shared.uploadProfilePicture(
            username: user.username,
            data: image.pngData()) { [weak self] (success) in
            if success {
                // Nếu sucess thì ta clear everything rồi fetch lại data
                self?.headerViewModel = nil
                self?.posts = []
                self?.fetchProfileInfo() // fetch lại mọi thứ
            }
        }
        
    }
}

//MARK: - Protocol from ProfileHeaderCountView
extension ProfileViewController: ProfileHeaderCountViewDelegate{
    func profileHeaderCountViewDidTapFollowers(_ containerView: ProfileHeaderCountView) {
        
    }
    
    func profileHeaderCountViewDidTapFollowing(_ containerView: ProfileHeaderCountView) {
        
    }
    
    func profileHeaderCountViewDidTapPosts(_ containerView: ProfileHeaderCountView) {
        guard posts.count >= 18 else
        {
            return
        }
        collectionView?.setContentOffset(CGPoint(
                                            x: 0,
                                            y: view.width * 0.7),
                                         animated: true)
    }
    
    func profileHeaderCountViewDidTapEditProfile(_ containerView: ProfileHeaderCountView) {
        let vc = EditProfileViewController()
        vc.completion = {[weak self] in
            self?.headerViewModel = nil
            self?.fetchProfileInfo()
            // refresh header info
        }
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true, completion: nil)
    }
    
    func profileHeaderCountViewDidTapFollow(_ containerView: ProfileHeaderCountView) {
        
    }
    
    func profileHeaderCountViewDidTapUnFollow(_ containerView: ProfileHeaderCountView) {
        
    }
        
}
