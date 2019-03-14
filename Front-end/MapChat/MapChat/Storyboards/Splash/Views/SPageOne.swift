//
//  SPageOne.swift
//  MapChat
//
//  Created by Baily Troyer on 2/24/19.
//  Copyright © 2019 CSE442Group. All rights reserved.
//

import Foundation
import Lottie
import UIKit

class SPageOne: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let animationView:LOTAnimationView = LOTAnimationView(name: "location_b") {
            animationView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
            
            animationView.center = self.view.center
            animationView.contentMode = .scaleAspectFill
            
            self.view.addSubview(animationView)
            animationView.play()
            animationView.loopAnimation = true
            
//            animationView.play{ (finished) in
//                print("removing from view")
//                animationView.removeFromSuperview()
//            }
        }
        
    }
}
