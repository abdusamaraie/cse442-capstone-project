//
//  loadView.swift
//  MapChat
//
//  Created by Baily Troyer on 4/19/19.
//  Copyright © 2019 CSE442Group. All rights reserved.
//

import Foundation
import UIKit
import Lottie

class LoadView: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if let animationView:AnimationView = AnimationView(name: "cachr_white_half") {
            animationView.frame = CGRect(x: 0, y: 0, width: 1000, height: 110)
            
            // label.center.y = view.center.y
            animationView.center.x = self.view.center.x
            animationView.center.y = self.view.center.y
            animationView.contentMode = .scaleAspectFill
            
            self.view.addSubview(animationView)
            
            animationView.play { (finished) in
                self.performSegue(withIdentifier: "to_splash", sender: self)
            }
        }
    }
}
