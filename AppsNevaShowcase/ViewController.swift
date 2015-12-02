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
        
        if let email = emailTextField.text where email != "", let pwd = passwordTextField.text where pwd != "" {
           
            addSpinner()
            
            DataService.ds.ref_base.authUser(email, password: pwd, withCompletionBlock: {
                
                error, authData in
                
                if error != nil {
                    
                    print(error.code, error.localizedDescription)
                    
                    if error.code == STATUS_DOES_NOT_EXIST {
                        
                        DataService.ds.ref_base.createUser(email, password: pwd, withValueCompletionBlock: {
                            error, result in
                            
                            if error != nil {
                                self.showErrorAlert("Could not create account", message: "Problem creating account")
                            } else {
                                NSUserDefaults.standardUserDefaults().setValue(result["uid"], forKey: KEY_UID)
                                print(result["uid"])
                                DataService.ds.ref_base.authUser(email, password: pwd, withCompletionBlock: {
                                    
                                    error, authData in
                                    let user = ["provider" : authData.provider!]
                                    DataService.ds.createFiresbaseUser(authData.uid, user: user)
                                
                                })
                                SwiftSpinner.hide({ () -> Void in
                                    self.performSegueWithIdentifier(LOGGED_IN, sender: nil)
                                    print("NEW account created")
                                })
                                
                            }
                        })
                    } else {
                        self.showErrorAlert("Oops", message: error.localizedDescription)
                    }
                } else {
                    NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: KEY_UID)
                    SwiftSpinner.hide({ () -> Void in
                        self.performSegueWithIdentifier(LOGGED_IN, sender: nil)
                    })
                    
                }
            })
            
        } else {
            showErrorAlert("Email and Password Required", message: "Please complete fields")
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

    
}

