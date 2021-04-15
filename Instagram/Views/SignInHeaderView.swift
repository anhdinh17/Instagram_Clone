//
//  SignInHeaderView.swift
//  Instagram
//
//  Created by Anh Dinh on 4/14/21.
//

import UIKit

class SignInHeaderView: UIView {
    
    private var gradientLayer: CALayer?
    
    private var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "text_logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        
        // add gradient color
        createGradient()
        
        // add subview of imageView
        addSubview(imageView)
    }
    
    private func createGradient(){
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.systemBlue.cgColor, UIColor.systemPink.cgColor]
        layer.addSublayer(gradientLayer)
        self.gradientLayer = gradientLayer
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // set the frame for gradient colors
        gradientLayer?.frame = layer.bounds
        
        // set frame for imageView
        imageView.frame = CGRect(x: 20,
                                 y: 20,
                                 width: width - 40,
                                 height: height - 40)
    }
    
}
