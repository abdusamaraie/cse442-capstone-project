//
//  AuthenticationHelper.swift
//  MapChat
//
//  Created by Baily Troyer on 3/12/19.
//  Copyright © 2019 CSE442Group. All rights reserved.
//

import Foundation
import Alamofire
import UIKit

class AuthenticationHelper {
    
    struct input_element {
        var element_literal: UITextField
        var element_name: String
    }
    
    struct user {
        var username: String?
        var password: String?
        var display_name: String?
        
        init(username: String? = nil, //👈
            password: String? = nil,
            display_name: String? = nil) {
            
            self.username = username
            self.password = password
            self.display_name = display_name
        }
    }
    
    static var sharedInstance = AuthenticationHelper()
    
    var username: String = ""
    var password: String = ""
    var display_name: String = ""
    var url_string:String = "192.168.0.0"
    
    var current_user:user = user()
    
    static func check_input(input_elements:[input_element]) -> [Any] {
        var invalid_elements:[Any] = []
        
        for element in input_elements {
            if element.element_literal.text == "" {
                invalid_elements.append(element.element_name)
            }
        }
        
        return invalid_elements
    }
    
    func sign_up(completion: @escaping (_ response_:String) -> ()){
        
        let parameters: Parameters = ["username": AuthenticationHelper.sharedInstance.current_user.username, "password": AuthenticationHelper.sharedInstance.current_user.password, "display_name": AuthenticationHelper.sharedInstance.current_user.display_name]
        
        Alamofire.request(url_string, method: .post, parameters: parameters).validate().responseJSON { response in
            
            switch(response.result) {
                case .success(_):
                    completion("Success")
                    break

                case .failure(_):
                    print("Error")
                    completion("Error")
                    break
            }
            
        }
        
    }
    
//    example calling function:
//    loadData (completion: { (number, strArr1, strArr2, strArr3) in
//        // do it
//        // for exapmple
//        self.number = number
//        self.strArr1 = strArr1
//        // and so on
//
//    })
}
