//
//  FeedVC.swift
//  AppsNevaShowcase
//
//  Created by Jim Aven on 11/18/15.
//  Copyright © 2015 Jim Aven. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
import SwiftSpinner

class FeedVC: UIViewController, UITableViewDataSource, UITableViewDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var posts = [Post]()
    var fireBase:Firebase!
    
    
    let okAction = UIAlertAction(title:"OK", style:.Cancel, handler:nil)
    
    static var imgCache = NSCache()
    
    var imgPicker:UIImagePickerController!
    var imageSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 358
        
        imgPicker = UIImagePickerController()
        imgPicker.delegate = self
        
        DataService.ds.ref_posts.observeEventType(.Value, withBlock: {
            snapshot in
            
            self.posts = []
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                
                for snap in snapshots {
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let post = Post(postKey: key, dictionary: postDict)
                        self.posts.append(post)
                    }
                }
                self.tableView.reloadData()
            }
        })
        
      
    }
    @IBAction func btnLogoutPressed(sender: UIBarButtonItem) {
        DataService.ds.ref_base.unauth()
        NSUserDefaults.standardUserDefaults().setValue(nil, forKey: KEY_UID)
        self.dismissViewControllerAnimated(true, completion: nil)

    }

    //MARK: Table data dn delegate
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("postCell") as? PostCell {
            
            
            cell.request?.cancel()
            
            var img:UIImage?
            
            if let url = post.imageUrl {
                img = FeedVC.imgCache.objectForKey(url) as? UIImage
            }
            
            cell.configureCell(post, img: img)
            
            return cell
        } else {
            return PostCell()
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let post = posts[indexPath.row]
        if post.imageUrl == nil {
            return 150
        } else {
            return tableView.estimatedRowHeight
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let postKey = posts[indexPath.row].postKey
        
        let alert = UIAlertController(title: "Delete?", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        let yesAction = UIAlertAction(title: "Yes", style: .Default){ (UIAlertAction) -> Void in
            
        SwiftSpinner.show("Deleting post now", animated: true)
            
            if let success = DataService.ds.removePost(postKey, completed: { () -> () in
                SwiftSpinner.hide()
            }) {
                if success == 1 {
                    self.showErrorAlert("Oops", message: "you can only delete your own posts")
                }
            }
        }
        
        alert.addAction(yesAction)
        
        let noAction = UIAlertAction(title: "No", style: .Cancel) { (UIAlertAction) -> Void in
            
        }
        alert.addAction(noAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    
    //MARK: Post section
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        imgPicker.dismissViewControllerAnimated(true, completion: nil)
        imgSelector.image = image
        imageSelected = true
    }
    
    @IBOutlet weak var postTextField: MaterialTextField!
    
    @IBOutlet weak var imgSelector: UIImageView!
    
    @IBAction func btnCameraPressed(sender: UITapGestureRecognizer) {
        
        self.presentViewController(imgPicker, animated: true, completion: nil)
        
    }
    
    @IBAction func btnPostPressed(sender: AnyObject) {
        
        if let text = postTextField.text where text != "" {
            
            SwiftSpinner.show("Creating post in the cloud", animated: true)
            SwiftSpinner.setTitleFont(UIFont(name: "Noto", size: 22.0))
            
            if let img = imgSelector.image where imageSelected == true {
                let urlStr = IMAGE_SHACK_URL
                let url = NSURL(string: urlStr)!
                let imgData = UIImageJPEGRepresentation(img, 0.2)!
                let keyData = IMAGE_SHACK.dataUsingEncoding(NSUTF8StringEncoding)!
                let keyJSON = "json".dataUsingEncoding(NSUTF8StringEncoding)!
                
                Alamofire.upload(.POST, url, multipartFormData: { (MultipartFormData) -> Void in
                    
                    MultipartFormData.appendBodyPart(data:imgData, name:"fileupload", fileName:"image", mimeType:"image/jpg")
                    MultipartFormData.appendBodyPart(data:keyData, name:"key")
                    MultipartFormData.appendBodyPart(data:keyJSON, name:"format")

                    }, encodingCompletion: { encodingResult in
                        
                        switch encodingResult {
                        case .Success(let upload, _, _):
                            upload.responseJSON(completionHandler: {
                                response in
                                if let info = response.result.value as? Dictionary<String,AnyObject> {
                                    if let links = info["links"] as? Dictionary<String, AnyObject> {
                                        if let imgLink = links["image_link"] as? String {
                                            self.postToFirebase(imgLink)
                                        }
                                    }
                                }
                            })
                        case .Failure(let error):
                            print(error)
                        }
                })
            } else {
                postToFirebase(nil)
            }
        }
    }
    
    func postToFirebase(imgUrl:String?) {
        
        var post: Dictionary<String, AnyObject> = ["description": postTextField.text!, "likes" : 0]
        if imgUrl != nil {
            post["imageURL"] = imgUrl
        }
        post["userID"] = NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID)
        let firebasePost = DataService.ds.ref_posts.childByAutoId()
        firebasePost.setValue(post)
        postTextField.text = ""
        imgSelector.image = UIImage(named: "cameraRoundedGrey")
        SwiftSpinner.hide { () -> Void in
            self.tableView.reloadData()
        }
    }
    
    
    func showErrorAlert(title:String, message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(cancelAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
