//
//  AuthenticationHelper.swift
//  MapChat
//
//  Created by Baily Troyer on 3/12/19.
//  Copyright © 2019 CSE442Group. All rights reserved.
//

import Foundation
import UIKit

class AuthenticationHelper {
    
    struct input_element {
        var element_literal: UITextField
        var element_name: String
    }
    
    struct user {
        var username: String
        var password: String
        var display_name: String
    }
    
    static var sharedInstance = AuthenticationHelper()
    
    var username: String = ""
    var password: String = ""
    var display_name: String = ""
    
    static func check_input(input_elements:[input_element]) -> [Any] {
        var invalid_elements:[Any] = []
        
        for element in input_elements {
            if element.element_literal.text == "" {
                invalid_elements.append(element.element_name)
            }
        }
        
        return invalid_elements
    }
    
    func sign_up(user_:user) {
        
    }
}
