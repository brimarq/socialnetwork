//
//  DataService.swift
//  socialnetwork
//
//  Created by Brian Marquis on 8/1/17.
//  Copyright © 2017 brimarq. All rights reserved.
//

import Foundation
import Firebase

// Get the Firebase database base url from the GoogleService-Info.plist and store it in a constant.
let DB_BASE = Database.database().reference()

class DataService {
    
    // Create a singleton class (singular instance of a class that is globally available)
    static let ds = DataService()
    
    private var _REF_BASE = DB_BASE
    private var _REF_POSTS = DB_BASE.child("posts")
    private var _REF_USERS = DB_BASE.child("users")
    
    var REF_BASE: DatabaseReference {
        return _REF_BASE
    }
    
    var REF_POSTS: DatabaseReference {
        return _REF_POSTS
    }
    
    var REF_USERS: DatabaseReference {
        return _REF_USERS
    }
    
    func createFirebaseDBUser(uid: String, userData: Dictionary<String, String>) {
        REF_USERS.child(uid).updateChildValues(userData)
    }
    
    
    
    
}
