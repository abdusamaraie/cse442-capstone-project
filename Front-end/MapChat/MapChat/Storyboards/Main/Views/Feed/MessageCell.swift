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
    @IBOutlet weak var upvoteIcon: UIButton!
    @IBOutlet weak var downvoteIcon: UIButton!
    
    var vote: Int!
    var defaultColor: UIColor!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        defaultColor = self.upvoteIcon.tintColor
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func upVote(_ sender: Any) {
        print("action")
        if (vote == nil) {
            print("upvote")
            self.upvoteIcon.tintColor = UIColor.blue
            vote=1
        } else if (vote == 0) {
            self.downvoteIcon.tintColor = defaultColor
            self.upvoteIcon.tintColor = UIColor.blue
            vote=1
        } else {
            vote=1
        }
        
    }
    
    @IBAction func downVote(_ sender: Any) {
        print("action")
        if (vote == nil) {
            print("downvote")
            self.downvoteIcon.tintColor = UIColor.blue
            vote=0
        } else if (vote == 1) {
            self.upvoteIcon.tintColor = defaultColor
            self.downvoteIcon.tintColor = UIColor.blue
            vote=0
        } else {
            vote=0
        }
    }
}
