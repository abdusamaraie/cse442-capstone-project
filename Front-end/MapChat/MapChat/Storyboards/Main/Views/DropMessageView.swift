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
import Lottie

class DropMessageView: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var message: UITextField!
    
    var locManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locManager.delegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            
            print("Found user's location: \(location)")

            let urlString = "http://34.73.109.229:80/message"

            let parameters: [String: Any] = [
                "location": [
                    "latitude": location.coordinate.latitude,
                    "longitude": location.coordinate.longitude,
                ],
                "expireTime": "2019-03-11 22:59:45",
                "username": "baily",
                "message": message.text!
            ]
            
            print("JSON: \(parameters)")
            
//            Alamofire.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default)
//                .responseString { response in
//
//                    switch response.result {
//                        case .success:
//
//                            print("======SUCCESS=============\n")
//                            print("SUCCESS: \(response)")
//                            self.message.text = ""
//                            break
//                        case .failure(let error):
//
//                            print("=======ERROR============\n")
//                            print("ERROR: \(error)")
//                            self.message.text = ""
//                    }
//                    print("===========\n")
//                    print("RESPONSE: \(response)")
//            }

            Alamofire.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseString { response in

                switch response.result {
                    case .success:

                        print("======SUCCESS=============\n")
                        print("SUCCESS: \(response)")
                        self.message.text = ""
                        
                        if let animationView:LOTAnimationView = LOTAnimationView(name: "message-success") {
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
