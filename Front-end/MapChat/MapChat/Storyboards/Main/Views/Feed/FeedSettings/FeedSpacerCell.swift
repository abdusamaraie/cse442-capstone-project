//
//  FeedSpacerCell.swift
//  MapChat
//
//  Created by Baily Troyer on 4/21/19.
//  Copyright © 2019 CSE442Group. All rights reserved.
//

import Foundation
import UIKit

class FeedSpacerCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
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
    }
}
