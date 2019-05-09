//
//  FeedSettingsView.swift
//  MapChat
//
//  Created by Baily Troyer on 4/21/19.
//  Copyright © 2019 CSE442Group. All rights reserved.
//

import Foundation
import UIKit

struct FeedSetting {
    var settingName: String
}

class FeedSettingsView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var settingsView: UITableView!
    
    var settingsList:[FeedSetting] = [FeedSetting(settingName: "empty"),
                                      FeedSetting(settingName: "radius"),
                                      FeedSetting(settingName: "location"),
                                      FeedSetting(settingName: "notification")]
    
    override func viewDidLoad() {
        print("inside view")
        super.viewDidLoad()
        
        settingsView.delegate = self
        settingsView.dataSource = self
        
        if DarkModeBool.darkmodeflag == true
        {
            settingsView.backgroundColor = .black
            self.navigationController?.navigationBar.barTintColor = .black
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            settingsView.reloadData()
        }
        else if DarkModeBool.darkmodeflag == false
        {
            settingsView.backgroundColor = .white
            self.navigationController?.navigationBar.barTintColor = .white
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
            settingsView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("settings list count: \(settingsList.count)")
        return settingsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FeedSettingsSpacerCell", for: indexPath) as! FeedSpacerCell
            return cell
        } else {
            if (settingsList[indexPath.row].settingName == "radius") {
                let cell = tableView.dequeueReusableCell(withIdentifier: "RadiusCell", for: indexPath) as! RadiusCell
                cell.iconImage.tintColor = UIColor.blue
                return cell
            } else if (settingsList[indexPath.row].settingName == "location") {
                let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationCell
                cell.iconImage.tintColor = UIColor.blue
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! NotificationCell
                cell.iconImage.tintColor = UIColor.blue
                return cell
            }
        }
    }
}
