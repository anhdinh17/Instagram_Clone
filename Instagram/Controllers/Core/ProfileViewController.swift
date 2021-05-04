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
        
        configure()
    }
    
    private func configure(){
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
