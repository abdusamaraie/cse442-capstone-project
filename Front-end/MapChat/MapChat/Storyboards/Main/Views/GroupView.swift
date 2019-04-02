//
//  GroupView.swift
//  MapChat
//
//  Created by Baily Troyer on 4/1/19.
//  Copyright © 2019 CSE442Group. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import MapKit
import Alamofire

class GroupView: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var groupTableView: UITableView!
    
    var locManager = CLLocationManager()
    
    var items:[Any] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locManager.delegate = self
        
        groupTableView.dataSource = self
        groupTableView.delegate = self
        
        items.append("hey")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadFeed()
    }
    
    func loadFeed() {
        self.groupTableView.reloadData()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            
            let latitude = "\(location.coordinate.latitude)"
            let longitude = "\(location.coordinate.longitude)"
            
            print("lat, long: \(latitude), \(longitude)")
            
            let urlString = "http://34.73.109.229:80/message"
            
            let parameters: [String: Any] = [
                "lat": latitude,
                "long": longitude,
                "distance": "20",
                //"username": username!
            ]
            
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
                        //self.messageObjects.append(MessageObject(latitude: "\(latitude)", longitude: "\(longitude)", content: content))
                    }
                    print("reloading data")
                    self.groupTableView.reloadData()
                    //self.feedView.reloadData()
                }
            }
            
            // SEND REQUEST TO GET JSON TO LOAD IN FEED
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    // -------------------------------------------------------------------
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("count: \(items.count)")
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        print("loading cell")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupViewCell", for: indexPath as IndexPath) as! GroupViewCell
        
        
        cell.groupImage.image = #imageLiteral(resourceName: "davis_hall")
        cell.groupImage.alpha = 0.35
        cell.groupImage.contentMode = .scaleToFill
        
        //cell.textLabel?.text = self.items[indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //self.performSegue(withIdentifier: "", sender: self)
        //print("You selected cell #\(indexPath.row)!")
    }
}
