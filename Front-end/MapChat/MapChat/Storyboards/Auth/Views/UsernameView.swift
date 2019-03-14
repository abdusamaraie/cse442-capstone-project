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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        input_elements.append(AuthenticationHelper.input_element(element_literal: username, element_name: "Username"))
        input_elements.append(AuthenticationHelper.input_element(element_literal: display_name, element_name: "Display name"))
    }
    
    @IBAction func sign_up(_ sender: Any) {
        
        if (AuthenticationHelper.check_input(input_elements: input_elements).count == 0) {
            print("good")
            AuthenticationHelper.sharedInstance.username = username.text!
            AuthenticationHelper.sharedInstance.display_name = display_name.text!
            self.performSegue(withIdentifier: "to_next_signup", sender: self)
        } else {
            // there are errors
            // get first element that cause issue
            print("first element issue: \(AuthenticationHelper.check_input(input_elements: input_elements)[0])")
        }

        
        
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}


