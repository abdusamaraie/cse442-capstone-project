//
//  FeedView.swift
//  MapChat
//
//  Created by Baily Troyer on 2/26/19.
//  Copyright © 2019 CSE442Group. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import MapKit
import Alamofire
import SwiftyJSON

struct Message {
    var message: String
    var tag: String
    var numberLikes: Int
    var ID: String
}

class FeedView: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    @IBOutlet weak var feedView: UITableView!
    var selectedLocation:CLLocation!
    
    var locManager = CLLocationManager()
    
    var messages: [Message] = []
    
    var place_id: String = ""
    var place_name: String = ""
    
    var currentLocation:CLLocation!
    
    var startLocation: CLLocation!
    var lastLocation: CLLocation!
    var startDate: Date!
    var traveledDistance: Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locManager.delegate = self
        
        feedView.delegate = self
        feedView.dataSource = self
        
        locManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locManager.distanceFilter = 10
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("view did appear")
        self.navigationItem.title = place_name
        loadFeed()
        // self.feedView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        locManager.stopUpdatingLocation()
    }
    
    func loadFeed() {
        
        locManager.requestWhenInUseAuthorization()
        if((CLLocationManager.authorizationStatus() == .authorizedWhenInUse) || (CLLocationManager.authorizationStatus() ==  .authorizedAlways)) {
            
            locManager.startUpdatingLocation()
            // locManager.requestLocation()
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        
        if startDate == nil {
            startDate = Date()
        } else {
            print("elapsedTime:", String(format: "%.0fs", Date().timeIntervalSince(startDate)))
        }
        if startLocation == nil {
            startLocation = locations.first
            self.selectedLocation = startLocation
            loadData()
        } else if let location = locations.last {
            traveledDistance += lastLocation.distance(from: location)
            print("Traveled Distance:",  traveledDistance)
            print("Straight Distance:", startLocation.distance(from: locations.last!))
            
            if (startLocation.distance(from: locations.last!) > 15) {
                self.selectedLocation = lastLocation
                loadData()
            }
        }
        lastLocation = locations.last
        
        
//        self.messages = []
//
//        if let location = locations.first {
//
//            print("LOADING DATA")
//            self.selectedLocation = location
//            self.locManager.stopUpdatingLocation()
//            loadData()
//        }
    }
    
    func loadData() {
        
        // assign current group id
        
        messages = []
        
        print("placeID: \(place_id)")
        
        GroupPostManager.sharedInstance.current_group.ID = place_id
        
        GroupPostManager.sharedInstance.assignLatLong(latitde: "\(selectedLocation.coordinate.latitude)", longitude: "\(selectedLocation.coordinate.longitude)")
        
        GroupPostManager.sharedInstance.getPostData(completion: {(response) in
            
            let posts: JSON = response
            
            print("posts: \(posts)")
            
            for (_, post) in posts {
                
                let content = post["content"].string!
                let likes = post["likes"].int!
                let postID = post["post_id"].string!
                self.messages.append(Message(message: content, tag: "#TestTag", numberLikes: likes, ID: postID))
            }
            
            self.feedView.reloadData()
        })
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "viewComment", sender: self)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AdvancedFeedCell", for: indexPath) as! AdvancedFeedCell
        
        cell.message.text = self.messages[indexPath.row].message
        
        return cell
    }
}

extension UIViewController {
    class func displaySpinner(onView : UIView) -> UIView {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        return spinnerView
    }
    
    class func removeSpinner(spinner :UIView) {
        DispatchQueue.main.async {
            spinner.removeFromSuperview()
        }
    }
}
