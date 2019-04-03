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
        loadFeed()
    }
    
    func loadFeed() {
        
        locManager.requestWhenInUseAuthorization()
        if((CLLocationManager.authorizationStatus() == .authorizedWhenInUse) || (CLLocationManager.authorizationStatus() ==  .authorizedAlways)) {
            locManager.requestLocation()
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        self.messages = []
        
        if let location = locations.first {
            
            GroupPostManager.sharedInstance.assignLatLong(latitde: "\(location.coordinate.latitude)", longitude: "\(location.coordinate.longitude)")
            
            GroupPostManager.sharedInstance.getPostData(completion: {(response) in
                
                // response dictionary
                let response_dict: [NSDictionary] = response
                print("response_dict: \(response_dict)")
                
                for message_dict in response_dict {
                    let message:String = message_dict.value(forKey: "content") as! String
                    let username:String = message_dict.value(forKey: "username") as! String
                    
                    self.messages.append(Message(message: message, username: username))
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
        
        let messageContent = self.messages[indexPath.row].message
        
        
        cell.title.text = messageContent
        cell.title.center = cell.center
        // cell.clipsToBounds = true

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
