//
//  SettingsCellTableViewCell.swift
//  MapChat
//
//  Created by Baily Troyer on 4/9/19.
//  Copyright © 2019 CSE442Group. All rights reserved.
//

import UIKit

class AppVersionCell: UITableViewCell {
    
    @IBOutlet weak var versionName: UILabel!
    @IBOutlet weak var versionNumber: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

