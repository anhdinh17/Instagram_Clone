//
//  PostCollectionViewCell.swift
//  Instagram
//
//  Created by Anh Dinh on 4/27/21.
//

import UIKit

protocol PostCollectionViewCellDelegate: AnyObject {
    func postCollectionViewCellDidLike(_ cell: PostCollectionViewCell)
}


class PostCollectionViewCell: UICollectionViewCell {
    static let identifier = "PostCollectionViewCell"
    
    weak var delegate: PostCollectionViewCellDelegate?
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    // image of the heart when you double tap on image
    private let heartImageView: UIImageView = {
        let image = UIImage(systemName: "suit.heart.fill",
                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 50))
        let imageView = UIImageView(image: image)
        imageView.isHidden = true
        imageView.tintColor = .white
        imageView.alpha = 0 // chưa hiểu alpha
        return imageView
    }()
    
//MARK: - INIT
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .systemBackground
        contentView.clipsToBounds = true
        
        contentView.addSubview(imageView)
        contentView.addSubview(heartImageView) // add heart image
        
        // Gesture for double tap
        let tap = UITapGestureRecognizer(target: self, action: #selector(didDoubleTapToLike))
        tap.numberOfTapsRequired = 2 // number of taps required
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tap)
    }
    
    @objc func didDoubleTapToLike(){
        // Fade in, fade out the heart when double tap
        heartImageView.isHidden = false
        UIView.animate(withDuration: 0.4) {
            self.heartImageView.alpha = 1
        }completion: { (done) in
            if done {
                UIView.animate(withDuration: 0.4) {
                    self.heartImageView.alpha = 0
                }completion: { (done) in
                    if done {
                        self.heartImageView.isHidden = true
                    }
                }
            }
        }
        
        // run delegate func in HomeViewController
        delegate?.postCollectionViewCellDidLike(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.frame = contentView.bounds
        
        let size: CGFloat = contentView.width/5
        heartImageView.frame = CGRect(x: (contentView.width-size)/2, // center the image
                                      y: (contentView.height-size)/2,
                                      width: size,
                                      height: size)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    func configure(with viewModel: PostCollectionViewCellViewModel){
        imageView.sd_setImage(with: viewModel.postUrl, completed: nil)
    }
}
