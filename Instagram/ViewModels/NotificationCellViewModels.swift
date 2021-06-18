//
//  NotificationCellViewModels.swift
//  Instagram
//
//  Created by Anh Dinh on 6/10/21.
//

import Foundation

struct LikeNotificationCellViewModel: Equatable {
    let username: String
    let profilePictureUrl: URL
    let postUrl: URL
}

struct FollowNotificationCellViewModel: Equatable {
    let username: String
    let profilePictureUrl: URL
    let isCurrentUserFollowing: Bool
}

struct CommentNotificationCellViewModel: Equatable {
    let username: String
    let profilePictureUrl: URL
    let postUrl: URL
}
