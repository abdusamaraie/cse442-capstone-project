//
//  SPageTwo.swift
//  MapChat
//
//  Created by Baily Troyer on 2/24/19.
//  Copyright © 2019 CSE442Group. All rights reserved.
//

import Foundation
import Lottie
import UIKit

class SPageTwo: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let title = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.maxX - self.view.frame.maxX/4, height: 100))
        //label.center = CGPoint(x: 160, y: 285)
        title.center.y = view.center.y + self.view.frame.maxY/9
        title.center.x = view.center.x
        
        title.textAlignment = .center
        title.text = "Interact with your surroundings like never before!"
        
        guard let customFont = UIFont(name: "AirbnbCerealApp-Medium", size: 20) else {
            fatalError("""
        Failed to load the "AirbnbCereal-Medium" font.
        Make sure the font file is included in the project and the font name is spelled correctly.
        """
            )
        }
        
        title.font = customFont
        title.numberOfLines = 2
        self.view.addSubview(title)
        
        // ------ body ------
        
        let body = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.maxX - self.view.frame.maxX/8, height: 100))
        //label.center = CGPoint(x: 160, y: 285)
        body.center.y = view.center.y + self.view.frame.maxY/5
        body.center.x = view.center.x
        
        body.textAlignment = .center
        body.text = "View messages, posts and pictures based on other people that have standed where you are right now!"
        
        guard let customBodyFont = UIFont(name: "AirbnbCerealApp-Light", size: 18) else {
            fatalError("""
        Failed to load the "AirbnbCereal-Medium" font.
        Make sure the font file is included in the project and the font name is spelled correctly.
        """
            )
        }
        
        body.font = customBodyFont
        body.numberOfLines = 3
        self.view.addSubview(body)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let animationView:AnimationView = AnimationView(name: "location_b") {
            animationView.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
            
            // label.center.y = view.center.y
            animationView.center.x = self.view.center.x
            animationView.center.y = self.view.center.y - self.view.frame.maxY/6
            animationView.contentMode = .scaleAspectFill
            
            self.view.addSubview(animationView)
            animationView.play()
            
            animationView.loopMode = .loop
        }
    }
    
}
