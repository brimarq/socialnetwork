//
//  FeedVC.swift
//  socialnetwork
//
//  Created by Brian Marquis on 7/31/17.
//  Copyright © 2017 brimarq. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageAdd: CircleView!
    @IBOutlet weak var captionField: FancyField!
    
    var posts = [Post]()
    var imagePicker: UIImagePickerController!
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    var imageSelected = false

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        // Init the image picker
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        // Init Firebase DB listener for changes to posts
        DataService.ds.REF_POSTS.observe(.value, with: { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    print("SNAP: \(snap)")
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let post = Post(postKey: key, postData: postDict)
                        self.posts.append(post)
                    }
                }
            }
            self.tableView.reloadData()
        })
        
    }
    
    // TableView functions
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as? PostCell {
            
            if let img = FeedVC.imageCache.object(forKey: post.imageUrl as NSString) {
                cell.configureCell(post: post, img: img)
                return cell
            } else {
                cell.configureCell(post: post)
                return cell
            }
        } else {
            return PostCell()
        }
    }
    
    // Image picker functions
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            imageAdd.image = image
            imageSelected = true
        } else {
            print("EKXXI: A valid image wasn't selected")
        }
        imagePicker.dismiss(animated: true, completion: nil) // Once an image is selected, get rid of the image picker
    }
    
    
    // IBActions
    @IBAction func addImageTapped(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func postBtnTapped(_ sender: Any) {
        // Checks that there is a caption for the post
        guard let caption = captionField.text, caption != "" else {
            print("EKXXI: Caption must be entered.")
            return
        }
        guard let img = imageAdd.image, imageSelected == true else {
            print("EKXXI: An image must be selected.")
            return
        }
        
        if let imgData = UIImageJPEGRepresentation(img, 0.2) {
            // Assign a uid to the image
            let imgUid = NSUUID().uuidString
            // for telling Firebase what kind of data this is.
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            // Send data to Firebase
            DataService.ds.REF_POST_IMAGES.child(imgUid).putData(imgData, metadata: metadata) { (metadata, error) in
                if error != nil {
                    print("EKXXI: Unable to upload image to Firebase storage.")
                } else {
                    print("EKXXI: Successfully uploaded image to Firebase storage.")
                    let downloadURL = metadata?.downloadURL()?.absoluteString
                    if let url = downloadURL {
                        self.postToFirebase(imgUrl: url)
                    }
                }
            }
        }
    }
    
    // Form the data to be sent to Firebase, cleanup after
    func postToFirebase(imgUrl: String) {
        let post: Dictionary<String, AnyObject> = [
            "caption": captionField.text as AnyObject,
            "imageUrl": imgUrl as AnyObject,
            "likes": 0 as AnyObject
        ]
        
        // Assign a uuid to the post
        let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
        firebasePost.setValue(post)
        
        // On posting, reset the caption field and image select button
        captionField.text = ""
        imageSelected = false
        imageAdd.image = UIImage(named: "add-image")
        
        // Reload the tableView to display the new post
        tableView.reloadData()
    }
    
    @IBAction func signOutTapped(_ sender: Any) {
        let keychainResult = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        print("EKXXI: ID removed from keychain \(keychainResult)")
        try! Auth.auth().signOut()
        performSegue(withIdentifier: "goToSignIn", sender: nil)
    }
    
}
