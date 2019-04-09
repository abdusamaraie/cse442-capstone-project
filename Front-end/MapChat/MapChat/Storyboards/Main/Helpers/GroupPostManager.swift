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
                
                print("places: \(places)")
                
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
    
    func placeDistance(completion: @escaping (_ response_:Bool) -> ()) {
        
        let placeID = "ChIJFSvOQC1y04kRCTzdpAd_QJo"
        
        // /distance takes placeId, lat, long
        
        let parameters: [String: Any] = ["lat": latitude,"long": longitude, "placeId": placeID]
        
        Alamofire.request("\(urlString)/distance", method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON { response in
            
            if((response.result.value) != nil) {
                let placeInRadius = response.result.value!
                
                print("placeInRadius: \(placeInRadius)")
                
                completion(true)
            }
            completion(false)
        }
    }
    
    
    
    func getPostData(completion: @escaping (_ response_:JSON) -> ()) {
        
        let parameters: [String: Any] = [
            "placeId": current_group.ID!
        ]
        
        // print("parameters: \(parameters)")
        
        Alamofire.request("\(urlString)/place/message", method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON { response in
            
            
            if((response.result.value) != nil) {
                let posts = JSON(response.result.value!)
                completion(posts)
                
            }
            completion([])
        }
    }
        
}

