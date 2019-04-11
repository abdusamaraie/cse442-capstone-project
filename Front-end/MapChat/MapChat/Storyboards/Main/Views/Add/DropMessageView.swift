//
//  DropMessageView.swift
//  MapChat
//
//  Created by Baily Troyer on 3/5/19.
//  Copyright © 2019 CSE442Group. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation
import Alamofire
import UIKit
import GooglePlaces
import Lottie

struct Place {
    var placeID: String
    var placeName: String
    var likelihood: String
}

class DropMessageView: UIViewController, CLLocationManagerDelegate, UITextViewDelegate, UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var message: UITextView!
    @IBOutlet weak var placesView: UICollectionView!
    
    var locManager = CLLocationManager()
    
    var placesClient: GMSPlacesClient!
    var places: [Place] = []
    var dropMessage: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locManager.delegate = self
        
        placesView.delegate = self
        placesView.dataSource = self
        
        placesClient = GMSPlacesClient.shared()
        
        self.message.delegate = self
        
        locManager.distanceFilter = 10
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.message.becomeFirstResponder()
        getPlace()
    }
    
    //
    
    // -------------------------------------------
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.places.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlaceCell", for: indexPath as IndexPath) as! PlaceCollectionCell
        
        cell.PlaceName.text = self.places[indexPath.row].placeName
        
        //cell.myLabel.text = self.items[indexPath.item]
        //cell.backgroundColor = UIColor.cyan // make cell more visible in our example project
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate protocol
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")
    }
    
    
    
    // collection view
    
    // -------------------------------------------
    
    // text field changes
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if(string == "\n") {
            textField.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    // text field changes
    
    // -------------------------------------------
    
    func getPlace() {
        // Specify the place data types to return.
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
            UInt(GMSPlaceField.placeID.rawValue))!
        placesClient?.findPlaceLikelihoodsFromCurrentLocation(withPlaceFields: fields, callback: {
            (placeLikelihoodList: Array<GMSPlaceLikelihood>?, error: Error?) in
            if let error = error {
                print("An error occurred: \(error.localizedDescription)")
                return
            }
            
            self.places = []
            
            if let placeLikelihoodList = placeLikelihoodList {
                for likelihood in placeLikelihoodList {
                    let place = likelihood.place
                    
                    GroupPostManager.sharedInstance.placeId = place.placeID!

                    GroupPostManager.sharedInstance.placeDistance(completion: {(response) in
                        if (response > 0 && response < 200) {
                            self.places.append(Place(placeID: place.placeID!, placeName: place.name!, likelihood: "\(likelihood.likelihood)"))
                        }
                        self.placesView.reloadData()
                        // self.messageLocation.reloadAllComponents()
                    })
                }
            }

            self.places.append(Place(placeID: "-1", placeName: "Other", likelihood: "-1"))

            self.placesView.reloadData()
            // self.messageLocation.reloadAllComponents()
            self.startGettingLocation()
        })
        
    }
    
    
    func startGettingLocation() {
        locManager.requestWhenInUseAuthorization()
        if((CLLocationManager.authorizationStatus() == .authorizedWhenInUse) || (CLLocationManager.authorizationStatus() ==  .authorizedAlways)) {
            locManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.first {
            
            // let selectedPlaceID = places[placesView.selectedRow(inComponent: 0)].placeID
            
            print("index paths for selected items: \(placesView.indexPathsForSelectedItems!)")
            
            let this = placesView.indexPathsForSelectedItems?.first?.row
            
            if (this != nil) {
                print("this: \(this!)")
                
                let selectedPlaceID = places[this!].placeID
                
                if (selectedPlaceID != "") {
                    
                    let urlString = "http://34.73.109.229:80/message"
                    
                    let parameters: [String: Any] = [
                        "location": [
                            "latitude": location.coordinate.latitude,
                            "longitude": location.coordinate.longitude,
                        ],
                        "expireTime": "2019-04-20 22:59:45",
                        "username": AuthenticationHelper.sharedInstance.current_user.username!,
                        "message": message.text!,
                        "placeId": selectedPlaceID
                    ]
                    
                    if (self.dropMessage) {
                        self.dropMessage = false
                        
                        Alamofire.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseString { response in
                            
                            switch response.result {
                            case .success:
                                
                                self.message.text = ""
                                
                                let animationView:AnimationView = AnimationView(name: "message-success")
                                animationView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
                                animationView.center = self.view.center
                                animationView.contentMode = .scaleAspectFill
                                self.view.addSubview(animationView)
                                animationView.play{ (finished) in animationView.removeFromSuperview() }
                                
                            // break
                            case .failure(let error):
                                print("error: \(error)")
                                self.message.text = ""
                            }
                        }
                    }
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    @IBAction func dropMessage(_ sender: Any) {
        
        if (message.text != "") {
            message.resignFirstResponder()
            self.dropMessage = true
        }
    }
}
