//
//  PostCell.swift
//  AppsNevaShowcase
//
//  Created by Jim Aven on 11/18/15.
//  Copyright © 2015 Jim Aven. All rights reserved.
//

import UIKit

class PostCell: UITableViewCell {

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var showcaseImg: UIImageView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var likesLbl: UILabel!
    
    var post:Post!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        
        
    }
    
    override func drawRect(rect: CGRect) {
        
        profileImg.layer.cornerRadius = profileImg.frame.size.width / 2
        profileImg.clipsToBounds = true
        
        showcaseImg.clipsToBounds = true
    }

    func configureCell(post:Post){
        
        self.post = post
        self.likesLbl.text = "\(post.likes)"
        
        
    }


}
