//
//  LocationServicesManager.swift
//  MapChat
//
//  Created by Baily Troyer on 2/26/19.
//  Copyright © 2019 CSE442Group. All rights reserved.
//

import Foundation
import CoreLocation

class LocationServicesManager {
    
    static func getCurrentLocation() {
        
        let locManager = CLLocationManager()
        locManager.requestWhenInUseAuthorization()
        
        var currentLocation: CLLocation!
        
        if( CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() ==  .authorizedAlways){
            
            currentLocation = locManager.location
        }
        
        print("\(currentLocation.coordinate.longitude)")
        print("\(currentLocation.coordinate.latitude)")
    }
    
}
