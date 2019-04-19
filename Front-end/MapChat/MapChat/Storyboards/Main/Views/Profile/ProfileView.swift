//
//  ProfileView.swift
//  MapChat
//
//  Created by Baily Troyer on 2/27/19.
//  Copyright © 2019 CSE442Group. All rights reserved.
//

import Foundation
import UIKit

struct Setting {
    var name: String
}

class ProfileView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var settingsView: UITableView!
    
    let settings_list: [Setting] = [Setting(name: "Profile"),
                                    Setting(name: "Settings"),
                                    Setting(name: "Log out"),
                                    Setting(name: "Terms of Service"),
                                    Setting(name: "Cookie Policy"),
                                    Setting(name: "Privacy Policy"),
                                    Setting(name: "App Version")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        settingsView.dataSource = self
        settingsView.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.settingsView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "to_advanced_settings", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings_list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath.row == (settings_list.count/2) - 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SpacerCell", for: indexPath) as! SpacerCell
            
            return cell
        } else if (settings_list[indexPath.row].name == "App Version") {
            let cell = tableView.dequeueReusableCell(withIdentifier: "VersionCell", for: indexPath) as! AppVersionCell
            
            cell.versionName.text = settings_list[indexPath.row].name
            cell.versionNumber.text = "7.2.0"
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BasicSettingCell", for: indexPath) as! SettingsCell
            
            cell.settingName.text = self.settings_list[indexPath.row].name
            
            return cell
        }
    }
    
}
