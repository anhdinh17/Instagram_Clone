//
//  PostDateTimeCollectionViewCell.swift
//  Instagram
//
//  Created by Anh Dinh on 4/27/21.
//

import UIKit

class PostDateTimeCollectionViewCell: UICollectionViewCell {
    static let identifier = "PostDateTimeCollectionViewCell"
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = .systemBlue
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .systemBackground
        contentView.clipsToBounds = true
        
        // add subview
        contentView.addSubview(label)
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
    
    func configure(with viewModel: PostDatetimeCollectionViewCellViewModel){
        let date = viewModel.date
        label.text = String.date(from: date)
    }
}
