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

/*
 
 Alamofire.request("http://34.73.109.229:80/", method: .get, parameters: nil, headers: nil).validate().responseString { response in
 
 print("response result val: \(response.result.value!)")
 print("response result: \(response.result)")
 print("status code: \(response.response?.statusCode)")
 
 switch(response.result) {
 case .success(_):
 print("Success")
 break
 
 case .failure(_):
 print("Error")
 break
 }
 
 }
 
 */

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
    
    var url_string:String = "http://34.73.109.229:80"
    
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
    
    func sign_in(completion: @escaping (_ response_:String) -> ()) {
        
        // 34.73.109.229:80/auth?username=bailytro&password=password
        
        let emailArray = AuthenticationHelper.sharedInstance.current_user.username!.components(separatedBy: "@")
        let username = emailArray[0]
        
        let sign_in_string = "\(url_string)/auth?username=\(username)&password=\(AuthenticationHelper.sharedInstance.current_user.password!)"
        
        print("URL STRING: \(sign_in_string)")
        
        Alamofire.request(sign_in_string, method: .get, parameters: nil, headers: nil).validate().responseString { response in
            
            print("response: \(response.result.value!)")
            print("status code: \(response.response!.statusCode)")
            
            switch(response.result) {
            case .success(_):
                if (response.result.value! == "True") {
                    print("Success")
                    completion("Success")
                    break
                } else {
                    print("Failure")
                    completion("Failure")
                    break
                }
            case .failure(_):
                print("Error")
                completion("Error")
                break
            }

        }
    }
    
    func sign_up(completion: @escaping (_ response_:String) -> ()) {
        
        let displayNameArray = AuthenticationHelper.sharedInstance.current_user.display_name!.components(separatedBy: " ")
        let firstname = displayNameArray[0]
        let lastname = displayNameArray[1]
        
        let emailArray = AuthenticationHelper.sharedInstance.current_user.username!.components(separatedBy: "@")
        let username = emailArray[0]
        
        
        
        let parameters: [String: Any] = [
            "email": AuthenticationHelper.sharedInstance.current_user.username!,
            "username": username,
            "password": AuthenticationHelper.sharedInstance.current_user.password!,
            "firstname": firstname,
            "lastname": lastname
        ]
        
        print("sending request: \(parameters)")
        
        Alamofire.request("\(url_string)/auth", method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseString { response in
            
            print("response: \(response.result.value!)")
            print("status code: \(response.response!.statusCode)")
            
            switch(response.result) {
                case .success(_):
                    print("Success")
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
