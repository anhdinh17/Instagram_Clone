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
    
    public func posts(for username: String, completion: @escaping (Result<[Post], Error>) -> Void){
        // query(directory) of the post that we want to read
        let ref = database.collection("users").document(username).collection("posts")
        // read the documents inside this query(directory)
        // cái đống dưới này là 1 array của Post struct trên Storage
        ref.getDocuments { (snapshot, error) in
            guard let posts = snapshot?.documents.compactMap({
                Post(with: $0.data()) // dòng này hiểu là: với mỗi element(là 1 object) của array, convert data bên trong [String:Any] thành 1 object của "Post"
            }),error == nil else {
                return
            }
  
            completion(.success(posts)) // return a "posts" array after main task done
        }
    }
    
    // find users used for search bar in Explore
    public func findUsers(with usernamePrefix: String,
                          completion: @escaping([User])->Void){
        let ref = database.collection("users") // "users" collection on Firestore Database
        ref.getDocuments { (snapshot, error) in // get all documents within "users"
            
            // dòng này chuyển toàn bộ documents trên firebase database thành array của "User" struct
            // bởi vì trong extension, chúng ta đã set code để convert dictionary(form của của database) thành Object
            guard let users = snapshot?.documents.compactMap({User(with: $0.data())}),
                  error == nil else {
                completion([]) // retrun a empty array
                return
            }
            
            // filter "users" array to get the item that has matching username with usernamePrefix
            let subset = users.filter({
                $0.username.lowercased().hasPrefix(usernamePrefix.lowercased())
            })
            
            // return a subset of [User]
            completion(subset)
        }
    }
    
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
        // tạo directory: "users"/username trên firebase Database
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
    
    // Add a post to Database under existing username
    public func createPost(newPost: Post, completion: @escaping (Bool)->Void){
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            completion(false)
            return
        }
        
        // tạo 1 directory based on what we already have:
        // under users/username ( cái mình đã tạo rồi khi tạo account) -> tạo 1 subfile post/ rồi trong đó tạo thêm newPost.id
        let reference = database.document("users/\(username)/posts/\(newPost.id)")
        guard let data = newPost.asDictionary() else { // convert object Post to dictionary to add to Firebase
            completion(false)
            return
        }
        
        reference.setData(data){error in
            completion(error == nil)
        }
    }
    
    public func explorePosts(completion: @escaping ([Post])->Void){
        let ref = database.collection("users") // "users" collection on Firestore Database
        ref.getDocuments { (snapshot, error) in // get all documents within "users"
            
            // dòng này chuyển toàn bộ documents trên firebase database thành array của "User" struct
            // bởi vì trong extension, chúng ta đã set code để convert dictionary(form của của database) thành Object
            guard let users = snapshot?.documents.compactMap({User(with: $0.data())}),
                  error == nil else {
                completion([])
                return
            }
            
            let group = DispatchGroup()
            var aggregatePosts = [Post]()
            
            users.forEach { (user) in
                let username = user.username
                let postsRef = self.database.collection("users/\(username)/posts") // directory của posts
                
                group.enter()
                
                postsRef.getDocuments { (snapshot, error) in
                    defer {
                        group.leave()
                    }
                    // chuyển tất cả các posts trong directory của postRef thành array của [Post]
                    guard let posts = snapshot?.documents.compactMap({Post(with: $0.data())}),
                          error == nil else {
                        return
                    }
                    
                    // add vô aggregatePosts array
                    aggregatePosts.append(contentsOf: posts)
                }
            }
            group.notify(queue: .main) {
                completion(aggregatePosts)
            }
        }
    }
    
    public func getNotifications(completion: @escaping ([IGNotification]) -> Void){
        
        guard let username = UserDefaults.standard.string(forKey: "username")
        else
        {
            completion([])
            return
        }
        
        // Vào directory cua "notifications", get all data from there, convert them to an array of "IGNotification"
        let ref = database.collection("users").document(username).collection("notifications")
        ref.getDocuments { (snapshot, error) in
            guard let notifications = snapshot?.documents.compactMap({IGNotification(with: $0.data())}),
                  error == nil else {
                completion([])
                return
            }
            
            completion(notifications)
        }
    }
    
    public func insertNotification(identifier: String, data: [String:Any], for username: String){
        let ref = database.collection("users")
            .document(username)
            .collection("notifications")
            .document(identifier)
        ref.setData(data)
    }
    
    // Xai trong NotificationVC
    // get a post from an id
    public func getPost(with identifier: String,
                        from username: String,
                        completion: @escaping (Post?)->Void){
        let ref = database.collection("users")
            .document(username)
            .collection("notifications")
            .document(identifier)
        ref.getDocument { (snapshot, error) in
            // lay het data trong id nay
            // cái này mình ko xài snapshot.documents.compactmap bởi vì mình chỉ lấy id của 1 thằng, chứ ko phải chuyển thành array
            guard let data = snapshot?.data(),
                  error == nil else {
                completion(nil)
                return
            }
            completion(Post(with: data)) //convert data to an object, extension da lam roi
        }
    }
    
    /// Follow states that are supported
    enum RelationshipState {
        case follow
        case unfollow
    }
    
    public func updateRelationship(
        state: RelationshipState,
        for targetUsername: String,
        completion: @escaping (Bool) -> Void
    ) {
        guard let currentUsername = UserDefaults.standard.string(forKey: "username") else {
            completion(false)
            return
        }

        // directory/path
        // directory này trên FB chưa có nhưng nếu ta sử dụng setData, deleter, etc. FB sẽ tự động tạo directory mà ta ref
        let currentFollowing = database.collection("users")
            .document(currentUsername)
            .collection("following")

        let targetUserFollowers = database.collection("users")
            .document(targetUsername)
            .collection("followers")

        switch state {
        case .unfollow:
            // Remove follower for currentUser following list
            currentFollowing.document(targetUsername).delete()
            // Remove currentUser from targetUser followers list
            targetUserFollowers.document(currentUsername).delete()

            completion(true)
        case .follow:
            // Add follower for requester following list
            currentFollowing.document(targetUsername).setData(["valid": "1"])
            // Add currentUser to targetUser followers list
            targetUserFollowers.document(currentUsername).setData(["valid": "1"])

            completion(true)
        }
    }
    
}
