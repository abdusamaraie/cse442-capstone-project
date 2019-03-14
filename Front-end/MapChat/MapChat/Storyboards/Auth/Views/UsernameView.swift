//
//  SignUpView.swift
//  MapChat
//
//  Created by Duncan Hall on 2/24/19.
//  Copyright © 2019 CSE442Group. All rights reserved.
//

import Foundation
import UIKit

class UsernameView: UIViewController {
    
    var input_elements:[AuthenticationHelper.input_element] = []
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var display_name: UITextField!
    
    var sign_in_button: UIButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sign_in_button = UIButton(frame: CGRect(x: 0, y: (self.view.frame.maxY - self.view.frame.maxY/5), width: (self.view.frame.maxX - self.view.frame.maxX/4), height: 50))
        
        // button text "sign in"
        sign_in_button.setTitle("Sign in", for: .normal)
        
        // add button target
        //sign_in_button.addTarget(self, action: #selector(sign_in), for: .touchUpInside)
        
        // button color white
        sign_in_button.backgroundColor = UIColor.blue
        
        // center within view
        sign_in_button.center.x = self.view.frame.midX
    
        
        // add button to view
        self.view.addSubview(sign_in_button)
        
        
        sign_in_button.bindToKeyboard()
        
        input_elements.append(AuthenticationHelper.input_element(element_literal: username, element_name: "Username"))
        input_elements.append(AuthenticationHelper.input_element(element_literal: display_name, element_name: "Display name"))
    }
    
    
    
    
//    @IBAction func sign_up(_ sender: Any) {
//
//        if (AuthenticationHelper.check_input(input_elements: input_elements).count == 0) {
//            print("good")
//            AuthenticationHelper.sharedInstance.username = username.text!
//            AuthenticationHelper.sharedInstance.display_name = display_name.text!
//            self.performSegue(withIdentifier: "to_next_signup", sender: self)
//        } else {
//            // there are errors
//            // get first element that cause issue
//            print("first element issue: \(AuthenticationHelper.check_input(input_elements: input_elements)[0])")
//        }
//
//
//
//    }

    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}


extension UIView {
    func bindToKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func keyboardWillChange(_ notification: NSNotification) {
        let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        let curve = notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt
        let begginingFrame = (notification.userInfo![UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let endFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let deltaY = endFrame.origin.y - begginingFrame.origin.y
        
        UIView.animateKeyframes(withDuration: duration, delay: 0.0, options: UIView.KeyframeAnimationOptions(rawValue: curve), animations: {
            self.frame.origin.y += deltaY
        }, completion: nil)
    }
}
