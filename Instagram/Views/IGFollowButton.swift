//
//  IGFollowButton.swift
//  Instagram
//
//  Created by Anh Dinh on 7/26/21.
//

import UIKit

final class IGFollowButton: UIButton {

    enum State: String {
        case follow = "Follow"
        case unfollow = "Unfollow"
        
        // Computed variable within an enum, cái này mới
        var titleColor: UIColor {
            switch self {
            case .follow: return .white
            case .unfollow: return .label
            }
        }
        
        var backgroundColor: UIColor {
            switch self {
            case .follow: return .systemBlue
            case .unfollow: return .tertiarySystemBackground
            }
        }
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 4
        layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }

    public func configure(
        for state: State
    ){
        // Because this class is a UIButton, this func is for the button Settings
        setTitle(state.rawValue, for: .normal)
        backgroundColor = state.backgroundColor // based on enum to set background
        setTitleColor(state.titleColor, for: .normal)
        
        switch state {
        case .follow:
            layer.borderWidth = 0
        case .unfollow:
            layer.borderWidth = 0.5
            layer.borderColor = UIColor.secondaryLabel.cgColor
        }
        
    }
    
}
