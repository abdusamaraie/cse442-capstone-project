//
//  RadiusCell.swift
//  MapChat
//
//  Created by Baily Troyer on 4/21/19.
//  Copyright © 2019 CSE442Group. All rights reserved.
//

import Foundation
import UIKit

class RadiusCell: UITableViewCell {
    
    @IBOutlet weak var feedradiusLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if DarkModeBool.darkmodeflag == true
        {
            backgroundColor = .black
            feedradiusLabel.textColor = .white
        }
        else if DarkModeBool.darkmodeflag == false
        { 
            backgroundColor = .white
            feedradiusLabel.textColor = .black
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
