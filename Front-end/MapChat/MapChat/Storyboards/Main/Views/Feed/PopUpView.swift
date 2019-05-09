//
//  PopUpView.swift
//  MapChat
//
//  Created by Baily Troyer on 2/27/19.
//  Copyright © 2019 CSE442Group. All rights reserved.
//

import Foundation
import UIKit

class PopUpView: UIViewController {
    
    @IBOutlet weak var message: UILabel!
    
    @IBOutlet weak var upVoteButton: UIButton!
    @IBOutlet weak var downVoteButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("this is pop up view")
        
    }
    
    @IBAction func upVote(_ sender: Any) {
        print("upvote")
        upVoteButton.isSelected = !upVoteButton.isSelected
    }
    
    @IBAction func downVote(_ sender: Any) {
        print("downvote")
        downVoteButton.isSelected = !downVoteButton.isSelected
    }
    
    @IBAction func close(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
}
