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
    
    // loading view
    var boxView = UIView()
    
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
        
        if (advanced_settings_list[indexPath.row].name == "Internet ads" || advanced_settings_list[indexPath.row].name == "Emails" || advanced_settings_list[indexPath.row].name == "Join Early Access") {
            
            let alert = UIAlertController(title: advanced_settings_list[indexPath.row].name, message: nil, preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "On", style: .default , handler:{ (UIAlertAction)in
                print("User click on button")
                let selected_int: Int = indexPath.row
                self.update_settings(selected_int, true)
            }))
            
            alert.addAction(UIAlertAction(title: "Off", style: .default , handler:{ (UIAlertAction)in
                print("User click Off button")
                let selected_int: Int = indexPath.row
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
        addSavingPhotoView()
        self.advanced_settings_list[selectedRow].on = value
        print("\(selectedRow), \(value)")
        self.advancedSettingsView.reloadData()
        boxView.removeFromSuperview()
    }
    
    func addSavingPhotoView() {
        // You only need to adjust this frame to move it anywhere you want
        boxView = UIView(frame: CGRect(x: view.frame.midX - 90, y: view.frame.midY - 25, width: 180, height: 50))
        boxView.backgroundColor = UIColor.white
        boxView.alpha = 0.8
        boxView.layer.cornerRadius = 10
        
        //Here the spinnier is initialized
        let activityView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        activityView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityView.startAnimating()
        
        let textLabel = UILabel(frame: CGRect(x: 60, y: 0, width: 200, height: 50))
        textLabel.textColor = UIColor.gray
        textLabel.text = "Updating"
        
        boxView.addSubview(activityView)
        boxView.addSubview(textLabel)
        
        view.addSubview(boxView)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AdvancedSpacerCell", for: indexPath) as! SpacerCell
            
            return cell
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "AdvancedSettingsCell", for: indexPath) as! AdvancedSettingsCell
            
            cell.titleLabel.text = advanced_settings_list[indexPath.row].name
            
            if (advanced_settings_list[indexPath.row].on) {
                cell.onLabel.text = "On"
            } else {
                cell.onLabel.text = "Off"
            }
            
            if (advanced_settings_list[indexPath.row].name == "Push notifications") {
                cell.onLabel.text = ""
                cell.isUserInteractionEnabled = false
            } else if (advanced_settings_list[indexPath.row].name == "Account details") {
                cell.onLabel.text = ""
                cell.isUserInteractionEnabled = false
            } else {
                // nothing yet
            }
            
            return cell
        }
    }
    
}
