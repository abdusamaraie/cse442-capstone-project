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
    internal var on: Bool
}

class AdvancedSettingsView: UIViewController, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate {
    
    @IBOutlet weak var advancedSettingsView: UITableView!
    
    var advanced_settings_list: [AdvancedSetting] = [AdvancedSetting(name: "Emails", on: true),
                                                     AdvancedSetting(name: "Internet ads", on: false),
                                                     AdvancedSetting(name: "Push notifications", on: true),
                                                     AdvancedSetting(name: "Account details", on: false),
                                                     AdvancedSetting(name: "Join Early Access", on: true)]
    
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (indexPath.row != 0) {
            let alert = UIAlertController(title: advanced_settings_list[indexPath.row].name, message: nil, preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "On", style: .default , handler:{ (UIAlertAction)in
                print("User click on button")
                var selected_int: Int = indexPath.row
                self.update_settings(selected_int, true)
            }))
            
            alert.addAction(UIAlertAction(title: "Off", style: .default , handler:{ (UIAlertAction)in
                print("User click Off button")
                var selected_int: Int = indexPath.row
                self.update_settings(selected_int, false)
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction)in
                print("User click Dismiss button")
            }))
            
            self.present(alert, animated: true, completion: {
                print("completion block")
            })
            
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func update_settings(_ selectedRow: Int, _ value: Bool) {
        print("\(selectedRow), \(value)")
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
