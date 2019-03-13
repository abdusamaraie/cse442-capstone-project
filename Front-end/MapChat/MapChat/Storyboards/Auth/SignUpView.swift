//
//  SignUpView.swift
//  MapChat
//
//  Created by Duncan Hall on 2/24/19.
//  Copyright © 2019 CSE442Group. All rights reserved.
//

import Foundation
import UIKit

struct input_element {
    var element_literal:UITextField
    var element_name:String
}

class SignUpView: UIViewController {
    
    var input_elements:[input_element] = []
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var display_name: UITextField!
    
    @IBOutlet weak var password_1: UITextField!
    @IBOutlet weak var password_2: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        input_elements.append(input_element(element_literal: username, element_name: "Username"))
        input_elements.append(input_element(element_literal: display_name, element_name: "Display name"))
        input_elements.append(input_element(element_literal: password_1, element_name: "Initial Password"))
        input_elements.append(input_element(element_literal: password_2, element_name: "Second Password Attempt"))
    }
    
    @IBAction func sign_up(_ sender: Any) {
        
        if (check_input().count == 0) {
            print("good")
        } else {
            // there are errors
            // get first element that cause issue
            print("first element issue: \(check_input()[0])")
        }

        
        
    }
    
    func check_input() -> [Any] {
        var invalid_elements:[Any] = []

        for element in input_elements {
            if element.element_literal.text == "" {
                invalid_elements.append(element.element_name)
            }
        }

        return invalid_elements
    }
}


