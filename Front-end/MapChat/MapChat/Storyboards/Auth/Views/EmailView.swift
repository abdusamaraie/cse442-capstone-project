//
//  EmailView.swift
//  MapChat
//
//  Created by Darren Matthew on 5/2/19.
//  Copyright © 2019 CSE442Group. All rights reserved.
//

import Foundation
import UIKit
import Lottie

class EmailView: UIViewController {
    
    var input_elements:[AuthenticationHelper.input_element] = []
    
    @IBOutlet weak var email: UITextField!
    // @IBOutlet weak var display_name: UITextField!
    
    var sign_in_button: UIButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        input_elements.append(AuthenticationHelper.input_element(element_literal: email, element_name: "email"))
        
        email.addTarget(self, action: #selector(textFieldDidChange(_:)),
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
        sign_in_button = UIButton(frame: CGRect(x: 0, y: (self.view.frame.maxY - self.view.frame.maxY/12), width: (self.view.frame.maxX - self.view.frame.maxX/6), height: 50))
        
        // button text "sign in"
        sign_in_button.setTitle("Continue", for: .normal)
        
        // add button target
        sign_in_button.addTarget(self, action: #selector(next_view), for: .touchUpInside)
        
        // button color white
        sign_in_button.backgroundColor = UIColor.white
        
        // center within view
        sign_in_button.center.x = self.view.frame.midX
        
        // round button
        sign_in_button.layer.cornerRadius = 10
        // button.layer.borderWidth = 1
        // button.layer.borderColor = UIColor.black.cgColor
        
        sign_in_button.setTitleColor(UIColor.gray, for: .normal)
        
        // add button to view
        self.view.addSubview(sign_in_button)
        
        sign_in_button.bindToKeyboard()
        self.email.becomeFirstResponder()
        
    }
    
    @objc func next_view() {
        
        if (AuthenticationHelper.check_input(input_elements: input_elements).count == 0) {
            print("good")
            AuthenticationHelper.sharedInstance.current_user.email = email.text!
            self.performSegue(withIdentifier: "to_name", sender: self)
        } else {
            // there are errors
            // get first element that cause issue
            //print("first element issue: \(AuthenticationHelper.check_input(input_elements: input_elements)[0])")
            print("ELEMENTS: \(AuthenticationHelper.check_input(input_elements: input_elements))")
            
            for element in AuthenticationHelper.check_input(input_elements: input_elements) {
                element.element_literal.backgroundColor = UIColor.red
                element.element_literal.alpha = 0.8
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //self.username.endEditing(true)
        self.email.resignFirstResponder()
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
