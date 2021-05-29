//
//  CaptionViewController.swift
//  Instagram
//
//  Created by Anh Dinh on 4/13/21.
//

import UIKit

class CaptionViewController: UIViewController {

    private let image: UIImage
    
    private let imageView: UIImageView = {
        let image = UIImageView()
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    private let textView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 22)
        textView.text = "Add caption..."
        textView.backgroundColor = .secondarySystemBackground
        textView.textContainerInset = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        return textView
    }()
    
    init(image: UIImage) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        view.backgroundColor = .secondarySystemBackground
        
        // add subviews
        view.addSubview(imageView)
        imageView.image = image
        
        view.addSubview(textView)
        
        // textView delegate
        textView.delegate = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Post",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapPost))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var size: CGFloat = view.width/4
        imageView.frame = CGRect(x: (view.width-size)/2, // center x
                                 y: view.safeAreaInsets.top + 10,
                                 width: size,
                                 height: size)
        
        textView.frame = CGRect(x: 20, // center x
                                y: imageView.bottom + 30,
                                width: view.width - 40,
                                 height: 100)
    }
    
    @objc func didTapPost(){
        // get rid of keyboard
        textView.resignFirstResponder()
        
        // get the caption
        var caption = textView.text ?? ""
        if caption == "Add caption..."{
            caption = ""
        }
        
        // Generate post ID
        guard let newPostID = createNewPostID() else {
            return
        }
        
        // Upload Post
        StorageManager.shared.uploadPost(id: newPostID,
                                         data: image.pngData()) { (newPostDownloadURL) in
            // Nếu true thì update database
            // nhận lại url của tấm hình post
            guard let url = newPostDownloadURL else {
                print("error: Failed to upload post to Storage")
                return
            }
            
            // New Post
            guard let stringDate = String.date(from: Date()) else { return} // get a date as String
            let newPost = Post(id: newPostID,
                               caption: caption,
                               postedDate: stringDate,
                               likers: [],
                               postUrlString: url.absoluteString)
            
            // Update Database
            DatabaseManager.shared.createPost(newPost: newPost ) { [weak self] finished in
                guard finished else {
                    return
                }
                
                DispatchQueue.main.async {
                    // trở về root view: HomeViewVC
                    self?.tabBarController?.tabBar.isHidden = false
                    self?.tabBarController?.selectedIndex = 0
                    self?.navigationController?.popToRootViewController(animated: false) // ko có dòng này thì nó vẫn trả về HomeViewController
                }
            }
        }
    }

    private func createNewPostID() -> String? {
        let timeStamp = Date().timeIntervalSince1970
        let randomNumber = Int.random(in: 0...1000)
        guard let username = UserDefaults.standard.string(forKey: "username") else{
            return nil
        }
        return "\(username)_\(randomNumber)_\(timeStamp)"
    }
}

//MARK: - TextView Delegate
extension CaptionViewController: UITextViewDelegate {
    // When users tap into textView
    func textViewDidBeginEditing(_ textView: UITextView) {
        // bỏ "Add caption..." khi users tap vào textView
        if textView.text == "Add caption..."{
            textView.text = nil
        }
    }
}
