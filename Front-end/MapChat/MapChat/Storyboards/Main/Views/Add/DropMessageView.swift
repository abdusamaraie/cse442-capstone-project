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

class DropMessageView: UIViewController, CLLocationManagerDelegate, UITextViewDelegate, UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
    
    @IBOutlet weak var message: UITextView!
    // @IBOutlet weak var placesView: UICollectionView!
    @IBOutlet weak var containerView: UIView!
    
    let animationView = AnimationView(name: "waiting")
    var locManager = CLLocationManager()
    
    var placesClient: GMSPlacesClient!
    var places: [Place] = []
    var dropMessage: Bool = false
    
    var placesView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        locManager.delegate = self
        
        placesClient = GMSPlacesClient.shared()
        
        self.message.delegate = self
        
        locManager.distanceFilter = 10
        
        // place holder for text view
        message.text = "Enter a message"
        message.textColor = UIColor.lightGray
        
        message.becomeFirstResponder()
        
        message.selectedTextRange = message.textRange(from: message.beginningOfDocument, to: message.beginningOfDocument)
        
        message.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 2, right: 10)
        
        // collection view
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        
        self.placesView = UICollectionView(frame: CGRect(x: 0, y: (self.view.frame.maxY - self.view.frame.maxY/8), width: view.frame.width, height: 100), collectionViewLayout: flowLayout)

        placesView.delegate = self
        placesView.dataSource = self
        
        self.placesView.register(UINib(nibName: "PlaceCellNib", bundle: nil), forCellWithReuseIdentifier: "PlaceCellObject")
        // placesView.register(PlaceCollectionCell.self, forCellWithReuseIdentifier: "PlaceCell")
        placesView.showsVerticalScrollIndicator = false
        placesView.showsHorizontalScrollIndicator = false
        placesView.backgroundColor = UIColor.clear
        // placesView.backgroundColor = UIColor.cyan
        self.view.addSubview(placesView)
        placesView.bindToKeyboard()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getPlace()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // getPlace()
        // placesView.reloadData()
        animate()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.places.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("adding collection cell")
        //let cell = placesView.dequeueReusableCell(withReuseIdentifier: "PlaceCell", for: indexPath) as! PlaceCollectionCell
        
        let cell:PlaceCollectionCell = placesView.dequeueReusableCell(withReuseIdentifier: "PlaceCellObject", for: indexPath) as! PlaceCollectionCell
        
        print("indexPath row: \(indexPath.row)")
        
        cell.PlaceName.text = places[indexPath.row].placeName
        // cell.PlaceName.text = "THIS IS A TEST"
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")

        let cell = placesView.cellForItem(at: indexPath)
        cell?.layer.borderWidth = 1.0
        cell?.layer.borderColor = UIColor.gray.cgColor
    }
    
    func getPlace() {
        print("inside get place")
        // Specify the place data types to return.
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
            UInt(GMSPlaceField.placeID.rawValue) | UInt(GMSPlaceField.coordinate.rawValue))!
        placesClient?.findPlaceLikelihoodsFromCurrentLocation(withPlaceFields: fields, callback: {
            (placeLikelihoodList: Array<GMSPlaceLikelihood>?, error: Error?) in
            if let error = error {
                print("An error occurred: \(error.localizedDescription)")
                return
            }
            
            self.places = []
            var maxLikelihood = 0.0
            
            if let placeLikelihoodList = placeLikelihoodList {
                
                //first item has the highest likelihood
                if(!placeLikelihoodList.isEmpty){
                    maxLikelihood = placeLikelihoodList[0].likelihood
                }
                
                for likelihood in placeLikelihoodList {
                    
                    //the places API returns a likelihood of 100% on many results if you arent near anything.
                    //i.e. Buffalo: 1.0, Erie County: 1.0, New York: 1.0
                    //if the Places list only has 1 item, we return it, otherwise return nothing.
                    if(likelihood.likelihood == 1.0 && placeLikelihoodList.count > 1){
                        break
                    }
                    
                    let place = likelihood.place
                    
                    print("Name: \(String(describing: place.name))! Likelihood: \(likelihood.likelihood)")
                    print("Lat: \(place.coordinate.latitude) Lng: \(place.coordinate.longitude)")
                    
                    GroupPostManager.sharedInstance.placeId = place.placeID!
                    
                    //if the current place's likelihood is less than 70% of the most likely place, skip the rest
                    if(likelihood.likelihood < maxLikelihood * 0.70){
                        break
                    }
                    else{
                        //print("Name: \(String(describing: place.name))! Likelihood: \(likelihood.likelihood)")
                        //print("Lat: \(place.coordinate.latitude) Lng: \(place.coordinate.longitude)")
                        
                        self.places.append(Place(placeID: place.placeID!, placeName: place.name!, likelihood: "\(likelihood.likelihood)"))
                    }
                }
            }
            
            self.places.append(Place(placeID: "Other", placeName: "Other", likelihood: "-1"))
            
            print("reloading data")
            self.placesView.reloadData()
            // self.messageLocation.reloadAllComponents()
            self.startGettingLocation()
        })
        
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        // Combine the textView text and the replacement text to
        // create the updated text string
        let currentText:String = textView.text
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: text)
        
        // If updated text view will be empty, add the placeholder
        // and set the cursor to the beginning of the text view
        if updatedText.isEmpty {
            
            textView.text = "Placeholder"
            textView.textColor = UIColor.lightGray
            
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
        }
            
            // Else if the text view's placeholder is showing and the
            // length of the replacement string is greater than 0, set
            // the text color to black then set its text to the
            // replacement string
        else if textView.textColor == UIColor.lightGray && !text.isEmpty {
            textView.textColor = UIColor.black
            textView.text = text
        }
            
            // For every other case, the text should change with the usual
            // behavior...
        else {
            return true
        }
        
        // ...otherwise return false since the updates have already
        // been made
        return false
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if self.view.window != nil {
            if textView.textColor == UIColor.lightGray {
                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            }
        }
    }
    
    func animate() {
        animationView.frame = containerView.bounds
        animationView.contentMode = .scaleAspectFill
        animationView.animationSpeed = 0.5
        self.containerView.addSubview(animationView)
        animationView.play()
        animationView.loopMode = .loop
    }
    
    @IBAction func cancel(_ sender: Any) {
        print("going back")
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cache(_ sender: Any) {
//        if (message.text != "") {
//            print("message text: \(message.text)")
//            message.resignFirstResponder()
//            self.dropMessage = true
//        }
    }
    
    // text field changes
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if(string == "\n") {
            textField.resignFirstResponder()
            return false
        }
        return true
    }

    func startGettingLocation() {
        locManager.requestWhenInUseAuthorization()
        if((CLLocationManager.authorizationStatus() == .authorizedWhenInUse) || (CLLocationManager.authorizationStatus() ==  .authorizedAlways)) {
            print("starting to update LOCATION")
            locManager.startUpdatingLocation()
        }
    }
    // -------------------------------------------
    
//    func getPlace() {
//        // Specify the place data types to return.
//        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
//            UInt(GMSPlaceField.placeID.rawValue))!
//        placesClient?.findPlaceLikelihoodsFromCurrentLocation(withPlaceFields: fields, callback: {
//            (placeLikelihoodList: Array<GMSPlaceLikelihood>?, error: Error?) in
//            if let error = error {
//                print("An error occurred: \(error.localizedDescription)")
//                return
//            }
//
//            self.places = []
//
//            if let placeLikelihoodList = placeLikelihoodList {
//                for likelihood in placeLikelihoodList {
//                    let place = likelihood.place
//
//                    GroupPostManager.sharedInstance.placeId = place.placeID!
//
//                    GroupPostManager.sharedInstance.placeDistance(completion: {(response) in
//                        if (response > 0 && response < 200) {
//                            self.places.append(Place(placeID: place.placeID!, placeName: place.name!, likelihood: "\(likelihood.likelihood)"))
//                        }
//                        //self.placesView.reloadData()
//                    })
//                }
//            }
//
//            self.places.append(Place(placeID: "-1", placeName: "Other", likelihood: "-1"))
//
//            //self.placesView.reloadData()
//            self.startGettingLocation()
//        })
//
//    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        if let location = locations.first {

            // let selectedPlaceID = places[placesView.selectedRow(inComponent: 0)].placeID

            //print("index paths for selected items: \(placesView.indexPathsForSelectedItems!)")

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

}


extension UIViewController {
    func performSegueToReturnBack()  {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
