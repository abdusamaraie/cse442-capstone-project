//
//  PictureView.swift
//  MapChat
//
//  Created by Baily Troyer on 4/27/19.
//  Copyright © 2019 CSE442Group. All rights reserved.
//

import Foundation
import UIKit

class PictureView: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    let pickerController = UIImagePickerController()
    var next_button: UIButton = UIButton()
    
    var selectedImage1: UIImage!
    
    @IBOutlet weak var imageButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // imagePicker.delegate = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate

        pickerController.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        next_button = UIButton(frame: CGRect(x: 0, y: (self.view.frame.maxY - self.view.frame.maxY/11  - 20), width: (self.view.frame.maxX - self.view.frame.maxX/6), height: 50))
        
        // button text "sign in"
        next_button.setTitle("Continue", for: .normal)
        
        // add button target
        next_button.addTarget(self, action: #selector(next_view), for: .touchUpInside)
        
        // button color white
        next_button.backgroundColor = UIColor.white
        
        // center within view
        next_button.center.x = self.view.frame.midX
        
        // round button
        next_button.layer.cornerRadius = 10
        // button.layer.borderWidth = 1
        // button.layer.borderColor = UIColor.black.cgColor
        
        next_button.setTitleColor(UIColor.gray, for: .normal)
        
        // add button to view
        self.view.addSubview(next_button)
        
    }
    
    @objc func next_view() {
        if (selectedImage1 != nil) {
            AuthenticationHelper.sharedInstance.profileImage = selectedImage1
        }
        
        self.performSegue(withIdentifier: "to_birthday", sender: self)
    }
    
    @IBAction func selectImage(_ sender: Any) {
        
        pickerController.allowsEditing = false
        pickerController.sourceType = .photoLibrary
        
        present(pickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
        
        print("selected image")
        
        guard let selectedImage = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        self.selectedImage1 = selectedImage
        
        imageButton.cornerRadius = 50
        imageButton.clipsToBounds = true
        
        imageButton.setBackgroundImage(selectedImage, for: .normal)
        
        dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
