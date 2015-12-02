//
//  PostCell.swift
//  AppsNevaShowcase
//
//  Created by Jim Aven on 11/18/15.
//  Copyright © 2015 Jim Aven. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

class PostCell: UITableViewCell {

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var showcaseImg: UIImageView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var heartLikeImg: UIImageView!
    
    var request:Request?
    
    var post:Post!
    
    var likeRef:Firebase!
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        let tap = UITapGestureRecognizer(target: self, action: "likeTapped:")
        tap.numberOfTapsRequired = 1
        heartLikeImg.addGestureRecognizer(tap)
        heartLikeImg.userInteractionEnabled = true
        
                
    }
    
    override func drawRect(rect: CGRect) {
        
        profileImg.layer.cornerRadius = profileImg.frame.size.width / 2
        profileImg.clipsToBounds = true
        
        showcaseImg.clipsToBounds = true
    }

    func configureCell(post:Post, img:UIImage?){
        
        self.post = post
        likeRef = DataService.ds.ref_cur_user.childByAppendingPath("likes").childByAppendingPath(post.postKey)
        self.likesLbl.text = "\(post.likes)"
       
        if let desc = post.postDescription where post.postDescription != "" {
            self.descriptionTextView.text = desc
        } else {
            self.descriptionTextView.hidden = true
        }
        
        
        if post.imageUrl != nil {
            if img != nil {
                self.showcaseImg.image = img
            } else {
                self.request = Alamofire.request(.GET, post.imageUrl!).validate(contentType: ["image/*"]).response(completionHandler: { request, response, data, error in
                    
                    if error == nil {
                        let aImg = UIImage(data: data!)!
                        self.showcaseImg.image = aImg
                        FeedVC.imgCache.setObject(aImg, forKey: self.post.imageUrl!)
                    } else {
                        print(error?.localizedDescription)
                    }
                })
            }
            
        } else {
            self.showcaseImg.hidden = true
        }
        
        
        
        likeRef.observeSingleEventOfType(.Value, withBlock: {
            
            snapshot in
            
            if let doesNotExist = snapshot.value as? NSNull {
               self.heartLikeImg.image = UIImage(named: "heart-empty")
            } else {
                self.heartLikeImg.image = UIImage(named: "heart-full")
            }
        })
    }

    func likeTapped (tap:UIGestureRecognizer) {
        
        likeRef.observeSingleEventOfType(.Value, withBlock: {
            
            snapshot in
            
            if let doesNotExist = snapshot.value as? NSNull {
                self.heartLikeImg.image = UIImage(named: "heart-full")
                self.post.adjustLikes(true)
                self.likeRef.setValue(true)
            } else {
                self.heartLikeImg.image = UIImage(named: "heart-empty")
                self.post.adjustLikes(false)
                self.likeRef.removeValue()
            }
        })
    }
    
}
