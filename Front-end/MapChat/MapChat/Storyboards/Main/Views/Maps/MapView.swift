//
//  MapView.swift
//  MapChat
//
//  Created by Baily Troyer on 4/19/19.
//  Copyright © 2019 CSE442Group. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import GoogleMaps

let kMapStyle = "[" +
    "  {" +
    "    \"featureType\": \"poi.business\"," +
    "    \"elementType\": \"all\"," +
    "    \"stylers\": [" +
    "      {" +
    "        \"visibility\": \"off\"" +
    "      }" +
    "    ]" +
    "  }," +
    "  {" +
    "    \"featureType\": \"transit\"," +
    "    \"elementType\": \"labels.icon\"," +
    "    \"stylers\": [" +
    "      {" +
    "        \"visibility\": \"off\"" +
    "      }" +
    "    ]" +
    "  }" +
"]"

class MapView: UIViewController, CLLocationManagerDelegate {
 
    @IBOutlet weak var mapView: GMSMapView!
    var locationManager = CLLocationManager()
    
    //
    
    var startLocation: CLLocation!
    var lastLocation: CLLocation!
    var startDate: Date!
    var traveledDistance: Double = 0
    
    
    // Set the status bar style to complement night-mode.
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // User Location
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        //locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = 10
        
        locationManager.startUpdatingLocation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if lastLocation != nil {
            print("UPDATING PINS")
            getGroups(lastLocation)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        
        if startDate == nil {
            startDate = Date()
        } else {
            print("elapsedTime:", String(format: "%.0fs", Date().timeIntervalSince(startDate)))
        }
        if startLocation == nil {
            startLocation = locations.first
            updateMap(manager, locations)
        } else if let location = locations.last {
            traveledDistance += lastLocation.distance(from: location)
            print("Traveled Distance:",  traveledDistance)
            print("Straight Distance:", startLocation.distance(from: locations.last!))
            
            if (startLocation.distance(from: locations.last!) > 15) {
                updateMap(manager, locations)
            }
        }
        lastLocation = locations.last

        //manager.stopUpdatingLocation()
    }
    
    func updateMap(_ manager: CLLocationManager, _ locations: [CLLocation]) {
        
        print("----refreshing----")
        getGroups(locations[0])
        
        print(locations)
        //let currentLocation =     CLLocationCoordinate2D(latitude:CLLocationDegrees(locations[0].coordinate.latitude), longitude:CLLocationDegrees(locations[0].coordinate.longitude))
        self.mapView.camera = GMSCameraPosition.camera(withTarget:locations[0].coordinate, zoom: 10.0)
        do {
            // Set the map style by passing a valid JSON string.
            mapView.mapStyle = try GMSMapStyle(jsonString: kMapStyle)
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
        print("zooming")
        self.mapView.animate(toZoom: 18)
        self.mapView.isMyLocationEnabled = true
        
        // showMarker(position: locations[0].coordinate, message: <#String#>)
        
        // update radius custom
        let update = GMSCameraUpdate.fit(GMSCircle(position: locations[0].coordinate, radius: CLLocationDistance(50)).bounds())
        mapView.animate(with: update)
        //
        
        manager.stopUpdatingLocation()
    }
    
    func getGroups(_ location: CLLocation) {
        
        // clear mapview to load newly dropped things
        mapView.clear()
        
        GroupPostManager.sharedInstance.latitude = "\(location.coordinate.latitude)"
        GroupPostManager.sharedInstance.longitude = "\(location.coordinate.longitude)"
        
        GroupPostManager.sharedInstance.getGroupData(completion: {(response) in
            
            let response_object: [GroupPostManager.GroupObject] = response
            
            if (response_object.count != 0) {
                // print("response-------->: \(response_object)")
                for value in response_object {
        
                    if (value.ID != nil) {
                        print("GROUP ID: \(value.ID!)")
                        //---
                        GroupPostManager.sharedInstance.current_group.ID = value.ID!
                        
                        GroupPostManager.sharedInstance.assignLatLong(latitde: "\(location.coordinate.latitude)", longitude: "\(location.coordinate.longitude)")
                        
                        GroupPostManager.sharedInstance.getPostData(completion: {(response) in
                            
                            let posts: JSON = response
                            
                            print("posts: \(posts)")
                            
                            for (_, post) in posts {
                                print("POST: -> \(post)")
                                let message = post["content"].string
                                let username = post["username"].string
                                
                                let lat = post["latitude"].double
                                let lon = post["longitude"].double
                                
                                let coordinates = CLLocationCoordinate2D(latitude:lat!, longitude:lon!)
                                
                                self.showMarker(position: coordinates, message: message!, username: username!)
                                // self.messages.append(Message(message: post["content"].string!, tag: "#UBISSHIT", numberLikes: 20))
                            }
                            
                            // self.feedView.reloadData()
                        })
                        //---
                    }
                    
                }

            } else {
                print("RESPONSE WAS NIL")
                // UIViewController.removeSpinner(spinner: sv)
            }
        })
    }
    
    func showMarker(position: CLLocationCoordinate2D, message:String, username:String){
        print("dropping marker")
        let marker = GMSMarker()
        marker.position = position
        marker.title = message
        marker.snippet = username
        marker.map = mapView
    }
}

extension MapView: GMSMapViewDelegate{

}

extension GMSCircle {
    func bounds () -> GMSCoordinateBounds {
        func locationMinMax(_ positive : Bool) -> CLLocationCoordinate2D {
            let sign: Double = positive ? 1 : -1
            let dx = sign * self.radius  / 6378000 * (180 / .pi)
            let lat = position.latitude + dx
            let lon = position.longitude + dx / cos(position.latitude * .pi / 180)
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
        
        return GMSCoordinateBounds(coordinate: locationMinMax(true),
                                   coordinate: locationMinMax(false))
    }
}
