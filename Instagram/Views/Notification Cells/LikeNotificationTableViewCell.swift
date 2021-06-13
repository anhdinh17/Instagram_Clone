//
//  LikeNotificationTableViewCell.swift
//  Instagram
//
//  Created by Anh Dinh on 6/9/21.
//

import UIKit

class LikeNotificationTableViewCell: UITableViewCell {
    static let identifier = "LikeNotificationTableViewCell"

    private let profilePictureImageView: UIImageView = {
        let image = UIImageView()
        image.layer.masksToBounds = true
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    private let postImageView: UIImageView = {
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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.clipsToBounds = true
        contentView.addSubview(label)
        contentView.addSubview(profilePictureImageView)
        contentView.addSubview(postImageView)
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
        
        let postSize: CGFloat = contentView.height - 6
        postImageView.frame = CGRect(x: contentView.width - postSize - 10,
                                     y: 3,
                                     width: postSize,
                                     height: postSize)
        
        let labelSize = label.sizeThatFits(CGSize(
                                            width: contentView.width - profilePictureImageView.right - 25 - postSize,
                                            height: contentView.height))
        label.frame = CGRect(x: profilePictureImageView.right + 10,
                             y: 0,
                             width: labelSize.width,
                             height: contentView.height)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
        profilePictureImageView.image = nil
        postImageView.image = nil
    }
    
    public func configure(with viewModel: LikeNotificationCellViewModel){
        // set profile image of the user who commented on your post
        profilePictureImageView.sd_setImage(with: viewModel.profilePictureUrl,
                                            completed: nil)
        // set the image of your post
        postImageView.sd_setImage(with: viewModel.postUrl, completed: nil)
        
        label.text = "\(viewModel.username) liked on your post."
    }
}
