//
//  AnalyticsManager.swift
//  Instagram
//
//  Created by Anh Dinh on 4/13/21.
//

import Foundation
import FirebaseAnalytics

final class AnalyticsManager {
    static let shared = AnalyticsManager()
    
    private init(){}
    
    func logEvent(){
        Analytics.logEvent("", parameters: [:])
    }
}
