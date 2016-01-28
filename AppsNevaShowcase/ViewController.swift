//
//  ViewController.swift
//  AppsNevaShowcase
//
//  Created by Jim Aven on 11/17/15.
//  Copyright © 2015 Jim Aven. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import SwiftSpinner

class ViewController: UIViewController {

    @IBOutlet weak var emailTextField: MaterialTextField!
    @IBOutlet weak var passwordTextField: MaterialTextField!
    @IBOutlet weak var imgLogo: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imgLogo.layer.cornerRadius = imgLogo.frame.width / 2
        imgLogo.clipsToBounds = true
        
         addSpinner()
        
        
    }

    override func viewDidAppear(animated: Bool) {
        
        if NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) != nil {
            
            SwiftSpinner.hide({ () -> Void in
                self.performSegueWithIdentifier(LOGGED_IN, sender: nil)
                
            })
        }
    }
    
    @IBAction func btnFbLogin(sender: AnyObject) {
        
        let facebookLogin = FBSDKLoginManager()
        facebookLogin.logInWithReadPermissions(["email"], fromViewController: self) {
            result, error in
            
            if error != nil {
                print("Facebook login failed. Error: \(error.localizedDescription)")
            } else if result != nil {
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                DataService.ds.ref_base.authWithOAuthProvider("facebook", token: accessToken, withCompletionBlock: {
                    
                    error, authData in
                    
                    if error != nil {
                        print("Login failed: \(error.localizedDescription)")
                    } else if authData != nil {
                        
                        let user = ["provider" : authData.provider!]
                        DataService.ds.createFiresbaseUser(authData.uid, user: user)
                        
                        NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: KEY_UID)
                        self.performSegueWithIdentifier(LOGGED_IN, sender: nil)
                        
                    } else {
                        print("Something above my pay grade went wrong")
                    }
                    
                })
            }
        }
    }
    @IBAction func btnLoginAttemptPressed(sender: AnyObject) {
        
        addSpinner()
        
        if let email = emailTextField.text where email != "", let pwd = passwordTextField.text where pwd != "" {
           
            DataService.ds.ref_base.authUser(email, password: pwd, withCompletionBlock: {
                
                error, authData in
                
                if error != nil {
                    print("Login error: \(error.localizedDescription)")
                    
                    if error.code == STATUS_DOES_NOT_EXIST {
                        
                        DataService.ds.ref_base.createUser(email, password: pwd, withValueCompletionBlock: {
                            
                            error, aResult in
                            
                            if error != nil {
                                SwiftSpinner.hide({ () -> Void in
                                    self.showErrorAlert("Oops", message: error.localizedDescription)
                                })
                                
                            } else {
                                let uid = aResult["uid"] as? String
                                DataService.ds.ref_base.authUser(email, password: pwd, withCompletionBlock: {
                                    error, result in
                                    if error != nil {
                                        SwiftSpinner.hide({ () -> Void in
                                            self.showErrorAlert("Oops", message: error.localizedDescription)
                                        })
                                    } else {
                                        NSUserDefaults.standardUserDefaults().setValue(result.uid, forKey: KEY_UID)
                                        let user = ["provider": result.provider!]
                                        DataService.ds.createFiresbaseUser(uid!, user: user)
                                        SwiftSpinner.hide({ () -> Void in
                                            self.clearTextFields()
                                            self.performSegueWithIdentifier("postLoginSegue", sender: nil)
                                        })
                                    }
                                })
                            }
                        })

                        
                    } else {
                        SwiftSpinner.hide({ () -> Void in
                            self.showErrorAlert("Oops", message: error.localizedDescription)
                        })
                        
                    }
                    
                } else {
                    SwiftSpinner.hide({ () -> Void in
                       NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: KEY_UID)
                        print("UID: \(authData.uid)")
                        self.clearTextFields()
                        self.performSegueWithIdentifier("postLoginSegue", sender: nil)
                    })
                }
            })
        } else {
            SwiftSpinner.hide()
            self.showErrorAlert("Oops", message: "Please fill out both fields")
        }
    }
    
    func showErrorAlert(title:String, message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(cancelAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func loadWelcomeView() {
        
        let welcomeVC = WelcomeVC(nibName: "WelView", bundle: nil)
        welcomeVC.modalTransitionStyle = UIModalTransitionStyle.PartialCurl
        self.presentViewController(welcomeVC, animated: true, completion: nil)

    }
    
    func addSpinner() {
        SwiftSpinner.setTitleFont(UIFont(name: "Noto", size: 22.0))
        SwiftSpinner.show("Connecting to the cloud", animated: true).addTapHandler({ () -> () in
            SwiftSpinner.hide()
            }, subtitle: "Tap to hide while connecting")
    }
    
    func clearTextFields() {
        emailTextField.text = ""
        passwordTextField.text = ""
    }

    
}

