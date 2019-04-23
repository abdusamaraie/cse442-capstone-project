//
//  MessageCell.swift
//  MapChat
//
//  Created by Baily Troyer on 4/19/19.
//  Copyright © 2019 CSE442Group. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class MessageCell: UITableViewCell {
    
    @IBOutlet weak var messageBody: UILabel!
    @IBOutlet weak var messageTag: UILabel!
    @IBOutlet weak var numberLikes: UILabel!
    @IBOutlet weak var upvoteIcon: UIButton!
    @IBOutlet weak var downvoteIcon: UIButton!
    
    let urlString = "http://35.238.74.200:80/rating"
    
    var vote: Bool!
    var defaultColor: UIColor!
    var postId: String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        defaultColor = self.upvoteIcon.tintColor
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func upVote(_ sender: Any) {
        if postId != nil {
            print("action: \(postId!)")
            if (vote == nil) {
                print("upvote")
                self.upvoteIcon.tintColor = UIColor.blue
                vote=true
            } else if (vote == false) {
                self.downvoteIcon.tintColor = defaultColor
                self.upvoteIcon.tintColor = UIColor.blue
                vote=true
            } else {
                vote=true
            }
        }
        
    }
    
    @IBAction func downVote(_ sender: Any) {
        if postId != nil {
            print("action: \(postId!)")
            if (vote == nil) {
                print("downvote")
                self.downvoteIcon.tintColor = UIColor.blue
                vote=false
            } else if (vote == true) {
                self.upvoteIcon.tintColor = defaultColor
                self.downvoteIcon.tintColor = UIColor.blue
                vote=false
            } else {
                vote=false
            }
            
            performVote(completion: {(result) in
                
                if result {
                    print("all good")
                } else {
                    print("error")
                }
            })
        }
    }
    
    func performVote(completion: @escaping (_ response_:Bool) -> ()) {
        
        let parameters: [String: Any] = ["username": AuthenticationHelper.sharedInstance.current_user.username!,
                                         "rating": vote,
                                         "postId": postId]
        
        // /rating takes username postId and rating: bool
        
        Alamofire.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseString { response in
            
            switch response.result {
            case .success:
                
                completion(true)
                
            // break
            case .failure(let error):
                print("error: \(error)")
                completion(false)
            }
        }
    }
}
