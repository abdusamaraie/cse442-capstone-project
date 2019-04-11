//
//  ProfileView.swift
//  MapChat
//
//  Created by Baily Troyer on 2/27/19.
//  Copyright © 2019 CSE442Group. All rights reserved.
//

import Foundation
import UIKit

struct Setting {
    var name: String
}

class ProfileView: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var changeImagrButton: UIButton!
    
    @IBOutlet weak var settingsView: UITableView!
    
    var imagePicker = UIImagePickerController()
    
    let settings_list: [Setting] = [Setting(name: "Dark Mode"),
                                    Setting(name: "Private Posts"),
                                    Setting(name: "Notify Friends")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        settingsView.dataSource = self
        settingsView.delegate = self
        
        imagePicker.delegate = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
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
    
    //
    
    override func viewDidAppear(_ animated: Bool) {
        // print("DISPLAY NAME: \(AuthenticationHelper.sharedInstance.current_user.display_name)")
        self.profileName.text = "Baily Troyer"
        self.settingsView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("count: \(settings_list.count)")
        return settings_list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as! SettingsCell
        
        cell.settingsName.text = settings_list[indexPath.row].name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(100)
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
