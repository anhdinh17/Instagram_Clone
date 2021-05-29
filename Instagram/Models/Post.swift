//
//  Post.swift
//  Instagram
//
//  Created by Anh Dinh on 4/13/21.
//

import Foundation

struct Post: Codable {
    let id: String
    let caption: String
    let postedDate: String
    var likers: [String]
    let postUrlString: String
    
    var storageReference: String?{
        guard let username = UserDefaults.standard.string(forKey: "username") else { return nil}
        // return the directory of the position of the post on Storage
        return "\(username)/post/\(id).png"
    }
}
