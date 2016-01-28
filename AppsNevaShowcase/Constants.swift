//
//  Constants.swift
//  AppsNevaShowcase
//
//  Created by Jim Aven on 11/17/15.
//  Copyright © 2015 Jim Aven. All rights reserved.
//

import Foundation
import UIKit

let SHADOW_COLOR:CGFloat = 157.0 / 255.0
let KEY_UID = "uid"


// Segues
let LOGGED_IN = "postLoginSegue"

// Status codes

let STATUS_DOES_NOT_EXIST = -8

//imageShackkey

let IMAGE_SHACK = "12DJKPSU5fc3afbd01b1630cc718cae3043220f3"
let IMAGE_SHACK_URL = "https://post.imageshack.us/upload_api.php"

// Firebase

let URL_BASE = "https://anshowcase.firebaseio.com/"

public typealias DownloadComplete = () -> ()