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
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(updateRefresh), for: .valueChanged)
        feedView.refreshControl = refreshControl
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        loadFeed()
    }
    
    @objc func updateRefresh(refreshControl: UIRefreshControl) {
        
        // load feed, calling API, refreshing table view and spinning loader
        loadFeed()
        refreshControl.endRefreshing()
        
        // todo: add functionality with flask instance
        WebServicesManager.testAlamofire()
    }
    
    func loadFeed() {
        print("loading feed")
        
        // start loading spinner
        let sv = UIViewController.displaySpinner(onView: self.view)
        
        // refresh table view
        self.feedView.reloadData()
        
        // remove spinner
        UIViewController.removeSpinner(spinner: sv)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // todo: get number of messages based on API call
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath) as! FeedViewCell
        
        // these fields would be returned from the WebServicesManager class
        cell.time.text = "_"
        cell.title.text = "_"
        cell.location.text = "_"

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
