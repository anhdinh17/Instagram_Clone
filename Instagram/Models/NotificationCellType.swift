//
//  NotificationCellType.swift
//  Instagram
//
//  Created by Anh Dinh on 6/10/21.
//

import Foundation

enum NotificationCellType {
    case follow(viewModel: FollowNotificationCellViewModel)
    case like(viewModel: LikeNotificationCellViewModel)
    case comment(viewModel: CommentNotificationCellViewModel)
}

