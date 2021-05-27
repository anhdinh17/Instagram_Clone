//
//  CameraViewController.swift
//  Instagram
//
//  Created by Anh Dinh on 4/13/21.
//

import UIKit
import AVFoundation


class CameraViewController: UIViewController {

    // properties for using camera
    private var output = AVCapturePhotoOutput()
    private var captureSession: AVCaptureSession?
    // thằng layer này chính là camera hiện trên màn hình
    private let previewLayer = AVCaptureVideoPreviewLayer()
    

    private let cameraView = UIView()

    // Button to take photo
    private let shutterButton: UIButton = {
        let button = UIButton()
        button.layer.masksToBounds = true
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.label.cgColor
        button.backgroundColor = nil
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .secondarySystemBackground

        title = "Take Photos"
        
        // add cameraView and shutterButton
        view.addSubview(cameraView)
        view.addSubview(shutterButton)
        
        // set nav bar
        setUpNavBar()
        
        checkCameraPermission()
        
        // add actions to shutterButton
        shutterButton.addTarget(self, action: #selector(didTapTakePhoto), for: .touchUpInside)
    }
    
    // We want to get rid of the tab bar when we are in CameraViewController
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // get rid of tab bar
        tabBarController?.tabBar.isHidden = true
        
        // start the camera if we get into Camera view and in case we just switch from other view to Camera view
        // !session.isRunning -> nếu camera đang ko chạy
        if let session = captureSession, !session.isRunning {
            session.startRunning()
        }
    }
    
    // Stop running the camera when we switch to other view
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        captureSession?.stopRunning()
    }
    
//MARK: - viewDidLayoutSubviews
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        cameraView.frame = view.bounds
        
        previewLayer.frame = CGRect(x: 0,
                                    y: view.safeAreaInsets.top,
                                    width: view.width,
                                    height: view.width)
        
        let buttonSize: CGFloat = view.width/4
        shutterButton.frame = CGRect(x: (view.width - buttonSize)/2, // center button
                                     y: view.safeAreaInsets.top + view.width + 150,
                                     width: buttonSize,
                                     height: buttonSize)
        shutterButton.layer.cornerRadius = buttonSize/2
    }

//MARK: - Button action func
    @objc func didTapTakePhoto(){
        output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
    }
    
    @objc func didTapClose(){
        // Tap on didTapClose -> bring back to HomeViewController
        tabBarController?.selectedIndex = 0
        tabBarController?.tabBar.isHidden = false
    }

//MARK: - Set NavBar and Camera
    private func setUpNavBar(){
        // add bar button to the left of nav bar, this button is a close button
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close,
                                                           target: self,
                                                           action: #selector(didTapClose))
    }
    
    // Don't know why we have to check permission for camera,
    // this may be a step that we have to do
    private func checkCameraPermission(){
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video){
        
        case .notDetermined:
            // request camera
            AVCaptureDevice.requestAccess(for: .video) { [weak self](granted) in
                guard granted else {
                    return
                }
                DispatchQueue.main.async {
                    self?.setUpCamera()
                }
            }
        case .authorized:
            setUpCamera()
        case .restricted,.denied:
            break
        @unknown default:
            break
        }
    }
    
    private func setUpCamera(){
        let captureSession = AVCaptureSession()
        
        if let device = AVCaptureDevice.default(for: .video){
            do{
                let input = try AVCaptureDeviceInput(device: device)
                if captureSession.canAddInput(input){
                    captureSession.addInput(input)
                }
            }catch{
                print(error)
            }
            
            if captureSession.canAddOutput(output){
                captureSession.addOutput(output)
            }
            
            // Layer
            // thằng layer này chính là camera hiện trên màn hình
            previewLayer.session = captureSession
            previewLayer.videoGravity = .resizeAspectFill
            // add layer to cameraView
            cameraView.layer.addSublayer(previewLayer)
            
            captureSession.startRunning()
        }
    }
    
    
}

//MARK: - Delegate for AVCapture
extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        // check if we get data
        guard let data = photo.fileDataRepresentation() else {
            return
        }
        
        // ngưng camera sau khi click chụp
        captureSession?.stopRunning()
        
        // Tạo 1 image, pass image này qua PostEditVC
        guard let image = UIImage(data: data) else {
            return
        }
        
        // resized image first rồi mới chuyển để khi filter ko bị ngược rotation
        guard let resizedImage = image.sd_resizedImage(with: CGSize(width: 640, height: 640),
                                                       scaleMode: .aspectFill)
        else{
            return
        }
        // Pass image to PostEditVC
        let vc = PostEditViewController(image: resizedImage)
        navigationController?.pushViewController(vc, animated: true)
        
    }
}
