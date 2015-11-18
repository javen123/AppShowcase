//
//  DataService.swift
//  AppsNevaShowcase
//
//  Created by Jim Aven on 11/18/15.
//  Copyright © 2015 Jim Aven. All rights reserved.
//

import Foundation
import Firebase

let URL_BASE = "https://appsnevashowcase.firebaseio.com"

class DataService {
    
    static let ds = DataService()
    
    private var _ref_base = Firebase(url: "\(URL_BASE)")
    private var _ref_posts = Firebase(url: "\(URL_BASE)/posts")
    private var _ref_users = Firebase(url: "\(URL_BASE)/users")
    
    var ref_base:Firebase {
        return _ref_base
    }
    var ref_posts:Firebase {
        return _ref_posts
    }
    
    var ref_users:Firebase {
        return _ref_users
    }
    
    func createFiresbaseUser(uid:String, user:Dictionary<String, String>){
        ref_users.childByAppendingPath(uid).setValue(user)
    }
    
}
