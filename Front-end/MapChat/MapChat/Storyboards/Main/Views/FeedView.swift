//
//  FeedView.swift
//  MapChat
//
//  Created by Baily Troyer on 2/26/19.
//  Copyright © 2019 CSE442Group. All rights reserved.
//

import Foundation
import UIKit

class FeedView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var feedView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.title = "Feed"
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(updateRefresh), for: .valueChanged)
        feedView.refreshControl = refreshControl
    }
    
    @objc func updateRefresh(refreshControl: UIRefreshControl) {
        
        loadFeed()
        refreshControl.endRefreshing()
    }
    
    func loadFeed() {
        print("loading feed")
        
        let sv = UIViewController.displaySpinner(onView: self.view)
        UIViewController.removeSpinner(spinner: sv)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath) as! FeedViewCell

        cell.clipsToBounds = true

        return cell
    }
}

extension UIViewController {
    class func displaySpinner(onView : UIView) -> UIView {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        return spinnerView
    }
    
    class func removeSpinner(spinner :UIView) {
        DispatchQueue.main.async {
            spinner.removeFromSuperview()
        }
    }
}
