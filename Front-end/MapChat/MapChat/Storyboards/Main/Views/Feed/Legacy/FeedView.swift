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
    var username: String
}

class FeedView: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    @IBOutlet weak var feedView: UITableView!
    
    var locManager = CLLocationManager()
    
    var messages: [Message] = []
    
    var place_id: String = ""
    var place_name: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locManager.delegate = self
        
        feedView.delegate = self
        feedView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationItem.title = place_name
        loadFeed()
    }
    
    func loadFeed() {
        
        locManager.requestWhenInUseAuthorization()
        if((CLLocationManager.authorizationStatus() == .authorizedWhenInUse) || (CLLocationManager.authorizationStatus() ==  .authorizedAlways)) {
            locManager.startUpdatingLocation()
            // locManager.requestLocation()
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        self.messages = []
        
        if let location = locations.first {
            
            GroupPostManager.sharedInstance.assignLatLong(latitde: "\(location.coordinate.latitude)", longitude: "\(location.coordinate.longitude)")
            
            GroupPostManager.sharedInstance.getPostData(completion: {(response) in
                
                let posts: JSON = response
                
                print("posts: \(posts)")
                
                for (_, post) in posts {
                    self.messages.append(Message(message: post["content"].string!, username: "_"))
                }
            
                self.feedView.reloadData()
            })
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath) as! FeedViewCell
        
        print("messages: \(self.messages)")
        
        let messageContent = self.messages[indexPath.row].message
        
        cell.messageTitle.text = messageContent
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(100)
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
