//
//  User.swift
//  MapChat
//
//  Created by Baily Troyer on 2/27/19.
//  Copyright © 2019 CSE442Group. All rights reserved.
//

import Foundation

class User {
    // todo
}

class AppState {
    
    static func getUser() {
        
        WebServicesManager.getUser(username: "username") { responseObject, error in
            print("responseObject = \(String(describing: responseObject)); error = \(String(describing: error))")
            return
        }
    }
    
    static func upVoteMessage() {
        
    }
    
    static func getMessageFeed(latLong: (Double, Double)) -> [[String : Any]] {
        
        WebServicesManager.getFeed(latLong: latLong) { responseObject, error in
            print("responseObject = \(String(describing: responseObject)); error = \(String(describing: error))")
            return
        }
        
        return [["test": "json"], ["test": "json"]]
    }
    
}
