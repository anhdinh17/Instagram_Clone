//
//  DatabaseManager.swift
//  Instagram
//
//  Created by Anh Dinh on 4/13/21.
//

import Foundation
import FirebaseFirestore

final class DatabaseManager {
    static let shared = DatabaseManager()
    
    private init(){}
    
    let database = Firestore.firestore()
    
    // Add user to Firebase Database
    public func createUser(newUser: User, completion: @escaping (Bool)->Void){
        let reference = database.document("users/\(newUser.username)")
        guard let data = newUser.asDictionary() else { // get a dictionary from asDictionary()
            completion(false)
            return
        }
        reference.setData(data){error in
            completion(error == nil)
        }
    }
}
