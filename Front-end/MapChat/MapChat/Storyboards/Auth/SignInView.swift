//
//  SignInView.swift
//  MapChat
//
//  Created by Duncan Hall on 2/24/19.
//  Copyright © 2019 CSE442Group. All rights reserved.
//

import Foundation
import UIKit

class SignInView: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        print("HERE")
        
    }
     override func viewDidAppear(_ animated: Bool) {
        let back_button = UIButton(frame: CGRect(x: 0, y: (self.view.frame.maxY - self.view.frame.maxY/5), width: (self.view.frame.maxX - self.view.frame.maxX/4), height: 50))
        
        
        back_button.setTitle("Back", for: .normal)
    }
}
