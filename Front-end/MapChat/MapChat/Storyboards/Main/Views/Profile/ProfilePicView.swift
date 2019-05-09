//
//  ProfilePicView.swift
//  MapChat
//
//  Created by Darren Matthew on 4/22/19.
//  Copyright © 2019 CSE442Group. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import UIKit

/*
 struct Message {
    var message: String
    var tag: String
    var numberLikes: Int
    var ID: String
 }
 */

struct DarkModeBool {
    static var darkmodeflag = false
}

class ProfilePicView: UIViewController, UIImagePickerControllerDelegate, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate{
    
    @IBOutlet weak var changeImagrButton: UIButton!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var fullName: UILabel!
    @IBOutlet weak var hometown: UILabel!
    @IBOutlet weak var profileCircle: UIView!
    
    @IBOutlet weak var profileTableView: UITableView!
    
    @IBAction func darkmode(_ sender: Any) {
        DarkModeBool.darkmodeflag.toggle()

        if DarkModeBool.darkmodeflag == true
        {
            self.navigationController?.navigationBar.barTintColor = .black
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            self.tabBarController?.tabBar.barTintColor = .black
            self.profileTableView.backgroundColor = .black
            self.view.backgroundColor = .black
            self.profileCircle.backgroundColor = .black
            self.profileName.textColor = .white
            self.hometown.textColor = .white
            self.fullName.textColor = .white
            self.profileTableView.reloadData()
        }
        else if DarkModeBool.darkmodeflag == false
        {
            self.navigationController?.navigationBar.barTintColor = .white
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
            self.tabBarController?.tabBar.barTintColor = .white
            self.profileTableView.backgroundColor = .white
            self.view.backgroundColor = .white
            self.profileCircle.backgroundColor = .white
            self.profileName.textColor = .black
            self.hometown.textColor = .black
            self.fullName.textColor = .black
            self.profileTableView.reloadData()
        }
    }
    
    let urlString = "http://35.238.74.200:80/history/posts"
    
    var imagePicker = UIImagePickerController()

    var messages:[String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileImage.image = #imageLiteral(resourceName: "profile_1")
        
        profileTableView.delegate = self
        profileTableView.dataSource = self
        
        profileImage.layer.masksToBounds = false
        profileImage.layer.borderColor = UIColor.black.cgColor
        profileImage.layer.cornerRadius = profileImage.frame.height/2
        profileImage.clipsToBounds = true
        
        imagePicker.delegate = self// as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
        
//        messages = [Message(message: "this is a test message", tag: "#UB2020", numberLikes: 4, ID: "abc123"),
//                    Message(message: "what's going on dude", tag: "#UB2019", numberLikes: 20, ID: "abc234"),
//                    Message(message: "abc123 is the new me", tag: "#UB2020", numberLikes: 23, ID: "abc345"),
//                    Message(message: "UB is a shitty school for dirt cheap", tag: "#UB2020", numberLikes: 1, ID: "abc456")]
        
        messages = []
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.messages = []
        profileTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return 0
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileMessageCell", for: indexPath) as! MessageCell
        
//        cell.messageBody.text = messages[indexPath.row].message
//        cell.messageTag.text = messages[indexPath.row].tag
//        cell.numberLikes.text = "\(messages[indexPath.row].numberLikes)"
        
        cell.messageBody.text = messages[indexPath.row]
        cell.messageTag.text = "#TestTag"
        cell.numberLikes.text = ""
        
        if DarkModeBool.darkmodeflag == true
        {
            cell.messageTag.textColor = .white
            cell.numberLikes.textColor = .white
            cell.messageBody.textColor = .white
            cell.backgroundColor = .black
        }
        else if DarkModeBool.darkmodeflag == false
        {
            cell.messageTag.textColor = .black
            cell.numberLikes.textColor = .black
            cell.messageBody.textColor = .black
            cell.backgroundColor = .white
        }

        return cell
    }
    
    @IBAction func selectedPosts(_ sender: Any) {
        
        messages = []
        print("selected posts")
        
        let parameters: [String: Any] = ["username": AuthenticationHelper.sharedInstance.current_user.username!]
        
        print("params: \(parameters)")
        
        // /rating takes username postId and rating: bool
        
        Alamofire.request(urlString, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON { response in
            
            switch response.result {
            case .success:
                
                let posts = JSON(response.result.value!)
                
                for (_, post) in posts {
                    print("post: \(post)")
                    self.messages.append(post["content"].string!)
                }
                
                self.profileTableView.reloadData()
            // break
            case .failure(let error):
                print("error: \(error)")
            }
        }
    }
    
    @IBAction func changeImage(_ sender: Any) {
        self.changeImagrButton.setTitleColor(UIColor.white, for: .normal)
        self.changeImagrButton.isUserInteractionEnabled = true
        
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallary()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        /*If you want work actionsheet on ipad
         then you have to use popoverPresentationController to present the actionsheet,
         otherwise app will crash on iPad */
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            alert.popoverPresentationController?.sourceView = sender as? UIView
            alert.popoverPresentationController?.sourceRect = (sender as AnyObject).bounds
            alert.popoverPresentationController?.permittedArrowDirections = .up
        default:
            break
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func openCamera() {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)) {
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
        else {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallary() {
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
        
        print("selected image")
        
        guard let selectedImage = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        
        self.profileImage.image = selectedImage
        
        dismiss(animated: true, completion: nil)
        
        //make post request to upload image to server
    }
    
    //
    
    override func viewDidAppear(_ animated: Bool) {
        print("DISPLAY NAME: \(AuthenticationHelper.sharedInstance.current_user.display_name!)")
        self.profileName.text = "@\(AuthenticationHelper.sharedInstance.current_user.username!)"
        self.hometown.text = AuthenticationHelper.sharedInstance.current_user.homeTown!
        self.fullName.text = AuthenticationHelper.sharedInstance.current_user.first_last_name!
    
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        AuthenticationHelper.sharedInstance.getImageURL(completion: {(imageURL) in
            print("image url: \(imageURL)")
            if imageURL != "" {
                
                let url = URL(string: imageURL)
                
                print("loading image")
                
                // self.profileImage
                
                DispatchQueue.global().async {
                    let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                    DispatchQueue.main.async {
                        self.profileImage.image = UIImage(data: data!)
                    }
                }
            } else {
                // print("error")
            }
        })
    }
}

// ------- UIView Extensions


extension UIView {
    
    @IBInspectable var cornerRadiusV: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidthV: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColorV: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
}
