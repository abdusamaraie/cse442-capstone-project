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

struct MessageObject {
    var latitude: String
    var longitude: String
    // var username: String
    var content: String
}

class FeedView: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    @IBOutlet weak var feedView: UITableView!
    
    var locManager = CLLocationManager()
    
    var messageObjects = [MessageObject]()
    
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
        
        self.messageObjects = []
        
        locManager.requestWhenInUseAuthorization()
        if((CLLocationManager.authorizationStatus() == .authorizedWhenInUse) || (CLLocationManager.authorizationStatus() ==  .authorizedAlways)) {
            locManager.requestLocation()
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            
            // start loading spinner
            //let sv = UIViewController.displaySpinner(onView: self.view)
            
            let latitude = "\(location.coordinate.latitude)"
            let longitude = "\(location.coordinate.longitude)"
            
            let urlString = "http://34.73.109.229:80/message"
            
            let parameters: [String: Any] = [
                "lat": latitude,
                "long": longitude,
                "distance": "20",
                //"username": username!
            ]
            
            // print("parameters: \(parameters)")
            
            Alamofire.request(urlString, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON { response in
                
                // print("response: \(response.result.value!)")
                
                if let result = response.result.value {
                    let messageList = result as! [Any]
                    print("JSON: \(messageList)")
                    for message in messageList {
                        
                        let message_json = message as! NSDictionary

                        let latitude = message_json.value(forKey: "latitude") as! NSNumber
                        let longitude = message_json.value(forKey: "longitude") as! NSNumber
                        let content = message_json.value(forKey: "content") as! String
                        
                        //self.messageObjects.append(MessageObject(latitude: latitude, longitude: longitude, username: username, content: content))
                        self.messageObjects.append(MessageObject(latitude: "\(latitude)", longitude: "\(longitude)", content: content))
                    }
                    print("reloading data")
                    self.feedView.reloadData()
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageObjects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        print("building cell")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath) as! FeedViewCell
        
        // these fields would be returned from the WebServicesManager class
        
        let messageContent = self.messageObjects[indexPath.row].content
        let messageLocation = "\(self.messageObjects[indexPath.row].latitude),\(self.messageObjects[indexPath.row].longitude)"
        
        print("message content: \(messageContent)")
        print("message location: \(messageLocation)")
        
        cell.time.text = "_"
        cell.title.text = messageContent
        cell.location.text = messageLocation

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
