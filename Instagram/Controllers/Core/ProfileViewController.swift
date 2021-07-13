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
        return 30
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PhotoCollectionViewCell.identifier,
                for: indexPath) as? PhotoCollectionViewCell else {
            fatalError()
        }
        cell.configure(with: UIImage(named: "test"))
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
        return headerView
    }
    
    // Tap on 1 item
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let post = posts[indexPath.row]
//        let vc = PostViewController(post: post)
//        navigationController?.pushViewController(vc, animated: true)
    }
}
