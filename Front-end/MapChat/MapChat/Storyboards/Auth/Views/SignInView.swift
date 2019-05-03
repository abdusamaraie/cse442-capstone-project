//
//  SignInView.swift
//  MapChat
//
//  Created by Duncan Hall on 2/24/19.
//  Copyright © 2019 CSE442Group. All rights reserved.
//

import Foundation
import UIKit
import FacebookLogin
import FBSDKCoreKit
import FBSDKLoginKit
import PopupDialog
import Lottie

class SignInView: UIViewController, UITextFieldDelegate {
    
    var sign_in_button: UIButton = UIButton()
    var input_elements:[AuthenticationHelper.input_element] = []
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var sunny: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        input_elements.append(AuthenticationHelper.input_element(element_literal: username, element_name: "Username or Email"))
        input_elements.append(AuthenticationHelper.input_element(element_literal: password, element_name: "Password"))
        
        username.addTarget(self, action: #selector(textFieldDidChange(_:)),
                           for: UIControl.Event.editingChanged)
        password.addTarget(self, action: #selector(textFieldDidChange(_:)),
                           for: UIControl.Event.editingChanged)
        
        username.delegate = self
        password.delegate = self
        
        self.sunny.tintColor = #colorLiteral(red: 0, green: 0.7694169879, blue: 0.9316933751, alpha: 1)
        
        
        if let animationView:AnimationView = AnimationView(name: "cachr_blue_full") {
            animationView.frame = CGRect(x: 0, y: 0, width: 480, height: 48)
            
            // label.center.y = view.center.y
            animationView.center.x = self.view.center.x
            animationView.center.y = self.view.frame.height/8
            animationView.contentMode = .scaleAspectFill
            animationView.loopMode = LottieLoopMode.loop
            
            self.view.addSubview(animationView)
            
            animationView.play()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == username {
            password.becomeFirstResponder()
        } else {
            validate()
        }
//        else {
//            passwordTextField.resignFirstResponder()
//        }
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        sign_in_button = UIButton(frame: CGRect(x: 0, y: (self.view.frame.maxY - self.view.frame.maxY/12), width: (self.view.frame.maxX - self.view.frame.maxX/6), height: 50))
        
        // button text "sign in"
        sign_in_button.setTitle("Continue", for: .normal)
        
        sign_in_button.setTitleColor(.white, for: .normal)
        
        // add button target
        sign_in_button.addTarget(self, action: #selector(next_view), for: .touchUpInside)
        
        // button color white
        sign_in_button.backgroundColor = #colorLiteral(red: 0, green: 0.7694169879, blue: 0.9316933751, alpha: 1)
        
        // center within view
        sign_in_button.center.x = self.view.frame.midX
        
        // round button
        sign_in_button.layer.cornerRadius = 10
        // button.layer.borderWidth = 1
        // button.layer.borderColor = UIColor.black.cgColor
        
        // add button to view
        self.view.addSubview(sign_in_button)
        
        sign_in_button.bindToKeyboard()
        self.username.becomeFirstResponder()
        

    }
    
    func validate() {
        if (AuthenticationHelper.check_input(input_elements: input_elements).count == 0) {
            
            AuthenticationHelper.sharedInstance.current_user.username = self.username.text!
            AuthenticationHelper.sharedInstance.current_user.password = self.password.text!
            
            AuthenticationHelper.sharedInstance.sign_in(completion: {(response) in
                
                print("response: \(response)")
                if (response == "Success") {
                    self.performSegue(withIdentifier: "toMain", sender: self)
                } else {
                    // Present dialog
                    
                    let title = "Oh no, something has gone wrong!"
                    let message = "We can't seem to connect to our backend, please try again."
                    
                    let popup = PopupDialog(title: title, message: message)
                    
                    // Create buttons
                    let buttonOne = CancelButton(title: "Okay") {
                        print("User understands issue with connection")
                    }
                    
                    // Add buttons to dialog
                    // Alternatively, you can use popup.addButton(buttonOne)
                    // to add a single button
                    popup.addButtons([buttonOne])
                    
                    
                    self.present(popup, animated: true, completion: nil)
                    print("invalid credentials")
                }
            })
        } else {
            // there are errors
            // get first element that cause issue
            
            print("ELEMENTS: \(AuthenticationHelper.check_input(input_elements: input_elements))")
            
            for element in AuthenticationHelper.check_input(input_elements: input_elements) {
                element.element_literal.backgroundColor = UIColor.red
                element.element_literal.alpha = 0.6
            }
            // print("first element issue: \(AuthenticationHelper.check_input(input_elements: input_elements)[0])")
            
            // self.performSegue(withIdentifier: "errorView", sender: self)
        }
    }
    
    @objc func next_view() {
        // self.performSegue(withIdentifier: "toMain", sender: self)
        validate()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        textField.backgroundColor = nil
    }
    
    @IBAction func editUsername(_ sender: Any) {
        self.username.backgroundColor = nil
    }
    
    @IBAction func facebookAuth(_ sender: Any) {
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["email"], from: self) { (result, error) -> Void in
            if (error == nil){
                let fbloginresult : FBSDKLoginManagerLoginResult = result!
                // if user cancel the login
                if (result?.isCancelled)!{
                    return
                }
                if(fbloginresult.grantedPermissions.contains("email"))
                {
                    self.getFBUserData()
                }
            }
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        self.username.resignFirstResponder()
    }
    
    func getFBUserData(){
        if((FBSDKAccessToken.current()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    //everything works print the user data
                    print(result)
                }
            })
        }
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}


extension UIImage {
    
    func alpha(_ value:CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: CGPoint.zero, blendMode: .normal, alpha: value)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}
