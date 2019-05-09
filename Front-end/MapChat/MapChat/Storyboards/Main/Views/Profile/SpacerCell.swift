//
//  SettingsCellTableViewCell.swift
//  MapChat
//
//  Created by Baily Troyer on 4/9/19.
//  Copyright © 2019 CSE442Group. All rights reserved.
//

import UIKit

class SpacerCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if DarkModeBool.darkmodeflag == true
        {
            backgroundColor = .black
        }
        else if DarkModeBool.darkmodeflag == false
        {
            backgroundColor = .white
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

