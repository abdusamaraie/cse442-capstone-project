//
//  AdvancedSettingsView.swift
//  MapChat
//
//  Created by Baily Troyer on 4/19/19.
//  Copyright © 2019 CSE442Group. All rights reserved.
//

import Foundation
import UIKit

internal struct AdvancedSetting {
    
    internal var name: String
}

class AdvancedSettingsView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var advancedSettingsView: UITableView!
    
    var advanced_settings_list: [AdvancedSetting] = [AdvancedSetting(name: "Emails"),
                                                     AdvancedSetting(name: "Internet ads"),
                                                     AdvancedSetting(name: "Push notifications"),
                                                     AdvancedSetting(name: "Account details"),
                                                     AdvancedSetting(name: "Join Early Access")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Settings"
        
        advancedSettingsView.dataSource = self
        advancedSettingsView.delegate = self
        
        self.navigationController?.navigationBar.topItem?.title = " "
        self.navigationController?.navigationBar.topItem?.backBarButtonItem?.image = #imageLiteral(resourceName: "left")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.advancedSettingsView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return advanced_settings_list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AdvancedSpacerCell", for: indexPath) as! SpacerCell
            
            return cell
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "AdvancedSettingsCell", for: indexPath) as! AdvancedSettingsCell
            
            cell.titleLabel.text = advanced_settings_list[indexPath.row].name
            
            if (advanced_settings_list[indexPath.row].name == "Push notifications") {
                cell.onLabel.text = ""
            } else if (advanced_settings_list[indexPath.row].name == "Account details") {
                cell.onLabel.text = ""
            } else {
                // nothing yet
            }
            
            return cell
        }
    }
    
}
