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
    var group_list:[GroupPostManager.GroupObject] = []
    
    var selectedGroup: GroupPostManager.GroupObject = GroupPostManager.GroupObject()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locManager.delegate = self
        
        groupTableView.dataSource = self
        groupTableView.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.group_list = []
        loadFeed()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(150)
    }
    
    func loadFeed() {
        
        locManager.requestWhenInUseAuthorization()
        if((CLLocationManager.authorizationStatus() == .authorizedWhenInUse) || (CLLocationManager.authorizationStatus() ==  .authorizedAlways)) {
            locManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.first {
            
            let latitude = "\(location.coordinate.latitude)"
            let longitude = "\(location.coordinate.longitude)"
            
            // print("lat, long: \(latitude), \(longitude)")
            
            GroupPostManager.sharedInstance.latitude = latitude
            GroupPostManager.sharedInstance.longitude = longitude
            
            GroupPostManager.sharedInstance.getGroupData(completion: {(response) in
                
                let response_object: [GroupPostManager.GroupObject] = response
                
                // print("response object_group view: \(response_object)")
                // print("count_group view: \(response_object.count)")
                
                if (response_object.count != 0) {
                    // print("response: \(response)")
                    
                    self.group_list = response
                    self.groupTableView.reloadData()
                } else {
                    // print("RESPONSE WAS NIL")
                }
            })
            
        }
    }
        
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("count: \(group_list.count)")
        return group_list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let group_item = group_list[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupViewCell", for: indexPath as IndexPath) as! GroupViewCell
        
        // cell.groupImage.image = #imageLiteral(resourceName: "davis_hall")
        
        let url = URL(string: group_item.URL!)
        
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            DispatchQueue.main.async {
                cell.groupImage.image = UIImage(data: data!)
                cell.groupImage.contentMode = .scaleToFill
                // cell.groupImage.alpha = 0.35
            }
        }
        
        cell.buildingName.text = group_list[indexPath.row].name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.selectedGroup = group_list[indexPath.row]
        GroupPostManager.sharedInstance.current_group = self.selectedGroup
        self.performSegue(withIdentifier: "toGroup", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toGroup") {
            let feedView = segue.destination as! FeedView
            feedView.place_id = selectedGroup.ID!
            feedView.place_name = selectedGroup.name!
        }
    }
    
}
