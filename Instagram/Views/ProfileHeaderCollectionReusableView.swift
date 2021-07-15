//
//  ProfileHeaderCollectionReusableView.swift
//  Instagram
//
//  Created by Anh Dinh on 7/13/21.
//

import UIKit

class ProfileHeaderCollectionReusableView: UICollectionReusableView {
    static let identifier = "ProfileHeaderCollectionReusableView"
    
    private let imageView: UIImageView = {
        let image = UIImageView()
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFill
        image.layer.masksToBounds = true
        image.backgroundColor = .systemBlue
        return image
    }()
    
    // BIO Label
    private let bioLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .systemYellow
        label.text = "Anh Dinh \nThis is my profile bio "
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18)
        return label
    }()
    
    // View nhỏ mà mình tạo để add vô view của Header
    public let countContainerView = ProfileHeaderCountView()
    
//MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemRed
        
        // add subView to this view, I think because this is using UICollectionReusableView so the syntax is not contentView.addSubview, just addSubview
        addSubview(countContainerView)
        countContainerView.backgroundColor = .yellow
        addSubview(imageView)
        addSubview(bioLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let imageSize: CGFloat = width/4
        imageView.frame = CGRect(x: 5,
                                 y: 5,
                                 width: imageSize,
                                 height: imageSize)
        imageView.layer.cornerRadius = imageSize/2
        
        countContainerView.frame = CGRect(x: imageView.right + 5,
                                          y: 5,
                                          width: width - imageView.right - 10,
                                          height: imageSize)
        
        bioLabel.sizeToFit()
        bioLabel.frame = CGRect(x: 5,
                                y: imageView.bottom + 10,
                                width: width - 10,
                                height: bioLabel.height)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    public func configure(with viewModel: ProfileHeaderViewModel){
        imageView.sd_setImage(with: viewModel.profilePicture, completed: nil)
        
        var text = ""
        if let name = viewModel.name {
            text = name + "\n"
        }
        text += viewModel.bio ?? "Welcome to my profile"
        bioLabel.text = text
        
        // ViewModel of UIView that is added to Header
        let containerViewModel = ProfileHeaderCountViewModel(
            followerCount: viewModel.followerCount,
            followingCount: viewModel.followingCount,
            postsCount: viewModel.postCount,
            actionType: viewModel.buttonType)
        countContainerView.configure(with: containerViewModel)
    }
}
