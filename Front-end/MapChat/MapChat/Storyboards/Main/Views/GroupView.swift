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
    
    var group_list:[GroupPostManager.GroupObject] = []
    
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
            
            // EXAMPLE DATA:
            /*
            [
                {
                    "place": {
                        "name": "Jabulani mall",
                        "place_id": "ChIJgbX7WpkOlR4RwXZjAPQrZFM",
                        "photo_url": "https://i.kym-cdn.com/entries/icons/original/000/025/999/Screen_Shot_2018-04-24_at_1.33.44_PM.png"},
                        "posts": [
                                    {"dislikes": 0, "username": "bailytro", "likes": 0, "latitude": -26.2041028, "bbox": [28.0473051, -26.2041028, 28.0473051, -26.2041028], "post_id": "dc8a4fa7-bf51-402e-a9c5-62c4f13f9193", "post_time": "2019-04-02 15:14:11.575823-04:00", "longitude": 28.0473051, "gtype": 1, "expire_time": "2019-04-20 22:59:45", "content": "Asdf"}, {"dislikes": 0, "username": "bailytro", "likes": 0, "latitude": -26.2041028, "bbox": [28.0473051, -26.2041028, 28.0473051, -26.2041028], "post_id": "fc1649b6-f2a9-483a-89be-6219944a09c5", "post_time": "2019-04-02 15:14:11.582744-04:00", "longitude": 28.0473051, "gtype": 1, "expire_time": "2019-04-20 22:59:45", "content": "Asdf"}, {"dislikes": 0, "username": "bailytro", "likes": 0, "latitude": -26.2041028, "bbox": [28.0473051, -26.2041028, 28.0473051, -26.2041028], "post_id": "b814827d-1323-417e-a968-e3f5eb635717", "post_time": "2019-04-02 15:13:25.539699-04:00", "longitude": 28.0473051, "gtype": 1, "expire_time": "2019-04-20 22:59:45", "content": "Fdsfdsa"
                                    }
                                  ]
                    
                }
            ]
            */
            Alamofire.request(urlString, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON { response in
                
                // print("response: \(response.result.value!)")
                
                if let result = response.result.value {
                    
                    let groupList = result as! [Any]
                    
                    print("JSON: \(groupList)")
                    for group in groupList {
                        
                        let groupDictionary = group as! NSDictionary
                        
                        let place = groupDictionary.value(forKey: "place") as! NSDictionary
                        
                        let groupObject = GroupPostManager.GroupObject(URL: place.value(forKey: "photo_url") as! String, posts: place.value(forKey: "posts") as! [NSDictionary], name: place.value(forKey: "name") as! String)
                        
                        self.group_list.append(groupObject)
                    }
                    print("reloading data")
                    self.groupTableView.reloadData()
                    //self.feedView.reloadData()
                }
            }
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
