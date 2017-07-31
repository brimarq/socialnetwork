//
//  SignInVC.swift
//  socialnetwork
//
//  Created by Brian Marquis on 7/30/17.
//  Copyright © 2017 brimarq. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase

class SignInVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func facebookBtnTapped(_ sender: Any) {
        
        // Facebook authentication
        let facebookLogin = FBSDKLoginManager()
        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if error != nil {
                //print("EKXXI: Unable to authenticate with Facebook - \(error)")
                print("EKXXI: Unable to authenticate with Facebook - \(String(describing: error))")
            } else if result?.isCancelled == true {
                print("EKXXI: User cancelled Facebook authentication")
            } else {
                print("EKXXI: Successfully authenticated with Facebook")
                let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                self.firebaseAuth(credential)
            }
        }
    }
    
    // Firebase authentication
    func firebaseAuth(_ credential: AuthCredential) {
        Auth.auth().signIn(with: credential, completion: { (user, error) in
            if error != nil {
                //print("EKXXI: Unable to authenticate with Firebase - \(error)")
                print("EKXXI: Unable to authenticate with Firebase - \(String(describing: error))")
            } else {
                print("EKXXI: Successfully authenticated with Firebase")
            }
        
        })
    }

}

