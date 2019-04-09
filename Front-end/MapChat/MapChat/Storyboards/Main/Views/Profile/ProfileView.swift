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
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    
    @IBOutlet weak var settingsView: UITableView!
    
    let settings_list: [Setting] = [Setting(name: "Dark Mode"),
                                    Setting(name: "Private Posts"),
                                    Setting(name: "Notify Friends")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        settingsView.dataSource = self
        settingsView.delegate = self
        
        // self.navigationController?.navigationBar.prefersLargeTitles = true
        // self.navigationController?.title = ""
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // print("DISPLAY NAME: \(AuthenticationHelper.sharedInstance.current_user.display_name)")
        self.profileName.text = "Baily Troyer"
        self.settingsView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("count: \(settings_list.count)")
        return settings_list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as! SettingsCell
        
        cell.settingsName.text = settings_list[indexPath.row].name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(100)
    }
    
}

// ------- UIView Extensions

extension UIView {
    
    @IBInspectable var cornerRadiusV: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidthV: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColorV: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
}
