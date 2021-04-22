//
//  AuthManager.swift
//  Instagram
//
//  Created by Anh Dinh on 4/13/21.
//

import FirebaseAuth
import Foundation


final class AuthMangager {
    static let shared = AuthMangager()
    
    private init(){}
    
    let auth = Auth.auth()
    
    enum AuthError: Error {
        case newUserCreation
        case signInFailed
    }
    
    public var isSignedIn: Bool {
        // return true if uers are signed in
        return auth.currentUser != nil // users signed in
    }
    
//MARK: - func to sign in
    public func signIn(email: String,
                       password: String,
                       completion: @escaping (Result<User, Error>) -> Void){
        DatabaseManager.shared.findUser(with: email) { [weak self] (user) in
            guard let user = user else{
                completion(.failure(AuthError.signInFailed))
                return
            }
            
            self?.auth.signIn(withEmail: email, password: password) { (result, error) in
                guard result != nil, error == nil else {
                    completion(.failure(AuthError.signInFailed))
                    return
                }
                // save to system
                UserDefaults.standard.setValue(user.username, forKey: "username")
                UserDefaults.standard.setValue(user.email, forKey: "email")
                
                // run completion block success with user
                completion(.success(user))
        }
        
        }
    }

//MARK: - func to sign up
    public func signUp(email: String,
                       password: String,
                       username: String,
                       profilePicture: Data?,
                       completion:@escaping (Result<User, Error>) -> Void){
        
        let newUser = User(username: username, email: email)
        
        // create user in Firebase Authentication
        auth.createUser(withEmail: email,
                        password: password) { (result, error) in
            guard result != nil, error == nil else {
                completion(.failure(AuthError.newUserCreation))
                return
            }
            
            // we want to insert these info into Firebase Database
            DatabaseManager.shared.createUser(newUser: newUser){success in
                // if adding success, we upload profile picture to storage
                if success {
                    StorageManager.shared.uploadProfilePicture(username: username,
                                                               data: profilePicture) { (uploadSuccess) in
                        if uploadSuccess{
                            completion(.success(newUser))
                        }else{
                            completion(.failure(AuthError.newUserCreation))
                        }
                    }
                } else {
                    completion(.failure(AuthError.newUserCreation))
                }
            }
            
        }
    }
    
//MARK: - func to sign out
    public func signOut(completion: @escaping (Bool) -> Void){
        do{
            try auth.signOut()
            completion(true)
        }catch{
            print(error)
            completion(false)
        }
        
    }
    
}
