//
//  CommentCell.swift
//  MapChat
//
//  Created by Baily Troyer on 4/27/19.
//  Copyright © 2019 CSE442Group. All rights reserved.
//

import Foundation
import UIKit

class CommentCell: UITableViewCell {
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var displayName: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var replyingToMessage: UILabel!
    @IBOutlet weak var message: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if DarkModeBool.darkmodeflag == true
        {
            backgroundColor = .black
            displayName.textColor = .white
            username.textColor = .white
            replyingToMessage.textColor = .white
            message.textColor = .white
        }
        else if DarkModeBool.darkmodeflag == false
        {
            backgroundColor = .white
            displayName.textColor = .black
            username.textColor = .black
            replyingToMessage.textColor = .black
            message.textColor = .black
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
