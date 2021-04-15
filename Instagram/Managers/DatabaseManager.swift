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
}
