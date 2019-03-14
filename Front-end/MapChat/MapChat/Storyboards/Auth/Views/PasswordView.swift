//
//  NameView.swift
//  MapChat
//
//  Created by Baily Troyer on 3/14/19.
//  Copyright © 2019 CSE442Group. All rights reserved.
//

import Foundation
import UIKit

class PasswordView: UIViewController {
    
    var input_elements:[AuthenticationHelper.input_element] = []
    
    @IBOutlet weak var password: UITextField!
    
    var next_button: UIButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        input_elements.append(AuthenticationHelper.input_element(element_literal: password, element_name: "Password"))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        next_button = UIButton(frame: CGRect(x: 0, y: (self.view.frame.maxY - self.view.frame.maxY/12), width: (self.view.frame.maxX - self.view.frame.maxX/6), height: 50))
        
        // button text "sign in"
        next_button.setTitle("Continue", for: .normal)
        
        // add button target
        next_button.addTarget(self, action: #selector(next_view), for: .touchUpInside)
        
        // button color white
        next_button.backgroundColor = UIColor.blue
        
        // center within view
        next_button.center.x = self.view.frame.midX
        
        // round button
        next_button.layer.cornerRadius = 10
        // button.layer.borderWidth = 1
        // button.layer.borderColor = UIColor.black.cgColor
        
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
            AuthenticationHelper.sharedInstance.password = password.text!
            self.performSegue(withIdentifier: "to_main", sender: self)
        } else {
            // there are errors
            // get first element that cause issue
            print("first element issue: \(AuthenticationHelper.check_input(input_elements: input_elements)[0])")
        }
    }
    
    @IBAction func go_back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
