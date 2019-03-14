//
//  Password.swift
//  MapChat
//
//  Created by Baily Troyer on 3/12/19.
//  Copyright © 2019 CSE442Group. All rights reserved.
//

import Foundation
import UIKit

class PasswordView: UIViewController {
    
    var input_elements:[AuthenticationHelper.input_element] = []
    
    @IBOutlet weak var password_initial: UITextField!
    @IBOutlet weak var password_verify: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        input_elements.append(AuthenticationHelper.input_element(element_literal: password_initial, element_name: "Initial Password"))
        input_elements.append(AuthenticationHelper.input_element(element_literal: password_verify, element_name: "Verify Password"))

    }
    
    @IBAction func sign_up(_ sender: Any) {
        if (AuthenticationHelper.check_input(input_elements: input_elements).count == 0) {
            print("good")
//            let user = AuthenticationHelper.user(username: AuthenticationHelper.sharedInstance.username, password: AuthenticationHelper.sharedInstance.password, display_name: AuthenticationHelper.sharedInstance.display_name)
//            AuthenticationHelper.sharedInstance.current_user = user
//
//            AuthenticationHelper.sharedInstance.sign_up (completion: { (response) in
//
//                print(response)
//            })
            
            self.performSegue(withIdentifier: "to_main", sender: self)
            
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
