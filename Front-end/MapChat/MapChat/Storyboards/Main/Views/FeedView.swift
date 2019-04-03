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

/*
 
 {
 bbox =     (
 "-78.79558400000001",
 "42.998865",
 "-78.79558400000001",
 "42.998865"
 );
 content = "Hey there";
 dislikes = 0;
 "expire_time" = "2019-04-20 22:59:45";
 gtype = 1;
 latitude = "42.998865";
 likes = 0;
 longitude = "-78.79558400000001";
 "post_id" = "d55dcac1-1a69-4a67-9965-acacd90985f3";
 "post_time" = "2019-04-02 18:02:41.116118-04:00";
 username = bailytro;
 }
 
 */

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
        
        self.navigationController?.title = "Feed"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(updateRefresh), for: .valueChanged)
        feedView.refreshControl = refreshControl
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        loadFeed()
    }
    
    @objc func updateRefresh(refreshControl: UIRefreshControl) {
        
        // load feed, calling API, refreshing table view and spinning loader
        loadFeed()
        refreshControl.endRefreshing()
        
        // todo: add functionality with flask instance
        WebServicesManager.testAlamofire()
    }
    
    func loadFeed() {
        
        self.messages = []
        
        locManager.requestWhenInUseAuthorization()
        if((CLLocationManager.authorizationStatus() == .authorizedWhenInUse) || (CLLocationManager.authorizationStatus() ==  .authorizedAlways)) {
            locManager.requestLocation()
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            
            // start loading spinner
            // let sv = UIViewController.displaySpinner(onView: self.view)
            
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
        
        // these fields would be returned from the WebServicesManager class
        
        let messageContent = self.messages[indexPath.row].message
        // let messageLocation = "\(self.messageObjects[indexPath.row].latitude),\(self.messageObjects[indexPath.row].longitude)"
        
        cell.time.text = "_"
        cell.title.text = messageContent
        cell.location.text = "_"

        cell.clipsToBounds = true

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
