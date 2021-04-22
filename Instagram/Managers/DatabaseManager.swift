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
    
    public func findUser(with email: String, completion: @escaping (User?) -> Void){
        let ref = database.collection("users") // "users" collection on Firestore Database
        ref.getDocuments { (snapshot, error) in // get all documents within "users"
            // dòng này chuyển toàn bộ documents trên firebase database thành array của "User" struct
            // bởi vì trong extension, chúng ta đã set code để convert dictionary(form của của database) thành Object
            guard let users = snapshot?.documents.compactMap({User(with: $0.data())}),
                  error == nil else {
                completion(nil)
                return
            }
            
            // check trong array trên, element nào có email giống email người sử dụng type vô, pass element đó vô "user" variable này.
            // thằng user này bây giờ là 1 instance của struct "User"
            let user = users.first(where: {$0.email == email})
            
            // run completion block with user
            completion(user)
        }
    }
    
    // Add user to Firebase Database
    public func createUser(newUser: User, completion: @escaping (Bool)->Void){
        let reference = database.document("users/\(newUser.username)")
        guard let data = newUser.asDictionary() else { // get a dictionary from asDictionary()
            completion(false)
            return
        }
        // set the dictionary [email:username] to Firestore Database under the documents "users"
        reference.setData(data){error in
            completion(error == nil)
        }
    }
}
