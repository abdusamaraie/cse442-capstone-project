//
//  LocationCell.swift
//  MapChat
//
//  Created by Baily Troyer on 4/21/19.
//  Copyright © 2019 CSE442Group. All rights reserved.
//

import Foundation
import UIKit

class LocationCell: UITableViewCell {
    
    @IBOutlet weak var locationservicesLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if DarkModeBool.darkmodeflag == true
        {
            backgroundColor = .black
            locationservicesLabel.textColor = .white
        }
        else if DarkModeBool.darkmodeflag == false
        {
            backgroundColor = .white
            locationservicesLabel.textColor = .black
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
