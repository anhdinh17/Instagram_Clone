//
//  PostLikesCollectionViewCell.swift
//  Instagram
//
//  Created by Anh Dinh on 4/27/21.
//

import UIKit

protocol PostLikesCollectionViewCellDelegate: AnyObject {
    func postLikesCollectionViewCellDidTapLikeCount(_ cell: PostLikesCollectionViewCell)
}


class PostLikesCollectionViewCell: UICollectionViewCell {
    static let identifier = "PostLikesCollectionViewCell"
    
    weak var delegate: PostLikesCollectionViewCellDelegate?
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.isUserInteractionEnabled = true
        label.textColor = .systemBlue
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .systemBackground
        contentView.clipsToBounds = true
        
        // add subviews:
        contentView.addSubview(label)
        
        // add tap to label:
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapLabel))
        label.addGestureRecognizer(tap)
    }
    
    @objc func didTapLabel(){
        delegate?.postLikesCollectionViewCellDidTapLikeCount(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        label.frame = CGRect(x: 10, y: 0, width: contentView.frame.width , height: contentView.frame.height)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        label.text = nil
    }
    
    func configure(with viewModel: PostLikesCollectionViewCellViewModel){
        let users = viewModel.likers
        label.text = "\(users.count) likes"
    }
}
