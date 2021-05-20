//
//  PostEditViewController.swift
//  Instagram
//
//  Created by Anh Dinh on 5/20/21.
//

import UIKit

class PostEditViewController: UIViewController {

    private let imageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        return image
    }()
    
    // Tạo 1 var image để nhận image từ cameraViewController
    private var image: UIImage
    init(image: UIImage) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Edit"
        view.backgroundColor = .secondarySystemBackground
        
        imageView.image = image
        view.addSubview(imageView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.frame = CGRect(x: 0,
                                 y: view.safeAreaInsets.top,
                                 width: view.width,
                                 height: view.width)
    }
}
