//
//  StorageManager.swift
//  Instagram
//
//  Created by Anh Dinh on 4/13/21.
//

import Foundation
import FirebaseStorage

final class StorageManager {
    static let shared = StorageManager()
    
    private init(){}
    
    let storage = Storage.storage().reference()
    
    // upload profile picture to FireBase Storage
    public func uploadProfilePicture(username: String,
                                     data: Data?,
                                     completion: @escaping(Bool)->Void){
        guard let data = data else {
            return
        }
        storage.child("\(username)/profile_picture.png").putData(data, metadata: nil) { (_, error) in
            completion(error == nil)
        }
    }
    
    // Upload a Post to Firebase Storage
    // Func này nghiã là: in Storage, under the same username we use for uploadProfilePicture(), we create another sub file which is "post", in that file we have the post picture with an id.
    public func uploadPost(
        id: String,
        data: Data?,
        completion: @escaping(URL?)->Void){
        guard let data = data,
              let username = UserDefaults.standard.string(forKey: "username") else {
            return
        }
        let ref = storage.child("\(username)/post/\(id).png")
        ref.putData(data, metadata: nil) { (_, error) in
            ref.downloadURL { (url, _) in
                completion(url)
            }
            
        }
    }
    
    // download the url of the post
    public func downloadURL(for post: Post, completion: @escaping (URL?)->Void){
        guard let ref = post.storageReference else {
            return
        }
        storage.child(ref).downloadURL { (url, _) in // ignore error in this closure
            completion(url) // after runs main task, return a url, url này chính là url dành cho mỗi post
        }
    }
    
    // URL of the profile picture 
    public func profilePictureURL(username: String, completion: @escaping(URL?)->Void){
        storage.child("\(username)/profile_picture.png").downloadURL { (url, _) in
            completion(url)
        }
    }
    
}
