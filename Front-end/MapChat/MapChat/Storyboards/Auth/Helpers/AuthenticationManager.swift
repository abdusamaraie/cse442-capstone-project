//
//  AuthenticationHelper.swift
//  MapChat
//
//  Created by Baily Troyer on 3/12/19.
//  Copyright © 2019 CSE442Group. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
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
        var birthday: String?
        var homeTown: String?
        var email: String?
        var first_last_name: String?
        
        init(username: String? = nil, //👈
            password: String? = nil,
            display_name: String? = nil,
            birthday: String? = nil,
            homeTown: String? = nil,
            email: String? = nil,
            first_last_name: String? = nil) {
            
            self.username = username
            self.password = password
            self.display_name = display_name
            self.birthday = birthday
            self.homeTown = homeTown
            self.email = email
            self.first_last_name = first_last_name
        }
    }
    
    static var sharedInstance = AuthenticationHelper()
    
    var profileImage:UIImage!
    
    var url_string:String = "http://35.238.74.200:80"
    
    var current_user:user = user()
    
    static func check_input(input_elements:[input_element]) -> [input_element] {
        var invalid_elements:[input_element] = []
        
        for element in input_elements {
            if element.element_literal.text == "" {
                invalid_elements.append(element)
            }
        }
        
        return invalid_elements
    }
    
    func sign_in(completion: @escaping (_ response_:String) -> ()) {
        
         //34.73.109.229:80/auth?username=bailytro&password=password
        
        //let emailArray = AuthenticationHelper.sharedInstance.current_user.username!.components(separatedBy: "@")
        //let username = emailArray[0]
        
        let username = AuthenticationHelper.sharedInstance.current_user.username!

        let sign_in_string = "\(url_string)/auth?username=\(username)&password=\(AuthenticationHelper.sharedInstance.current_user.password!)"

        print("URL STRING: \(sign_in_string)")

        Alamofire.request(sign_in_string, method: .get, parameters: nil, headers: nil).validate().responseString { response in

            print("response: \(response.result.value!)")
            print("status code: \(response.response!.statusCode)")

            switch(response.result) {
            case .success(_):
                if (response.result.value! == "True") {
                    
                    //retreive
                    let get_info_string = "\(self.url_string)/profile?username=\(username)"
                    print(get_info_string)
                    
                    var info: JSON? = nil
                    
                    Alamofire.request(get_info_string, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseString { resp in
                        
                        if((resp.result.value) != nil){
                            info = JSON(resp.result.value!)
                            print(info!)
                        }
                        else{
                            print("Profile response was nil")
                        }
                        
                        
                        
                    }
                    
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
    
    // ---
    func sendPhoto() {
        let profileImage = #imageLiteral(resourceName: "profile_1")
        let data:Data = profileImage.pngData()!
        
        print("sending photo")
        
        requestWith(endUrl: "\(url_string)/profile/image?username=\(AuthenticationHelper.sharedInstance.current_user.username!)", imageData: data, parameters: [:])
        
        print("done sending photo")
    }
    
    func requestWith(endUrl: String, imageData: Data?, parameters: [String : Any], onCompletion: ((JSON?) -> Void)? = nil, onError: ((Error?) -> Void)? = nil){
        
        let url = endUrl /* your API url */
        
        let headers: HTTPHeaders = [
            /* "Authorization": "your_access_token",  in case you need authorization header */
            "Content-type": "multipart/form-data"
        ]
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in parameters {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            
            if let data = imageData{
                multipartFormData.append(data, withName: "file", fileName: "file.png", mimeType: "image/png")
            }
            
        }, usingThreshold: UInt64.init(), to: url, method: .post, headers: headers) { (result) in
            
            print("inside image upload")
            
            switch result{
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    print("response: \(response.result.value!)")
                    print("Succesfully uploaded")
                    if let err = response.error{
                        onError?(err)
                        return
                    }
                    onCompletion?(nil)
                }
            case .failure(let error):
                print("Error in upload: \(error.localizedDescription)")
                onError?(error)
            }
        }
    }
    
    func getImageURL(completion: @escaping (_ response_:String) -> ()) {
        
        // /distance takes placeId, lat, long
        
        print("inside getImageURL")
        
        let thing:String = "\(url_string)/profile/image?username=\(AuthenticationHelper.sharedInstance.current_user.username!)"
        
        Alamofire.request(thing, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseString { response in
            
            print("response obj: \(response)")
            
            if ((response.result.value) != nil) {
                let URLString = response.result.value! as? String
                
                completion(URLString!)
            }
            completion("")
        }
    }
    
    // ---
    
    func sign_up(completion: @escaping (_ response_:String) -> ()) {
        
        let displayNameArray = AuthenticationHelper.sharedInstance.current_user.first_last_name!.components(separatedBy: " ")
        let firstname = displayNameArray[0]
        let lastname = displayNameArray[1]
        
        //print("Email: \(AuthenticationHelper.sharedInstance.current_user.username!)")
        
        let email = AuthenticationHelper.sharedInstance.current_user.email!
        
        let username = AuthenticationHelper.sharedInstance.current_user.username!
        
        //let emailArray = AuthenticationHelper.sharedInstance.current_user.username!.components(separatedBy: "@")
        //let username = emailArray[0]
        
        //AuthenticationHelper.sharedInstance.current_user.username = username
        
        //print("Username: \(AuthenticationHelper.sharedInstance.current_user.username!)")
        
        let birthday = AuthenticationHelper.sharedInstance.current_user.birthday!
        
        let homeTown = AuthenticationHelper.sharedInstance.current_user.homeTown!
        
        let parameters: [String: Any] = [
            "email": email,
            "username": username,
            "password": AuthenticationHelper.sharedInstance.current_user.password!,
            "firstname": firstname,
            "lastname": lastname,
            "birthday": birthday,
            "hometown": homeTown
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
