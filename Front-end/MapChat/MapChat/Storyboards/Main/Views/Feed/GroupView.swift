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
    
    var refreshControl = UIRefreshControl()
    
    // var group_list:[GroupPostManager.GroupObject]!
    
    var group_list:[GroupPostManager.GroupObject] = []
    
//    var group_list:[GroupPostManager.GroupObject]! {
//        didSet{
//            groupTableView.reloadData()
//        }
//    }
    
    var selectedGroup: GroupPostManager.GroupObject = GroupPostManager.GroupObject()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Feed"
        
        locManager.delegate = self
        groupTableView.dataSource = self
        groupTableView.delegate = self
        
        // refresh
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: UIControl.Event.valueChanged)
        groupTableView.addSubview(refreshControl)
        
        // drop view modal
        self.tabBarController?.delegate = UIApplication.shared.delegate as? UITabBarControllerDelegate
        
    }
    
    @objc func refresh(sender:AnyObject) {
        // Code to refresh table view
        loadFeed()
        refreshControl.endRefreshing()
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        if let indexPath = groupTableView.indexPathForSelectedRow {
//            groupTableView.deselectRow(at: indexPath, animated: true)
//        }
        loadFeed()
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        loadFeed()
//    }
    
    func wipe_feed() {
        print("wiping feed")
        self.group_list = []
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(231)
    }
    
    func loadFeed() {
        
        wipe_feed()
        
        print("requesting location")
        locManager.requestWhenInUseAuthorization()
        if((CLLocationManager.authorizationStatus() == .authorizedWhenInUse) || (CLLocationManager.authorizationStatus() ==  .authorizedAlways)) {
            print("loaction requested... now loading loc manager")
            locManager.startUpdatingLocation()
            // locManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        print("location manager INSIDE")
        
        // let sv = UIViewController.displaySpinner(onView: self.view)
        
        if let location = locations.first {
            
            // self.navigationItem.title = "\(location.coordinate.latitude), \(location.coordinate.longitude)"
            
            GroupPostManager.sharedInstance.latitude = "\(location.coordinate.latitude)"
            GroupPostManager.sharedInstance.longitude = "\(location.coordinate.longitude)"
            
            // displau spinner
            
            GroupPostManager.sharedInstance.getGroupData(completion: {(response) in
                
                let response_object: [GroupPostManager.GroupObject] = response
                
                // print("response object_group view: \(response_object)")
                // print("count_group view: \(response_object.count)")
                
                if (response_object.count != 0) {
                    // print("response: \(response)")
                    
                    self.group_list = response
                    // UIViewController.removeSpinner(spinner: sv)
                    self.groupTableView.reloadData()
                } else {
                    // print("RESPONSE WAS NIL")
                    // UIViewController.removeSpinner(spinner: sv)
                }
            })
            
        }
    }
        
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("count: \(group_list.count)")
        // return group_list.count
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
//        let group_item = group_list[indexPath.row]
//
//        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupViewCell", for: indexPath as IndexPath) as! GroupViewCell
//
//        // cell.groupImage.image = #imageLiteral(resourceName: "davis_hall")
//
//        let url = URL(string: group_item.URL!)
//
//        DispatchQueue.global().async {
//            let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
//            DispatchQueue.main.async {
//                cell.groupImage.image = UIImage(data: data!)
//                cell.groupImage.contentMode = .scaleToFill
//                // cell.groupImage.alpha = 0.35
//            }
//        }
//
//        cell.buildingName.text = group_list[indexPath.row].name
//
//        return cell
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TestCard", for: indexPath as IndexPath) as! CardCell
        
        let detailVC = storyboard?.instantiateViewController(withIdentifier: "CardContent")
    
        cell.card.shouldPresent(detailVC, from: self, fullscreen: true)
        //cell.card.detailView = detailVC?.view
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("index path: \(indexPath.row)")
        print("group list: \(group_list)")
        if (group_list.count > 0) {
            self.selectedGroup = group_list[indexPath.row]
            GroupPostManager.sharedInstance.current_group = self.selectedGroup
            self.performSegue(withIdentifier: "toGroup", sender: self)
            groupTableView.deselectRow(at: indexPath, animated: true)
        } else {
            print("not yet")
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toGroup") {
            let feedView = segue.destination as! FeedView
            feedView.place_id = selectedGroup.ID!
            feedView.place_name = selectedGroup.name!
        }
    }
    
}

extension UIImageView {
    func tintImageColor(color : UIColor) {
        self.image = self.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        self.tintColor = color
    }
}
