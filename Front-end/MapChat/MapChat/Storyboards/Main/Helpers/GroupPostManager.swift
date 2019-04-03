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
        
        init(URL: String? = nil, //👈
            name: String? = nil,
            ID: String? = nil) {

            self.URL = URL
            self.name = name
            self.ID = ID
        }
    }
    
    let urlString = "http://34.73.109.229:80"
    
    static var sharedInstance = GroupPostManager()
    
    var group_list: [GroupObject] = []
    
    var current_group:GroupObject = GroupObject()
    
    var latitude: String = ""
    var longitude: String = ""
    
    var posts: [NSDictionary] = []
    
    func assignLatLong(latitde: String, longitude: String) {
        self.latitude = latitde
        self.longitude = longitude
    }
    
    func getGroupData(completion: @escaping (_ response_:[GroupObject]) -> ()) {
        
        let parameters: [String: Any] = ["lat": latitude,"long": longitude]
        
        Alamofire.request("\(urlString)/place", method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON { response in
            
            if((response.result.value) != nil) {
                let places = JSON(response.result.value!)
                
                for (_,place) in places {
            
                    self.group_list.append(GroupPostManager.GroupObject(URL: place["photo_url"].string!, name: place["name"].string!, ID: place["place_id"].string!))
                }
                
                completion(self.group_list)
                self.group_list = []
                
            }
            completion([])
            self.group_list = []
        }
    }
    
    
    
    func getPostData(completion: @escaping (_ response_:[NSDictionary]) -> ()) {
        
        let parameters: [String: Any] = [
            "placeID": current_group.ID!
        ]
        
        Alamofire.request("\(urlString)/place/message", method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON { response in
            
            if let result = response.result.value {
                
                let groupList = result as! [Any]
                
                for group in groupList {
                    
                    let groupDictionary = group as! NSDictionary
                    let place = groupDictionary.value(forKey: "place") as! NSDictionary
                    
                    
                    let place_id = place.value(forKey: "place_id") as! String
                    
                    if (place_id == self.current_group.ID) {
                        let posts_: [NSDictionary] = groupDictionary.value(forKey: "posts") as! [NSDictionary]
                        self.posts = posts_
                        completion(self.posts)
                    }
                }
            }
            completion([])
        }
    }
        
}

