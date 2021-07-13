//
//  ProfileHeaderViewModel.swift
//  Instagram
//
//  Created by Anh Dinh on 7/13/21.
//

import Foundation

enum ProfileButtonType {
    case edit
    case follow(isFollowing: Bool)
}

struct ProfileHeaderViewModel {
    let profilePicture: URL?
    let followerCount: Int
    let followingCount: Int
    let postCount: Int
    let buttonType: ProfileButtonType
    let name: String?
    let bio: String?
}
