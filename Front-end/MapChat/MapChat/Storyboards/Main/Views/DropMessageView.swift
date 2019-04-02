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

class DropMessageView: UIViewController, CLLocationManagerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate, UITextFieldDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.places.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.places[row].placeName
    }
    
    
    @IBOutlet weak var message: UITextView!
    @IBOutlet weak var messageTitle: UITextField!
    @IBOutlet weak var messageLocation: UIPickerView!
    
    var locManager = CLLocationManager()
    
    var placesClient: GMSPlacesClient!
    var places: [Place] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locManager.delegate = self
        
        placesClient = GMSPlacesClient.shared()
        
        self.messageLocation.delegate = self
        self.messageLocation.dataSource = self
        
        self.message.delegate = self
        self.messageTitle.delegate = self
    }
    
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
            
            if let placeLikelihoodList = placeLikelihoodList {
                for likelihood in placeLikelihoodList {
                    let place = likelihood.place
                    self.places.append(Place(placeID: place.placeID!, placeName: place.name!, likelihood: "\(likelihood.likelihood)"))
                    print("Current Place name \(String(describing: place.name)) at likelihood \(likelihood.likelihood)")
                    print("Current PlaceID \(String(describing: place.placeID))")
                }
            }
            
            self.places.append(Place(placeID: "-1", placeName: "Other", likelihood: "-1"))
            
            print("update pickerview")
            self.messageLocation.reloadAllComponents()
        })
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getPlace()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            
            let selectedPlaceID = places[messageLocation.selectedRow(inComponent: 0)].placeID
            
            if (selectedPlaceID != "") {
                
                print("Found user's location: \(location)")
                
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
                
                //            {
                //                "username": "daru",
                //                "location": {"latitude": 32.06541, "longitude": 71.674351},
                //                "message": "This is a test post",
                //                "expireTime": "2019-04-01 20:34:02-04:00"
                //                "placeId": "NFjbf534Jflje5_t4iT"
                //            }
                
                print("JSON: \(parameters)")
                
                Alamofire.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseString { response in
                    
                    switch response.result {
                    case .success:
                        
                        print("======RESPONSE=============\n")
                        print("resp res val: \(response.result.value!)")
                        self.message.text = ""
                        
                        
                        if let animationView:AnimationView = AnimationView(name: "message-success") {
                            animationView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
                            animationView.center = self.view.center
                            animationView.contentMode = .scaleAspectFill
                            
                            self.view.addSubview(animationView)
                            
                            animationView.play{ (finished) in
                                print("removing from view")
                                animationView.removeFromSuperview()
                            }
                        }
                        
                        break
                        
                    //=========
                    case .failure(let error):
                        
                        print("=======ERROR============\n")
                        print("ERROR: \(error)")
                        self.message.text = ""
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
            locManager.requestWhenInUseAuthorization()
            if((CLLocationManager.authorizationStatus() == .authorizedWhenInUse) || (CLLocationManager.authorizationStatus() ==  .authorizedAlways)) {
                locManager.requestLocation()
            }
        }
    }
}
