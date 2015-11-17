//
//  MaterialBtn.swift
//  AppsNevaShowcase
//
//  Created by Jim Aven on 11/17/15.
//  Copyright © 2015 Jim Aven. All rights reserved.
//

import UIKit

class MaterialBtn: UIButton {
    
    override func awakeFromNib() {
        layer.cornerRadius = 2.0
        layer.shadowColor = UIColor(red: SHADOW_COLOR, green: SHADOW_COLOR, blue: SHADOW_COLOR, alpha: 0.5).CGColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 5.0
        layer.shadowOffset = CGSizeMake(0.0, 2.0)
        
        
    }


}
