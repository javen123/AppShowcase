//
//  DataService.swift
//  AppsNevaShowcase
//
//  Created by Jim Aven on 11/18/15.
//  Copyright © 2015 Jim Aven. All rights reserved.
//

import Foundation
import Firebase
import SwiftSpinner

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
    
    var ref_cur_user:Firebase {
        
        let uid = NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) as! String
        let user = Firebase(url: "\(URL_BASE)").childByAppendingPath("users").childByAppendingPath(uid)
        return user!
    }
    
    func createFiresbaseUser(uid:String, user:Dictionary<String, String>){
        ref_users.childByAppendingPath(uid).setValue(user)
        
    }
    
    func authUserFirebase(user:String, passwd:String) {
        
            ref_base.authUser(user, password: passwd) {
                error, result in
                if error != nil {
                    
                }
        }
        
        
    }
    
    func removePost (key:String, completed:DownloadComplete) -> Int?{
        
        let post = Firebase(url: "\(URL_BASE)/posts/\(key)")
        var success:Int?
        post.removeValueWithCompletionBlock {
            
            error, result in
    
            if error != nil {
                print(error.debugDescription)
                success = error.code
            }
            else if result != nil {
                print(result.authData.uid)
                
            }
            
            completed()
        }
        
        return success
    }
}
