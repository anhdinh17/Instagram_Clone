//
//  PosterCollectionViewCell.swift
//  Instagram
//
//  Created by Anh Dinh on 4/27/21.
//

import UIKit
import SDWebImage

// AnyObject is not to cause memory leak
// Good practice là thêm parameter cho functrion chính là class này, thật ra nếu bỏ parameter vẫn có thể sử dụng func được.
protocol PosterCollectionViewCellDelegate: AnyObject {
    func posterCollectionViewCellDidTapMore(_ cell: PosterCollectionViewCell)
    func posterCollectionViewCellDidTapUsername(_ cell: PosterCollectionViewCell)
}

final class PosterCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "PosterCollectionViewCell"
    
    weak var delegate: PosterCollectionViewCellDelegate?
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .darkGray
        // to add gesture
        label.isUserInteractionEnabled = true
        label.font = .systemFont(ofSize: 18, weight: .regular)
        return label
    }()
    
    private let moreButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .darkGray
        button.tintColor = .label
        let image = UIImage(systemName: "ellipsis",
                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
        button.setImage(image, for: .normal)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .systemBackground
        contentView.clipsToBounds = true
        
        contentView.addSubview(imageView)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(moreButton)
        
        moreButton.addTarget(self, action: #selector(didTapMore), for: .touchUpInside)
        
        // add gesture recognizer for username label so we can tap on it
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapUsername))
        usernameLabel.addGestureRecognizer(tap)
    }
    
    @objc func didTapMore(){
        // có nghĩa là khi tap sẽ run delegate func in HomeViewController
        delegate?.posterCollectionViewCellDidTapMore(self)
    }
    
    @objc func didTapUsername(){
        // run delegate func in HomeViewController
        delegate?.posterCollectionViewCellDidTapUsername(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let imagePadding: CGFloat = 4
        let imageSize: CGFloat = contentView.height - imagePadding*4
        imageView.frame = CGRect(x: imagePadding, y: imagePadding, width: imageSize, height: imageSize)
        imageView.layer.cornerRadius = imageSize/2
        
        usernameLabel.sizeToFit()
        usernameLabel.frame = CGRect(x: imageView.right + 10,
                                     y: 0,
                                     width: usernameLabel.width,
                                     height: contentView.height)
        
        moreButton.frame = CGRect(x: contentView.width - 55,
                                  y: (contentView.height-50)/2,
                                  width: 50,
                                  height: 50)
    }
    
    // everytime the cell is reused, we want to set the image and text to be nil
    override func prepareForReuse() {
        super.prepareForReuse()
        usernameLabel.text = nil
        imageView.image = nil
    }
    
    func configure(with viewModel: PosterCollectionViewCellViewModel){
        usernameLabel.text = viewModel.username
        imageView.sd_setImage(with: viewModel.profilePictureURL, completed: nil)
    }
}
