//
//  GroupPostManager.swift
//  MapChat
//
//  Created by Baily Troyer on 4/2/19.
//  Copyright © 2019 CSE442Group. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class GroupPostManager {
    
    struct GroupObject {
        var URL: String?
        var name: String?
        var ID: String?
        var numberPosts: Int?
        
        init(URL: String? = nil, //👈
            name: String? = nil,
            ID: String? = nil,
            numberPosts: Int? = nil) {

            self.URL = URL
            self.name = name
            self.ID = ID
            self.numberPosts = numberPosts
        }
    }
    
    let urlString = "http://35.238.74.200:80"
    
    static var sharedInstance = GroupPostManager()
    
    var group_list: [GroupObject] = []
    
    var current_group:GroupObject = GroupObject()
    
    var latitude: String = ""
    var longitude: String = ""
    
    var placeId: String = ""
    
    var posts: [NSDictionary] = []
    
    func assignLatLong(latitde: String, longitude: String) {
        self.latitude = latitde
        self.longitude = longitude
    }
    
    func getGroupData(completion: @escaping (_ response_:[GroupObject]) -> ()) {
        
        let parameters: [String: Any] = ["lat": latitude,"long": longitude]
        
        print("parameters: \(parameters)")
        
        Alamofire.request("\(urlString)/place", method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON { response in
            
            if((response.result.value) != nil) {
                let places = JSON(response.result.value!)
                
                print("places: \(places)")
                
                for (_,place) in places {
            
                    self.group_list.append(GroupPostManager.GroupObject(URL: place["photo_url"].string!, name: place["name"].string!, ID: place["place_id"].string!, numberPosts: place["number_of_posts"].int!))
                }
                
                completion(self.group_list)
                self.group_list = []
                
            } else {
                print("places was nil")
            }
            completion([])
            self.group_list = []
        }
    }
    
    func placeDistance(completion: @escaping (_ response_:Double) -> ()) {
        
        // /distance takes placeId, lat, long
        
        let parameters: [String: Any] = ["lat": latitude,"long": longitude, "placeId": placeId]
        
        print("parameters: \(parameters)")
        
        Alamofire.request("\(urlString)/distance", method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON { response in
            
            if((response.result.value) != nil) {
                let placeInRadius = response.result.value! as? Double
                
                print("placeInRadius: \(placeInRadius!)")
                
                completion(placeInRadius!)
            }
            completion(-1.0)
        }
    }
    
    
    
    func getPostData(completion: @escaping (_ response_:JSON) -> ()) {
        
        let parameters: [String: Any] = [
            "placeId": current_group.ID!
        ]
        
        print("parameters: \(parameters)")
        
        Alamofire.request("\(urlString)/place/message", method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON { response in
            
            
            if((response.result.value) != nil) {
                let posts = JSON(response.result.value!)
                completion(posts)
                
            }
            completion([])
        }
    }
    
//    func getProfileInformation(completion: @escaping (_ response_:JSON) -> ()) {
//
//        let parameters: [String: Any] = [
//            "username": AuthenticationHelper.sharedInstance.current_user.username
//        ]
//
//        print("parameters: \(parameters)")
//
//        Alamofire.request("\(urlString)/settings", method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON { response in
//
//
//            if((response.result.value) != nil) {
//                let posts = JSON(response.result.value!)
//                completion(posts)
//
//            }
//            completion([])
//        }
//    }
    
}

