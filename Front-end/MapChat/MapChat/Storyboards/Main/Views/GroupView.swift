//
//  GroupView.swift
//  MapChat
//
//  Created by Baily Troyer on 4/1/19.
//  Copyright © 2019 CSE442Group. All rights reserved.
//

import Foundation
import UIKit

class GroupView: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var groupTableView: UITableView!
    
    var items:[Any] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        groupTableView.dataSource = self
        groupTableView.delegate = self
        
        items.append("hey")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.groupTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("count: \(items.count)")
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        print("loading cell")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupViewCell", for: indexPath as IndexPath) as! GroupViewCell
        
        
        cell.groupImage.image = #imageLiteral(resourceName: "davis_hall")
        cell.groupImage.alpha = 0.35
        cell.groupImage.contentMode = .scaleToFill
        
        //cell.textLabel?.text = self.items[indexPath.row]
        
        return cell
    }
    
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        print("You selected cell #\(indexPath.row)!")
//    }
}
