//
//  PostCaptionsCollectionViewCell.swift
//  Instagram
//
//  Created by Anh Dinh on 4/27/21.
//

import UIKit

protocol PostCaptionCollectionViewCellDelegate: AnyObject {
    func postCaptionCollectionViewCellDidTapCaption(_ cell: PostCaptionCollectionViewCell)
}

class PostCaptionCollectionViewCell: UICollectionViewCell {
    static let identifier = "PostCaptionCollectionViewCell"
    
    weak var delegate: PostCaptionCollectionViewCellDelegate?
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .systemBlue
        label.isUserInteractionEnabled = true
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .systemBackground
        contentView.clipsToBounds = true
        
        //add subview
        contentView.addSubview(label)
        
        // add tap to label
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapCaption))
        label.addGestureRecognizer(tap)
    }
    
    @objc func didTapCaption(){
        delegate?.postCaptionCollectionViewCellDidTapCaption(self)
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
    
    func configure(with viewModel: PostCaptionCollectionViewCellViewModel){
        label.text = "\(viewModel.username): \(viewModel.caption ?? "")"
    }
}
