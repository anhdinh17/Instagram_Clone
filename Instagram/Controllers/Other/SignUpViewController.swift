//
//  SignUpViewController.swift
//  Instagram
//
//  Created by Anh Dinh on 4/13/21.
//

import UIKit
import SafariServices

class SignUpViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    private let profilePictureImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .lightGray
        imageView.image = UIImage(systemName: "person.circle")
        imageView.contentMode = .scaleToFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 45
        return imageView
    }()
    
    private let usernamelField: IGTextField = {
        let field = IGTextField()
        field.placeholder = "User name"
        field.returnKeyType = .next
        field.autocorrectionType = .no
        field.backgroundColor = .secondarySystemBackground
        
        return field
    }()
    
    private let emailField: IGTextField = {
        let field = IGTextField()
        field.placeholder = "Email Address"
        field.keyboardType = .emailAddress
        field.returnKeyType = .next
        field.autocorrectionType = .no
        field.backgroundColor = .secondarySystemBackground
        
        return field
    }()
    
    private let passwordField: IGTextField = {
        let field = IGTextField()
        field.placeholder = "Create Password"
        field.keyboardType = .default
        field.returnKeyType = .continue
        field.autocorrectionType = .no
        field.isSecureTextEntry =  true
        field.backgroundColor = .secondarySystemBackground
        
        return field
    }()
    
    private let signUpButton: UIButton = {
        let button = UIButton()
        button.setTitle("Sign Up", for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        return button
    }()
        
    private let termsButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.link, for: .normal)
        button.setTitle("Terms of Service", for: .normal)
        return button
    }()
    
    private let privacyButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.link, for: .normal)
        button.setTitle("Privacy Policy", for: .normal)
        return button
    }()
 
    public var completion: (() -> Void)?
    
//MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Create Account"
        view.backgroundColor = .systemBackground
        
        usernamelField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        
        addSubViews()
        
        addButtonAction()
        
        // select image for profile picture
        addImageGesture()

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let imageSize: CGFloat = 90
        
        profilePictureImageView.frame = CGRect(x: (view.width - imageSize)/2,
                                  y: view.safeAreaInsets.top + 15,
                                  width: imageSize,
                                  height: imageSize)
        usernamelField.frame = CGRect(x: 25,
                                  y: profilePictureImageView.bottom + 20,
                                  width: view.width - 50,
                                  height: 50)
        emailField.frame = CGRect(x: 25,
                                  y: usernamelField.bottom + 10,
                                  width: view.width - 50,
                                  height: 50)
        passwordField.frame = CGRect(x: 25,
                                  y: emailField.bottom + 10,
                                  width: view.width - 50,
                                  height: 50)
        signUpButton.frame = CGRect(x: 35,
                                  y: passwordField.bottom + 20,
                                  width: view.width - 70,
                                  height: 50)
        termsButton.frame = CGRect(x: 35,
                                  y: signUpButton.bottom + 50,
                                  width: view.width - 70,
                                  height: 40)
        privacyButton.frame = CGRect(x: 35,
                                  y: termsButton.bottom + 10,
                                  width: view.width - 70,
                                  height: 40)
    }
    
    private func addSubViews(){

        view.addSubview(profilePictureImageView)
        view.addSubview(usernamelField)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(signUpButton)
        view.addSubview(termsButton)
        view.addSubview(privacyButton)
    }
    
    private func addImageGesture(){
        // add gestureRecognizer to profileImageView so when we tap on image, we can do stuff
        let tap = UITapGestureRecognizer(target: self, action: #selector(didtapImage))
        profilePictureImageView.isUserInteractionEnabled = true
        profilePictureImageView.addGestureRecognizer(tap)
    }
    
    private func addButtonAction(){
        signUpButton.addTarget(self, action: #selector(didTapSignUp), for: .touchUpInside)
        termsButton.addTarget(self, action: #selector(didTapTerms), for: .touchUpInside)
        privacyButton.addTarget(self, action: #selector(didTapPrivacy), for: .touchUpInside)
    }
    
//MARK: - Actions
    @objc func didtapImage(){
        let sheet = UIAlertController(title: "Profile Picture",
                                      message: "Set a picture to help your friends find you.",
                                      preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        sheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { [weak self] (_) in
            DispatchQueue.main.async {
                //view controller that manages the system interfaces for taking pictures, recording movies, and choosing items from the user's media library.
                let picker = UIImagePickerController()
                picker.allowsEditing = true // this one is for cropping the image to make it square
                picker.sourceType = .camera
                picker.delegate = self
                self?.present(picker, animated: true)
            }
        }))
        sheet.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { [weak self] (_) in
            DispatchQueue.main.async {
                let picker = UIImagePickerController()
                picker.allowsEditing = true
                picker.sourceType = .photoLibrary
                picker.delegate = self
                self?.present(picker, animated: true)
            }
        }))
        
        present(sheet, animated: true, completion: nil)
    }
    
    @objc func didTapSignUp(){
        
        usernamelField.resignFirstResponder()
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        //!email.trimmingCharacters(in: .whitespaces).isEmpty is to make sure it's not empty and even when users just type in spaces, we catch that too.
        guard let username = usernamelField.text,
              let email = emailField.text,
              let password = passwordField.text,
              !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespaces).isEmpty,
              !username.trimmingCharacters(in: .whitespaces).isEmpty,
              password.count >= 6,
              username.count >= 2,
              username.trimmingCharacters(in: .alphanumerics).isEmpty
        else {
            presentError()
            return
        }
        
        let data = profilePictureImageView.image?.pngData()
        
        // SIGN UP WITH AUTHMANAGER
        AuthMangager.shared.signUp(email: email,
                                   password: password,
                                   username: username,
                                   profilePicture: data) {[weak self] (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):// user này là object User, cái này từ completion(.success(newUser)) của Authmanager(đoán vậy)
                    
                    // store data to system
                    UserDefaults.standard.setValue(user.email, forKey: "email")
                    UserDefaults.standard.setValue(user.username, forKey: "username")
                    
                    // if success, go back to root VC and run completion() block
                    self?.navigationController?.popToRootViewController(animated: true)
                    self?.completion?() // present main application user interface
                case .failure(let error):
                    print("\n\nSign Up Error: \(error)")
                }
            }
        }
    }
    
    private func presentError(){
        let alert = UIAlertController(title: "Woops",
                                      message: "Please make sure to fill all fields and have a password longer than 6 characters",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    @objc func didTapTerms(){
        guard let url = URL(string: "") else {return}
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true)
    }
    
    @objc func didTapPrivacy(){
        guard let url = URL(string: "") else {return}
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true)
    }
    
//MARK: - TextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // this means if we are at emailField, when we hit return button,we move to passwordField.
        // else, keyboard dismisses when clicking on return button.
        if textField == usernamelField{
            emailField.becomeFirstResponder()
        }else if textField == emailField{
            passwordField.becomeFirstResponder()
        }else{
            textField.resignFirstResponder()
            didTapSignUp() // run didTapSignUp() func when hitting return button
        }
        return true
    }

//MARK: - Image Picker Delegate Funcs
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        // get the image users choose and set that to be profile picture
        // editedImage is that we ask users to crop the image to be squared
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        profilePictureImageView.image = image
    }
}
