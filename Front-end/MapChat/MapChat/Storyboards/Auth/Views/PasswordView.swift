//
//  NameView.swift
//  MapChat
//
//  Created by Baily Troyer on 3/14/19.
//  Copyright © 2019 CSE442Group. All rights reserved.
//

import Foundation
import UIKit
import Lottie

class PasswordView: UIViewController {
    
    var input_elements:[AuthenticationHelper.input_element] = []
    
    @IBOutlet weak var password: UITextField!
    
    var next_button: UIButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        input_elements.append(AuthenticationHelper.input_element(element_literal: password, element_name: "Password"))
        password.addTarget(self, action: #selector(textFieldDidChange(_:)),
                                  for: UIControl.Event.editingChanged)
        
        if let animationView:AnimationView = AnimationView(name: "cachr_white_full") {
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
    
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        textField.backgroundColor = nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        next_button = UIButton(frame: CGRect(x: 0, y: (self.view.frame.maxY - self.view.frame.maxY/12), width: (self.view.frame.maxX - self.view.frame.maxX/6), height: 50))
        
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
        
        next_button.bindToKeyboard()
        
        self.password.becomeFirstResponder()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.password.resignFirstResponder()
    }
    
    @objc func next_view() {
        if (AuthenticationHelper.check_input(input_elements: input_elements).count == 0) {
            print("good")
            AuthenticationHelper.sharedInstance.current_user.password = password.text!
            
            
            //    loadData (completion: { (number, strArr1, strArr2, strArr3) in
            //        // do it
            //        // for exapmple
            //        self.number = number
            //        self.strArr1 = strArr1
            //        // and so on
            //
            //    })
            
            AuthenticationHelper.sharedInstance.sign_up(completion: {(response) in
                // print("result: \(response)")
                if (response == "Error") {
                    print("User already signed in")
                } else {
                    
                    // send photo
                    print("calling send photo")
                    // AuthenticationHelper.sharedInstance.sendPhoto()
                    self.performSegue(withIdentifier: "to_main", sender: self)
                }
            })
        } else {
            // there are errors
            // get first element that cause issue
            
            print("ELEMENTS: \(AuthenticationHelper.check_input(input_elements: input_elements))")
            
            for element in AuthenticationHelper.check_input(input_elements: input_elements) {
                element.element_literal.backgroundColor = UIColor.red
                element.element_literal.alpha = 0.8
            }
        }
    }
    
    @IBAction func go_back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
