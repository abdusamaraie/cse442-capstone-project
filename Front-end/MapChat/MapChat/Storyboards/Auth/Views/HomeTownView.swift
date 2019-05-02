//
//  HomeTownView.swift
//  MapChat
//
//  Created by Baily Troyer on 4/27/19.
//  Copyright © 2019 CSE442Group. All rights reserved.
//

import Foundation
import GooglePlaces
import UIKit

class HomeTownView: UIViewController {
    
    var next_button: UIButton = UIButton()
    
    @IBOutlet weak var homeTownField: UITextField!
    var viewedHomeTown:Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewedHomeTown = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if (viewedHomeTown != true) {
            viewedHomeTown = true
            let placePickerController = GMSAutocompleteViewController()
            placePickerController.delegate = self
            present(placePickerController, animated: true, completion: nil)
        }
        
        next_button = UIButton(frame: CGRect(x: 0, y: (self.view.frame.maxY - self.view.frame.maxY/12), width: (self.view.frame.maxX - self.view.frame.maxX/6), height: 50))
        
        // button text "sign in"
        next_button.setTitle("Continue", for: .normal)
        
        // add button target
        next_button.addTarget(self, action: #selector(next_view), for: .touchUpInside)
        
        // button color white
        next_button.backgroundColor = UIColor.white
        
        // center within view
        next_button.center.x = self.view.frame.midX
        
        // round button
        next_button.layer.cornerRadius = 10
        // button.layer.borderWidth = 1
        // button.layer.borderColor = UIColor.black.cgColor
        
        next_button.setTitleColor(UIColor.gray, for: .normal)
        
        // add button to view
        self.view.addSubview(next_button)
        
    }
    
    @objc func next_view() {
        if (homeTownField.text != "") {
            AuthenticationHelper.sharedInstance.current_user.homeTown = "\(homeTownField.text!)"
            self.performSegue(withIdentifier: "to_username", sender: self)
        }
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension HomeTownView: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
//        print("Place name: \(place.name)")
//        print("Place address: \(place.formattedAddress)")
//        print("Place attributions: \(place.attributions)")
        
        homeTownField.text = "\(place.formattedAddress!)"
        homeTownField.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}
