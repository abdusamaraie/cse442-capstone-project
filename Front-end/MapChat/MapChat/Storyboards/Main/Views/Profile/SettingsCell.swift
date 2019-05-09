//
//  SettingsCellTableViewCell.swift
//  MapChat
//
//  Created by Baily Troyer on 4/9/19.
//  Copyright © 2019 CSE442Group. All rights reserved.
//

import UIKit

class SettingsCell: UITableViewCell {
    
    @IBOutlet weak var settingName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if DarkModeBool.darkmodeflag == true
        {
            backgroundColor = .black
            settingName.textColor = .white
        }
        else if DarkModeBool.darkmodeflag == false
        {
            backgroundColor = .white
            settingName.textColor = .black
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
