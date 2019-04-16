//
//  CardCell.swift
//  MapChat
//
//  Created by Baily Troyer on 4/14/19.
//  Copyright © 2019 CSE442Group. All rights reserved.
//

import Foundation
import UIKit
import Cards

class CardCell: UITableViewCell {
    
    @IBOutlet weak var card: CardHighlight!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
