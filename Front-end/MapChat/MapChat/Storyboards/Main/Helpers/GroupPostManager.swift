//
//  GroupPostManager.swift
//  MapChat
//
//  Created by Baily Troyer on 4/2/19.
//  Copyright © 2019 CSE442Group. All rights reserved.
//

import Foundation
import Alamofire

class GroupPostManager {
    
    struct GroupObject {
        var URL: String?
        var posts: [NSDictionary]?
        var name: String?
        var ID: String?
        
        init(URL: String? = nil, //👈
            posts: [NSDictionary]? = nil,
            name: String? = nil,
            ID: String? = nil) {

            self.URL = URL
            self.posts = posts
            self.name = name
            self.ID = ID
        }
    }
    
    let urlString = "http://34.73.109.229:80/message"
    
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
        
        
        let parameters: [String: Any] = [
            "lat": latitude,
            "long": longitude,
            "distance": "20"
        ]
        
        Alamofire.request(urlString, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON { response in
            
            // print("response: \(response.result.value!)")
            
            if let result = response.result.value {
    
                let groupList = result as! [Any]
                
                // print("group List: \(groupList)")
                // print("JSON: \(groupList)")
                for group in groupList {
                    
                    // print("group: \(group)")
                    
                    let groupDictionary = group as! NSDictionary
                    let place = groupDictionary.value(forKey: "place") as! NSDictionary
                    
                    let groupObject = GroupPostManager.GroupObject(URL: (place.value(forKey: "photo_url") as! String), posts: (groupDictionary.value(forKey: "posts") as! [NSDictionary]), name: (place.value(forKey: "name") as! String), ID: (place.value(forKey: "place_id") as! String))
                    
                    self.group_list.append(groupObject)
                }
                
                // print("completion of group list!!! GOOD")
                completion(self.group_list)

//                self.groupTableView.reloadData()
            }
            
            // print("completion of empty list due to error")
            completion([])
        }
    }
    
    
    
    func getPostData(completion: @escaping (_ response_:[NSDictionary]) -> ()) {
        
        let parameters: [String: Any] = [
            "lat": latitude,
            "long": longitude,
            "distance": "20"
        ]
        
        // print("parameters: \(parameters)")
        
        Alamofire.request(urlString, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON { response in
            
            if let result = response.result.value {
                
                let groupList = result as! [Any]
                
                // print("current group ID: \(self.current_group.ID)")
                // print("group list: \(groupList)")
                
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

