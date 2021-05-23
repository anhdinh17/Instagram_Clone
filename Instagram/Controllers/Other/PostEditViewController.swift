//
//  PostEditViewController.swift
//  Instagram
//
//  Created by Anh Dinh on 5/20/21.
//

import UIKit
import CoreImage


class PostEditViewController: UIViewController {

    // create an array of UIImage for filter symbol used with collectionView
    private var filters = [UIImage]()
    
    private let imageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        return image
    }()
    
    // Tạo 1 var image để nhận image từ CameraViewController
    private var image: UIImage
    init(image: UIImage) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }
    
    
    // CollectionView
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 2
        layout.sectionInset = UIEdgeInsets(top: 1, left: 10, bottom: 1, right: 10)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .secondarySystemBackground
        collectionView.register(PhotoCollectionViewCell.self,
                                forCellWithReuseIdentifier: PhotoCollectionViewCell.identifier)
        return collectionView
    }()
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Edit"
        view.backgroundColor = .secondarySystemBackground
        
        imageView.image = image
        view.addSubview(imageView)
        
        setupFilters()
        
        // add collectionView
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Create a Next button on the rigt of nav bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(didTapNext))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.frame = CGRect(x: 0,
                                 y: view.safeAreaInsets.top,
                                 width: view.width,
                                 height: view.width)
        
        collectionView.frame = CGRect(x: 0,
                                      y: imageView.bottom + 20,
                                      width: view.width,
                                      height: 100)
    }
    
    // Func to filter image to be black and white
    // FYI: filter image is a heavy process, we need to run it in dispatchQueue.Main.async to save memory
    private func filterImage(image: UIImage){
        guard let cgImage = image.cgImage else {
            return
        }
        
        let filter = CIFilter(name: "CIColorMonochrome")
        filter?.setValue(CIImage(cgImage: cgImage), forKey: "inputImage")
        filter?.setValue(CIColor(red: 0.7, green: 0.7, blue: 0.7), forKey: "inputColor")
        filter?.setValue(1.0, forKey: "inputIntensity")
        
        guard let outputImage = filter?.outputImage else {
            return
        }
        
        let context = CIContext()
        
        if let outputcgImage = context.createCGImage(outputImage,
                                                     from: outputImage.extent){
            let filteredImage = UIImage(cgImage: outputcgImage)
            
            // set image to be the filtered image which is black and white now.
            imageView.image = filteredImage
        }
        
    }
    
    private func setupFilters(){
        guard let filterImage = UIImage(systemName: "camera.filters") else {
            return
        }
        filters.append(filterImage)
    }
    
    @objc func didTapNext(){
        let vc = CaptionViewController(image: image)
        vc.title = "Add Caption"
        navigationController?.pushViewController(vc, animated: true)
    }
}


//MARK: - CollectionView Delegate and DataSource
extension PostEditViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    // number of Items
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.identifier, for: indexPath) as? PhotoCollectionViewCell else {
            fatalError()
        }
        cell.configure(with: filters[indexPath.row])
        return cell
    }
    
    // Delegate - what happens when clicking on item
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        // runs filter func to make image black and white when clicking on item
        DispatchQueue.main.async {
            self.filterImage(image: self.image)
        }
    }
    
}
