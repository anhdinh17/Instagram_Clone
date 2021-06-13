//
//  FollowNotificationTableViewCell.swift
//  Instagram
//
//  Created by Anh Dinh on 6/9/21.
//

import UIKit

class FollowNotificationTableViewCell: UITableViewCell {
    static let identifier = "FollowNotificationTableViewCell"
    
    private let profilePictureImageView: UIImageView = {
        let image = UIImageView()
        image.layer.masksToBounds = true
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18)
        return label
    }()
    
    private let followButton: UIButton = {
        let button = UIButton()
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 4
        
        return button
    }()
 
//MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.clipsToBounds = true
        contentView.addSubview(label)
        contentView.addSubview(profilePictureImageView)
        contentView.addSubview(followButton)
        followButton.addTarget(self, action: #selector(didTapFollowButton), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let imageSize: CGFloat = contentView.height/1.5
        profilePictureImageView.frame = CGRect(x: 10,
                                               y: (contentView.height-imageSize)/2,
                                               width: imageSize,
                                               height: imageSize)
        profilePictureImageView.layer.cornerRadius = imageSize/2
        
        followButton.sizeToFit()
        followButton.frame = CGRect(x: contentView.width - followButton.width - 24,
                                    y: (contentView.height - followButton.height)/2,
                                    width: followButton.width + 14,
                                    height: followButton.height)
        
        let labelSize = label.sizeThatFits(
            CGSize(
                width: contentView.width-profilePictureImageView.width-followButton.width-44,
                height: contentView.height
            )
        )
        label.frame = CGRect(x: profilePictureImageView.right + 10,
                             y: 0,
                             width: labelSize.width,
                             height: contentView.height)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
        profilePictureImageView.image = nil
        followButton.setTitle(nil, for: .normal)
        followButton.backgroundColor = nil
    }

//MARK: - functions
    @objc func didTapFollowButton(){
        
    }
    
    public func configure(with viewModel: FollowNotificationCellViewModel){
        label.text = "\(viewModel.username) started following you"
        profilePictureImageView.sd_setImage(with: viewModel.profilePictureUrl, completed: nil)
        
        // set title for button using TERNARY condition
        followButton.setTitle(viewModel.isCurrentUserFollowing ? "Unfollow" : "Follow", for: .normal)
        followButton.backgroundColor = viewModel.isCurrentUserFollowing ? .tertiarySystemBackground : .systemBlue
        followButton.setTitleColor(viewModel.isCurrentUserFollowing ? .label : .white, for: .normal)
        
        // if current user is follwing, we give border to button
        if viewModel.isCurrentUserFollowing {
            followButton.layer.borderWidth = 0.5
            followButton.layer.borderColor = UIColor.secondaryLabel.cgColor
        }
    }
}
