//
//  PostActionsCollectionViewCell.swift
//  Instagram
//
//  Created by Anh Dinh on 4/27/21.
//

import UIKit

protocol PostActionsCollectionViewCellDelegate: AnyObject {
    func postActionsCollectionViewCellDidTapLike(_ cell: PostActionsCollectionViewCell, isLiked: Bool)
    func postActionsCollectionViewCellDidTapComment(_ cell: PostActionsCollectionViewCell)
    func postActionsCollectionViewCellDidTapShare(_ cell: PostActionsCollectionViewCell)
}

class PostActionsCollectionViewCell: UICollectionViewCell {
    static let identifier = "PostActionsCollectionViewCell"
    
    weak var delegate: PostActionsCollectionViewCellDelegate?
    
    private var isLiked = false
    
    private let likeButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        // set the symbol we want and the size
        let image = UIImage(systemName: "suit.heart", withConfiguration: UIImage.SymbolConfiguration(pointSize: 44))
        button.setImage(image, for: .normal)
        return button
    }()
    
    private let commentButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        // set the symbol we want and the size
        let image = UIImage(systemName: "message", withConfiguration: UIImage.SymbolConfiguration(pointSize: 44))
        button.setImage(image, for: .normal)
        return button
    }()
    
    private let shareButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        // set the symbol we want and the size
        let image = UIImage(systemName: "paperplane", withConfiguration: UIImage.SymbolConfiguration(pointSize: 44))
        button.setImage(image, for: .normal)
        return button
    }()

//MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .systemBackground
        contentView.clipsToBounds = true
        
        // Add subviews
        contentView.addSubview(likeButton)
        contentView.addSubview(commentButton)
        contentView.addSubview(shareButton)
        
        //Button Actions
        likeButton.addTarget(self, action: #selector(didTapLike), for: .touchUpInside)
        commentButton.addTarget(self, action: #selector(didTapComment), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(didTapShare), for: .touchUpInside)
    }
    
    @objc func didTapLike(){
        
        if self.isLiked {
            let image = UIImage(systemName: "suit.heart.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 44))
            likeButton.setImage(image, for: .normal)
            likeButton.tintColor = .white // heart rỗng
        }else{
            let image = UIImage(systemName: "suit.heart.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 44))
            likeButton.setImage(image, for: .normal)
            likeButton.tintColor = .systemRed // heart màu đỏ
        }
        
        // khi tap on like button, run delegate func in HomeViewController with parameter is ngược lại của isLiked
        delegate?.postActionsCollectionViewCellDidTapLike(self, isLiked: !isLiked)
        
        self.isLiked = !isLiked
    }
    
    @objc func didTapComment(){
        delegate?.postActionsCollectionViewCellDidTapComment(self)
    }
    
    @objc func didTapShare(){
        delegate?.postActionsCollectionViewCellDidTapShare(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let size: CGFloat = contentView.height/1.3
        likeButton.frame = CGRect(x: 10,
                                  y: (contentView.height-size)/2,
                                  width: size,
                                  height: size)
        commentButton.frame = CGRect(x: likeButton.right + 12,
                                     y: (contentView.height-size)/2,
                                     width: size,
                                     height: size)
        shareButton.frame = CGRect(x: commentButton.right + 12,
                                   y: (contentView.height-size)/2,
                                   width: size,
                                   height: size)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func configure(with viewModel: PostActionsCollectionViewCellViewModel){
        
        isLiked = viewModel.isLiked
        
        // if isLiked = true, set the image of the button to be filled with red
        if viewModel.isLiked {
            let image = UIImage(systemName: "suit.heart.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 44))
            likeButton.setImage(image, for: .normal)
            likeButton.tintColor = .systemRed
        }
    }
}
