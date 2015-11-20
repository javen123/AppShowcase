//
//  Post.swift
//  AppsNevaShowcase
//
//  Created by Jim Aven on 11/18/15.
//  Copyright © 2015 Jim Aven. All rights reserved.
//

import Foundation
import Firebase

class Post {
    
    private var _postDescription:String?
    private var _imageUrl:String?
    private var _likes:Int!
    private var _username:String!
    private var _postKey:String!
    private var _postRef:Firebase!
    
    var postDescription:String? {
        return _postDescription
    }
    
    var imageUrl:String? {
        return _imageUrl
    }
    
    var likes:Int {
        return _likes
    }
    
    var username:String {
        return _username
    }
    
    var postKey:String {
        return _postKey
    }
    
    init(desc:String, imageURL:String?, username:String){
        self._postDescription = desc
        self._imageUrl = imageURL
        self._username = username
    }
    
    init(postKey:String, dictionary:Dictionary<String, AnyObject>) {
        
        self._postKey = postKey
        
        if let likes = dictionary["likes"] as? Int {
            self._likes = likes
        }
        
        if let imgURL = dictionary["imageURL"] {
            self._imageUrl = imgURL as? String
        }
        
        if let desc = dictionary["description"] as? String {
            self._postDescription = desc
        }
        
        self._postRef = DataService.ds.ref_posts.childByAppendingPath(self._postKey)
    }
    
    func adjustLikes(addLike:Bool) {
        
        if addLike {
            _likes = _likes + 1
        } else {
            _likes = _likes - 1
        }
        
        _postRef.childByAppendingPath("likes").setValue(_likes)
        
    }
    
}
