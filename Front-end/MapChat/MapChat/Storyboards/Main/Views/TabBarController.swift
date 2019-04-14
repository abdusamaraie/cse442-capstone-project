//
//  TabBarController.swift
//  MapChat
//
//  Created by Baily Troyer on 4/14/19.
//  Copyright © 2019 CSE442Group. All rights reserved.
//

import Foundation
import UIKit

class TabBarController: UITabBarController , UIPopoverPresentationControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController is DropMessageView {
            
            print("selected drop message")
            return false
//            if let popupView = tabBarController.storyboard?.instantiateViewController(withIdentifier: "Popup") {
//                tabBarController.present(popupView, animated: true)
//                return false
//            }
//            return false
        }
        return true
    }
}
