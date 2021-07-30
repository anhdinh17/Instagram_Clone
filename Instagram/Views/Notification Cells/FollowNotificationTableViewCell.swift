//
//  FollowNotificationTableViewCell.swift
//  Instagram
//
//  Created by Anh Dinh on 6/9/21.
//

import UIKit

protocol FollowNotificationTableViewCellDelegate: AnyObject {
    func followNotificationTableViewCell(_ cell: FollowNotificationTableViewCell,
                                         didTapButton isFollowing: Bool,
                                         viewModel: FollowNotificationCellViewModel)
}

class FollowNotificationTableViewCell: UITableViewCell {
    static let identifier = "FollowNotificationTableViewCell"
    
    weak var delegate: FollowNotificationTableViewCellDelegate?
    
    private var isFollowing = false
    
    private var viewModel: FollowNotificationCellViewModel?
    
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
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 16, weight: .light)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let followButton = IGFollowButton()
    
    //MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        print("Cell width is: \(contentView.width)")
        selectionStyle = .none
        contentView.clipsToBounds = true
        contentView.addSubview(label)
        contentView.addSubview(profilePictureImageView)
        contentView.addSubview(followButton)
        contentView.addSubview(dateLabel)
        
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
        let buttonWidth: CGFloat = max(followButton.width, 75)
        followButton.frame = CGRect(x: contentView.width - buttonWidth - 24 ,
                                    y: (contentView.height - followButton.height)/2,
                                    width: buttonWidth + 14,
                                    height: followButton.height)
//        followButton.frame = CGRect(x: 310,
//                                    y: (contentView.height - followButton.height)/2,
//                                    width: 100,
//                                    height: followButton.height)

        let labelSize = label.sizeThatFits(
            CGSize(
                width: contentView.width-profilePictureImageView.width - buttonWidth - 44,
                height: contentView.height
            )
        )
        
        dateLabel.sizeToFit()
        
        label.frame = CGRect(x: profilePictureImageView.right + 10,
                             y: 0,
                             width: labelSize.width,
                             height: contentView.height - dateLabel.height - 2)
        
        dateLabel.frame = CGRect(x: profilePictureImageView.right + 10,
                                 y: contentView.height - dateLabel.height - 2,
                                 width: dateLabel.width,
                                 height: dateLabel.height)
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
        profilePictureImageView.image = nil
        followButton.setTitle(nil, for: .normal)
        followButton.backgroundColor = nil
        dateLabel.text = nil
    }
    
    //MARK: - functions
    @objc func didTapFollowButton(){
        guard let vm = viewModel else {return}
        
        delegate?.followNotificationTableViewCell(self,
                                                  didTapButton: !isFollowing,
                                                  viewModel: vm)
        isFollowing = !isFollowing
        
        // Using func configure from IGFollowButton()
        followButton.configure(for: isFollowing ? .unfollow : .follow)
    }
        
    public func configure(with viewModel: FollowNotificationCellViewModel){
        self.viewModel = viewModel
        
        label.text = "\(viewModel.username) started following you"
        profilePictureImageView.sd_setImage(with: viewModel.profilePictureUrl, completed: nil)
        
        // lấy bool từ viewModel để biết là mình có đang follow ng ta ko
        isFollowing = viewModel.isCurrentUserFollowing
        
        dateLabel.text = viewModel.date
        
        followButton.configure(for: isFollowing ? .unfollow : .follow)
    }
}
