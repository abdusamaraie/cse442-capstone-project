//
//  TagView.swift
//  MapChat
//
//  Created by Baily Troyer on 4/22/19.
//  Copyright © 2019 CSE442Group. All rights reserved.
//

import Foundation
import UIKit

struct Tag {
    var tagName: String
}

class TagView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tagsspacer: UIView!
    @IBOutlet weak var tagsView: UITableView!
    
    var tags:[Tag]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tagsView.dataSource = self
        self.tagsView.delegate = self
        
        tags = [Tag(tagName: "UB2019"),
                Tag(tagName: "UB2020"),
                Tag(tagName: "CSE442"),
                Tag(tagName: "I<3Jesse"),
                Tag(tagName: "CSE"),
                Tag(tagName: "UB"),
                Tag(tagName: "CarlTaughtMeJava"),
                Tag(tagName: "oof"),
                Tag(tagName: "yo"),
                Tag(tagName: "getrekt"),
                Tag(tagName: "uwot")]
        
        if DarkModeBool.darkmodeflag == true
        {
            self.tagsView.backgroundColor = .black
            tagsspacer.backgroundColor = .black
            self.navigationController?.navigationBar.barTintColor = .black
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        }
        else if DarkModeBool.darkmodeflag == false
        {
            self.tagsView.backgroundColor = .white
            tagsspacer.backgroundColor = .white
            self.navigationController?.navigationBar.barTintColor = .white
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        }

    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        self.tagsView.reloadData()
    }
    
    @IBAction func done(_ sender: Any) {
        print("done")
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tagsView.cellForRow(at: indexPath) as! TagCell
        cell.checkImage.isHidden = false
        cell.checkImage.tintColor = UIColor.blue
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tags.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TagCell", for: indexPath) as! TagCell
        cell.tagName.text = "#" + tags[indexPath.row].tagName
        cell.checkImage.isHidden = true
        cell.tagImage.tintColor = UIColor.blue
    
        return cell
    }
}
