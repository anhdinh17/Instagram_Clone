//
//  Notification.swift
//  Instagram
//
//  Created by Anh Dinh on 4/13/21.
//

import Foundation

// IGNotification is for someone who like/comment/follow your post - this is not for current user
struct IGNotification: Codable {
    let identifier: String
    let notificationType: Int //1: like, 2: comment, 3: follow
    let profilePictureUrl: String
    let username: String
    let dateString: String
    // Follow/Unfollow
    let isFollowing: Bool?
    // Like/Comment
    let postId: String?
    let postUrl: String?
}
