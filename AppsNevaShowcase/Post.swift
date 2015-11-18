//
//  Post.swift
//  AppsNevaShowcase
//
//  Created by Jim Aven on 11/18/15.
//  Copyright © 2015 Jim Aven. All rights reserved.
//

import Foundation

class Post {
    
    private var _postDescription:String!
    private var _imageUrl:String?
    private var _likes:Int!
    private var _username:String!
    private var _postKey:String!
    
    var postDescription:String {
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
        
        if let imgURL = dictionary["imageUrl"] {
            self._imageUrl = imgURL as? String
        }
        
        if let desc = dictionary["descriptions"] as? String {
            self._postDescription = desc
        }
    }
    
}
