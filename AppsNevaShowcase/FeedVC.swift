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

class FeedVC: UIViewController, UITableViewDataSource, UITableViewDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var posts = [Post]()
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
            
            if let img = imgSelector.image where imageSelected == true {
                let urlStr = "https://post.imageshack.us/upload_api.php"
                let url = NSURL(string: urlStr)!
                let imgData = UIImageJPEGRepresentation(img, 0.2)!
                let keyData = "1YZL0VAJ2e4d929d40f3b0fcad513e71db5c8a56".dataUsingEncoding(NSUTF8StringEncoding)!
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
        let firebasePost = DataService.ds.ref_posts.childByAutoId()
        firebasePost.setValue(post)
        postTextField.text = ""
        imgSelector.image = UIImage(named: "cameraRoundedGrey")
        tableView.reloadData()
        
    }
}
