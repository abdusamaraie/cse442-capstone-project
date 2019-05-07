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
        
        if (settings_list[indexPath.row].name == "Settings") {
            self.performSegue(withIdentifier: "to_advanced_settings", sender: self)
            tableView.deselectRow(at: indexPath, animated: true)
        } else if (settings_list[indexPath.row].name == "Log out") {
            print("logging out")
            
            //find new way to load auth view
            //self.dismiss(animated: false, completion: {})
            
            //set UserDefaults to nil so the user wont be autmatically logged in
            UserDefaults.standard.set(nil, forKey: "username")
            UserDefaults.standard.set(nil, forKey: "password")
            UserDefaults.standard.set(false, forKey: "is_authenticated")
            UserDefaults.standard.synchronize()
            
            let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
            let loginVC = mainStoryBoard.instantiateViewController(withIdentifier: "HomeViewID")
            
            let appDel:AppDelegate = UIApplication.shared.delegate as! AppDelegate
            
            appDel.window?.rootViewController = loginVC
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings_list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath.row == (settings_list.count/2)) {
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
