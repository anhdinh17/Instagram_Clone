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
    
    public var isSignedIn: Bool {
        // return true if uers are signed in
        return auth.currentUser != nil // users signed in
    }
    
//MARK: - func to sign in
    public func signIn(email: String,
                       password: String,
                       completion: @escaping (Result<User, Error>) -> Void){
        
    }

//MARK: - func to sign up
    public func signUp(email: String,
                       password: String,
                       username: String,
                       profilePicture: Data?,
                       completion:@escaping (Result<User, Error>) -> Void){}
    
//MARK: - func to sign out
    public func signOut(completion: @escaping (Bool) -> Void){
        
    }
    
}
