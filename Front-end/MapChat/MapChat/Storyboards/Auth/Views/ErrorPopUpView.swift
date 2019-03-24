//
//  ErrorPopUpView.swift
//  MapChat
//
//  Created by Baily Troyer on 3/24/19.
//  Copyright © 2019 CSE442Group. All rights reserved.
//

import Foundation
import UIKit

class ErrorPopUpView: UIViewController {
    
    @IBOutlet weak var itemsMissing: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.itemsMissing.text = "1. Password"
    }
    
    @IBAction func okay(_ sender: Any) {
        dismiss(animated: true)
    }
    
}
