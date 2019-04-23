//
//  MapView.swift
//  MapChat
//
//  Created by Baily Troyer on 4/19/19.
//  Copyright © 2019 CSE442Group. All rights reserved.
//

import Foundation
import UIKit
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
        
//        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 14.0)
//        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
//        //let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
//
//        do {
//            // Set the map style by passing a valid JSON string.
//            mapView.mapStyle = try GMSMapStyle(jsonString: kMapStyle)
//        } catch {
//            NSLog("One or more of the map styles failed to load. \(error)")
//        }
//
//        self.view = mapView
        
        // User Location
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        //locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = 10
        
        locationManager.startUpdatingLocation()
    }
    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        let userLocation = locations.last
//        let center = CLLocationCoordinate2D(latitude: userLocation!.coordinate.latitude, longitude: userLocation!.coordinate.longitude)
//
//        let camera = GMSCameraPosition.camera(withLatitude: userLocation!.coordinate.latitude,
//                                              longitude: userLocation!.coordinate.longitude, zoom: 13.0)
//        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
//        mapView.isMyLocationEnabled = true
//        self.view = mapView
//
////        let marker = GMSMarker()
////        marker.position = CLLocationCoordinate2D(latitude: userLocation!.coordinate.latitude, longitude: userLocation!.coordinate.longitude)
////        marker.title = "Home"
////        marker.snippet = "hey there :)"
////        marker.map = mapView
//
//        locationManager.stopUpdatingLocation()
//    }
    
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
        
        showMarker(position: locations[0].coordinate)
        
        // update radius custom
        let update = GMSCameraUpdate.fit(GMSCircle(position: locations[0].coordinate, radius: CLLocationDistance(50)).bounds())
        mapView.animate(with: update)
        //
        
        manager.stopUpdatingLocation()
    }
    
    func showMarker(position: CLLocationCoordinate2D){
        let marker = GMSMarker()
        marker.position = position
        marker.title = "Palo Alto"
        marker.snippet = "San Francisco"
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
