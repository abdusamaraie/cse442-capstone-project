//
//  CommentView.swift
//  MapChat
//
//  Created by Baily Troyer on 4/27/19.
//  Copyright © 2019 CSE442Group. All rights reserved.
//

import Foundation
import UIKit

class CommentView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var spacerView: UIView!
    @IBOutlet weak var messagedropLabel: UILabel!
    @IBOutlet weak var commentsView: UITableView!
    // CommentCellObject
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentsView.delegate = self
        commentsView.dataSource = self
        
        if DarkModeBool.darkmodeflag == true
        {
            commentsView.backgroundColor = .black
            view.backgroundColor = .black
            messagedropLabel.textColor = .white
            spacerView.backgroundColor = .black
            self.navigationController?.navigationBar.barTintColor = .black
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        }
        else if DarkModeBool.darkmodeflag == false
        {
            commentsView.backgroundColor = .white
            view.backgroundColor = .white
            messagedropLabel.textColor = .black
            spacerView.backgroundColor = .white
            self.navigationController?.navigationBar.barTintColor = .white
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AdvancedFeedCellDuplicate", for: indexPath) as! AdvancedFeedCell
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCellObject", for: indexPath) as! CommentCell
            
            return cell
        }
        
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
