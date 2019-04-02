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
