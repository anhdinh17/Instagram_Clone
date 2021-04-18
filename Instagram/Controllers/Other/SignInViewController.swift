//
//  SignInViewController.swift
//  Instagram
//
//  Created by Anh Dinh on 4/13/21.
//

import UIKit
import SafariServices

class SignInViewController: UIViewController, UITextFieldDelegate {

    // instance of headerView to add to this View
    private let headerView = SignInHeaderView()
    
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
        field.placeholder = "Password"
        field.keyboardType = .default
        field.returnKeyType = .continue
        field.autocorrectionType = .no
        field.isSecureTextEntry =  true
        field.backgroundColor = .secondarySystemBackground
        
        return field
    }()
    
    private let signInButton: UIButton = {
        let button = UIButton()
        button.setTitle("Sign In", for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        return button
    }()
    
    private let createAccountButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.link, for: .normal)
        button.setTitle("Create Account", for: .normal)
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
 
//MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Sign in"
        view.backgroundColor = .systemBackground
        
        emailField.delegate = self
        passwordField.delegate = self
        
        addSubViews()
        
        addButtonAction()

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        headerView.frame = CGRect(x: 0,
                                  y: view.safeAreaInsets.top,
                                  width: view.width,
                                  height: (view.height - view.safeAreaInsets.top)/3)
        
        emailField.frame = CGRect(x: 25,
                                  y: headerView.bottom + 20,
                                  width: view.width - 50,
                                  height: 50)
        passwordField.frame = CGRect(x: 25,
                                  y: emailField.bottom + 10,
                                  width: view.width - 50,
                                  height: 50)
        signInButton.frame = CGRect(x: 35,
                                  y: passwordField.bottom + 20,
                                  width: view.width - 70,
                                  height: 50)
        createAccountButton.frame = CGRect(x: 35,
                                  y: signInButton.bottom + 20,
                                  width: view.width - 70,
                                  height: 50)
        termsButton.frame = CGRect(x: 35,
                                  y: createAccountButton.bottom + 50,
                                  width: view.width - 70,
                                  height: 40)
        privacyButton.frame = CGRect(x: 35,
                                  y: termsButton.bottom + 10,
                                  width: view.width - 70,
                                  height: 40)
    }
    
    private func addSubViews(){
        // add headerView
        view.addSubview(headerView)
        
        // add emailField, passwordField, buttons
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(signInButton)
        view.addSubview(createAccountButton)
        view.addSubview(termsButton)
        view.addSubview(privacyButton)
    }
    
    private func addButtonAction(){
        signInButton.addTarget(self, action: #selector(didTapSignIn), for: .touchUpInside)
        createAccountButton.addTarget(self, action: #selector(didTapCreateAccount), for: .touchUpInside)
        termsButton.addTarget(self, action: #selector(didTapTerms), for: .touchUpInside)
        privacyButton.addTarget(self, action: #selector(didTapPrivacy), for: .touchUpInside)
    }
    
//MARK: - Actions
    @objc func didTapSignIn(){
        //!email.trimmingCharacters(in: .whitespaces).isEmpty is to make sure it's not empty and even when users just type in spaces, we catch that too.
        guard let email = emailField.text,
              let password = passwordField.text,
              !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespaces).isEmpty,
              password.count >= 6 else {
            return
        }
    }
    
    @objc func didTapCreateAccount(){
        let vc = SignUpViewController()
        vc.completion = {[weak self] in
            DispatchQueue.main.async {
                let tabVC = TabBarViewController()
                tabVC.modalPresentationStyle = .fullScreen
                self?.present(tabVC,animated: true)
            }
        }
        
        // use navigationController to display SignUpViewController when clicking on the button
        // so we go from Sign-in View to Sign-up View
        navigationController?.pushViewController(vc, animated: true)
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
        if textField == emailField{
            passwordField.becomeFirstResponder()
        }else{
            textField.resignFirstResponder()
            didTapSignIn() // run didTapSignIn() func when hitting return button
        }
        return true
    }

}
