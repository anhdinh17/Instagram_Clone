//
//  ProfileHeaderCountView.swift
//  Instagram
//
//  Created by Anh Dinh on 7/14/21.
//

import UIKit

protocol ProfileHeaderCountViewDelegate: AnyObject {
    func profileHeaderCountViewDidTapFollowers(_ containerView: ProfileHeaderCountView)
    func profileHeaderCountViewDidTapFollowing(_ containerView: ProfileHeaderCountView)
    func profileHeaderCountViewDidTapPosts(_ containerView: ProfileHeaderCountView)
    func profileHeaderCountViewDidTapEditProfile(_ containerView: ProfileHeaderCountView)
    func profileHeaderCountViewDidTapFollow(_ containerView: ProfileHeaderCountView)
    func profileHeaderCountViewDidTapUnFollow(_ containerView: ProfileHeaderCountView)
}

class ProfileHeaderCountView: UIView {

    weak var delegate: ProfileHeaderCountViewDelegate?
    
    private var action = ProfileButtonType.edit
    
    private var isFollowing = false
    
    private let followerCountButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.numberOfLines = 2
        button.setTitle("-", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.layer.cornerRadius = 4
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.tertiaryLabel.cgColor
        return button
    }()
    
    private let followingCountButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.numberOfLines = 2
        button.setTitle("-", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.layer.cornerRadius = 4
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.tertiaryLabel.cgColor
        return button
    }()
    
    private let postCountButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.numberOfLines = 2
        button.setTitle("-", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.layer.cornerRadius = 4
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.tertiaryLabel.cgColor
        return button
    }()
    
    // Action Button, use IGFollowButton() 
    private let actionButton = IGFollowButton()

//MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // BECAUSE this is UIView, not a file for a cell, so syntax to add subview is bit different, we don't use contentView
        addSubview(followerCountButton)
        addSubview(followingCountButton)
        addSubview(postCountButton)
        addSubview(actionButton)
        
        addActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let buttonWidth: CGFloat = (width-15)/3
        followerCountButton.frame = CGRect(x: 5,
                                      y: 5,
                                      width: buttonWidth,
                                      height: height/2)
        followingCountButton.frame = CGRect(x: followerCountButton.right + 5,
                                      y: 5,
                                      width: buttonWidth,
                                      height: height/2)
        postCountButton.frame = CGRect(x: followingCountButton.right + 3,
                                      y: 5,
                                      width: buttonWidth,
                                      height: height/2)
        
        actionButton.frame = CGRect(x: 5,
                                    y: height - 42,
                                    width: width - 10,
                                    height: 40)
    }
    
    private func addActions(){
        // Add targets for buttons
        followerCountButton.addTarget(self, action: #selector(didTapFollowers), for: .touchUpInside)
        followingCountButton.addTarget(self, action: #selector(didTapFollowing), for: .touchUpInside)
        postCountButton.addTarget(self, action: #selector(didTapPosts), for: .touchUpInside)
        actionButton.addTarget(self, action: #selector(didTapActionButton), for: .touchUpInside)
    }
    
    @objc func didTapFollowers(){
        delegate?.profileHeaderCountViewDidTapFollowers(self)
    }
    @objc func didTapFollowing(){
        delegate?.profileHeaderCountViewDidTapFollowing(self)
    }
    @objc func didTapPosts(){
        delegate?.profileHeaderCountViewDidTapPosts(self)
    }
    @objc func didTapActionButton(){
        switch action {
        case .edit:
            delegate?.profileHeaderCountViewDidTapEditProfile(self)
        case .follow:
            if isFollowing {
                // If already following, unfollow
                delegate?.profileHeaderCountViewDidTapUnFollow(self)
            } else {
                delegate?.profileHeaderCountViewDidTapFollow(self)
            }
            self.isFollowing = !isFollowing
            actionButton.configure(for: isFollowing ? .unfollow : .follow)
        }
    }
    
    func configure(with viewModel: ProfileHeaderCountViewModel){
        followerCountButton.setTitle("\(viewModel.followerCount) \n Followers", for: .normal)
        followingCountButton.setTitle("\(viewModel.followingCount) \n Following", for: .normal)
        postCountButton.setTitle("\(viewModel.postsCount) \n Posts", for: .normal)
        
        self.action = viewModel.actionType
        
        switch viewModel.actionType{
        case .edit:
            actionButton.backgroundColor = .systemBackground
            actionButton.setTitle("Edit Profile", for: .normal)
            actionButton.setTitleColor(.label, for: .normal)
            actionButton.layer.borderWidth = 0.5
            actionButton.layer.borderColor = UIColor.tertiaryLabel.cgColor

        case .follow(let isFollowing):
            self.isFollowing = isFollowing
            // Nếu isFollowing is true, use case .unfollow to set up the button and vice versa
            actionButton.configure(for: isFollowing ? .unfollow : .follow)
        }
    }
    
    
}
