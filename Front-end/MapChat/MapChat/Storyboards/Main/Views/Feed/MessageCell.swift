//
//  MessageCell.swift
//  MapChat
//
//  Created by Baily Troyer on 4/19/19.
//  Copyright © 2019 CSE442Group. All rights reserved.
//

import Foundation
import UIKit

class MessageCell: UITableViewCell {
    
    @IBOutlet weak var messageBody: UILabel!
    @IBOutlet weak var messageTag: UILabel!
    @IBOutlet weak var numberLikes: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func upVote(_ sender: Any) {
        
    }
    @IBAction func downVote(_ sender: Any) {
    }
}
