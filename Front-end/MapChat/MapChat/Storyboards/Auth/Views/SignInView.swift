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

class SignInView: UIViewController {
    
    var sign_in_button: UIButton = UIButton()
    var input_elements:[AuthenticationHelper.input_element] = []
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        input_elements.append(AuthenticationHelper.input_element(element_literal: username, element_name: "Username or Email"))
        input_elements.append(AuthenticationHelper.input_element(element_literal: password, element_name: "Password"))
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        sign_in_button = UIButton(frame: CGRect(x: 0, y: (self.view.frame.maxY - self.view.frame.maxY/12), width: (self.view.frame.maxX - self.view.frame.maxX/6), height: 50))
        
        // button text "sign in"
        sign_in_button.setTitle("Continue", for: .normal)
        
        // add button target
        sign_in_button.addTarget(self, action: #selector(next_view), for: .touchUpInside)
        
        // button color white
        sign_in_button.backgroundColor = UIColor.blue
        
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
    
    @objc func next_view() {
        if (AuthenticationHelper.check_input(input_elements: input_elements).count == 0) {
            
            AuthenticationHelper.sharedInstance.current_user.username = self.username.text!
            AuthenticationHelper.sharedInstance.current_user.password = self.password.text!
            
            AuthenticationHelper.sharedInstance.sign_in(completion: {(response) in
                
                print("response: \(response)")
                if (response == "Success") {
                    self.performSegue(withIdentifier: "toMain", sender: self)
                } else {
                    print("invalid credentials")
                }
            })
        } else {
            // there are errors
            // get first element that cause issue
            
            print("first element issue: \(AuthenticationHelper.check_input(input_elements: input_elements)[0])")
            
            self.performSegue(withIdentifier: "errorView", sender: self)
        }
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
