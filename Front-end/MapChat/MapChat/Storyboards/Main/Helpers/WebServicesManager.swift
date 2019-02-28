//
//  WebServicesManager.swift
//  MapChat
//
//  Created by Baily Troyer on 2/26/19.
//  Copyright © 2019 CSE442Group. All rights reserved.
//

import Foundation
import Alamofire

class WebServicesManager{
    
    static let serverIpAddress:String = "192.168.0.0"
    
    static func postRequest() -> [String:String] {
        // do a post request and return post data
        return ["someData" : "someData"]
    }
    
    static func testAlamofire() {
        
        Alamofire.request(serverIpAddress).responseJSON { response in
            
            // original url request
            print("Request: \(String(describing: response.request))")
            
            // http url response
            print("Response: \(String(describing: response.response))")
            
            // response serialization result
            print("Result: \(response.result)")
            
            if let json = response.result.value {
                
                // serialized json response
                print("JSON: \(json)")
            }
            
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                
                // original server data as UTF8 string
                print("Data: \(utf8Text)") // original server data as UTF8 string
            }
        }
        
    }
    
    static func getFeed(latLong: (Double, Double), completionHandler: @escaping (NSDictionary?, Error?) -> ()) {
        let parameters: Parameters = ["latlong": latLong]
        
        Alamofire.request(serverIpAddress, method: .get, parameters: parameters).validate().responseJSON { response in
            
            guard response.result.isSuccess else {
                print("Error while fetching remote rooms: \(String(describing: response.result.error))")
                return
            }
            
            guard let value = response.result.value as? [String: Any],
                let _ = value["rows"] as? [[String: Any]] else {
                    print("Malformed data received from fetchAllRooms service")
                    return
            }
        }
    }
    
    static func getUser(username:String, completionHandler: @escaping (NSDictionary?, Error?) -> ()) {
        
        let parameters: Parameters = ["username": username]
        
        Alamofire.request(serverIpAddress, method: .get, parameters: parameters).validate().responseJSON { response in
            
            guard response.result.isSuccess else {
                print("Error while fetching remote rooms: \(String(describing: response.result.error))")
                return
            }
            
            guard let value = response.result.value as? [String: Any],
                let _ = value["rows"] as? [[String: Any]] else {
                    print("Malformed data received from fetchAllRooms service")
                    return
                }
        }
        
    }
    
}
