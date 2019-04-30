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
import VSTwitterTextCounter

struct Place {
    var placeID: String
    var placeName: String
    var likelihood: String
}

class DropMessageView: UIViewController, CLLocationManagerDelegate, UITextViewDelegate, UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    
    @IBOutlet weak var message: UITextView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var counterView: VSTwitterTextCounter!
    
    let animationView = AnimationView(name: "waiting")
    var locManager = CLLocationManager()
    
    var placesClient: GMSPlacesClient!
    var places: [Place] = []
    var dropMessage: Bool = false
    
    var selectedPlace: Place!
    var placesView: UICollectionView!
    var currentLocation:CLLocation!
    var selectedTag:Tag!
    var lengthLabel: UILabel!
    
    var postTime:Int!
    
    let dateFormatterGet = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // update date format for cacheMessage
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        locManager.delegate = self
        
        placesClient = GMSPlacesClient.shared()
        
        self.message.delegate = self
        
        locManager.distanceFilter = 10
        
        // place holder for text view
        message.text = "Enter a message"
        message.textColor = UIColor.lightGray
        
        message.selectedTextRange = message.textRange(from: message.beginningOfDocument, to: message.beginningOfDocument)
        
        //message.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 2, right: 10)
        
        // collection view
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        
        self.placesView = UICollectionView(frame: CGRect(x: 0, y: (self.view.frame.maxY - self.view.frame.maxY/8), width: view.frame.width, height: 80), collectionViewLayout: flowLayout)

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
        
        // keyboard toolbar
        let toolbar = UIToolbar(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        toolbar.barStyle = .default
        
        let tagItem = UIBarButtonItem(title: "Tags", style: .plain, target: self, action: #selector(tags))
        tagItem.image = #imageLiteral(resourceName: "round_more_horiz_black_48pt")
        
        let timeItem = UIBarButtonItem(title: "Time", style: .plain, target: self, action: #selector(setTime))
        timeItem.image = #imageLiteral(resourceName: "timer")
        
        // slider
        
        // let mySlider = UISlider(x: 0, y: 0, width: UIScreen.main.bounds.width/4, height: 50)
        let mySlider = UISlider(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width/2, height: 50))
        mySlider.minimumValue = 1
        mySlider.maximumValue = 4.003461
        mySlider.setValue(1.778, animated: false)
        self.postTime = Int(powf(10.0, 1.778))
        mySlider.isContinuous = true
        mySlider.tintColor = UIColor.blue
        mySlider.addTarget(self, action: #selector(DropMessageView.changeVlaue(_:)), for: .valueChanged)
        
        let sliderItem = UIBarButtonItem(customView: mySlider)
        
        // --> mySlider.addTarget(self, action: #selector(slide), for: .valueChanged)
        //
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let timeLabel = UILabel()
        timeLabel.text = "----"
        let labelBarButton = UIBarButtonItem(customView: timeLabel)
        
        // length label
        self.lengthLabel = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width/4, height: 50))
        self.lengthLabel.text = "1h"
        let labelBarButton1 = UIBarButtonItem(customView: self.lengthLabel)
        
        toolbar.items = [timeItem, sliderItem, labelBarButton1, spacer, labelBarButton, tagItem]
        toolbar.sizeToFit()
        message.inputAccessoryView = toolbar

        
        self.counterView.maxCount = 120
    }
    
    @objc func changeVlaue(_ sender: UISlider) {
        let logTime = Int(powf(10.0, sender.value))
        print("====sender====: \(logTime)")
        
        // self.lengthLabel.text = "\(Int(sender.value))"
        let tuple = minutesToHoursMinutes(minutes: logTime)
        let dayTuple = minutesToDaysHours(minutes: logTime)
        
        self.postTime = logTime
        
        if (logTime >= 60 && logTime < 1440) {
            self.lengthLabel.text = " \(tuple.hours)h\(tuple.leftMinutes)m"
        } else if (logTime >= 1440){
            self.lengthLabel.text = " \(dayTuple.days)d\(dayTuple.hours)h"
        } else {
            self.lengthLabel.text = " \(logTime)m"
        }
        
    }
    
    func minutesToHoursMinutes (minutes : Int) -> (hours : Int , leftMinutes : Int) {
        return (minutes / 60, (minutes % 60))
    }
    
    func minutesToDaysHours (minutes : Int) -> (days: Int, hours: Int){
        return (minutes / 1440, ((minutes / 60) % 24))
    }
    
    @objc func tags() {
        print("show tags")
        self.performSegue(withIdentifier: "viewTags", sender: self)
    }
    
    @objc func setTime() {
        print("set time")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.message.becomeFirstResponder()
        getPlace()
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
        
        // cell.PlaceName.text = places[indexPath.row].placeName
        // cell.PlaceName.text = "THIS IS A TEST"
        cell.PlaceName.text = places[indexPath.row].placeName
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.item)!")

        // update UI
        let cell = placesView.cellForItem(at: indexPath)
        cell?.layer.borderWidth = 1.0
        cell?.layer.borderColor = UIColor.gray.cgColor
        
        // update selected group object
        self.selectedPlace = places[indexPath.row]
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView){

        
        let allCells = scrollView as! UICollectionView
        let visibleCells = allCells.visibleCells
        for cell in visibleCells{
            let realCenter = scrollView.convert(CGPoint(x: cell.frame.minX, y: cell.frame.midY), to: scrollView.superview)
            let distFromLeft = self.view.frame.minX + realCenter.x
            if(distFromLeft > 10){
                let s = 10/distFromLeft
                //let s = -0.00005 * pow(realCenter.x, 2) + 1.5
                cell.transform = CGAffineTransform.init(scaleX: s, y: s)
                let pCell = cell as! PlaceCollectionCell
                pCell.PlaceName.text = "\(s)"
            }
        }
    }
    
    func cacheMessage() {
        
        print("inside cache message")
        
        let this = placesView.indexPathsForSelectedItems?.first?.row
        print("THIS: \(this!)")
        if (this != nil) {
            print("this: \(this!)")
            
            let selectedPlaceID = places[this!].placeID
            
            if (selectedPlaceID != "") {
                
                let urlString = "http://35.238.74.200:80/message"
                
                // get current date adding the slider effect
                let date = Calendar.current.date(byAdding: .minute, value: Int(postTime), to: Date())
                
                let parameters: [String: Any] = [
                    "location": [
                        "latitude": currentLocation.coordinate.latitude,
                        "longitude": currentLocation.coordinate.longitude,
                    ],
                    "expireTime": dateFormatterGet.string(from: date!),
                    "username": AuthenticationHelper.sharedInstance.current_user.username!,
                    "message": message.text!,
                    "placeId": selectedPlaceID
                ]
                
                print("placeID: \(selectedPlaceID)")
                
                if (self.dropMessage) {
                    print("=====drop message is true=====")
                    self.dropMessage = false
                    
                    Alamofire.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseString { response in
                        
                        switch response.result {
                        case .success:
                            
                            self.message.text = ""
                            
                            let animationView:AnimationView = AnimationView(name: "message-success")
                            animationView.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
                            
                            animationView.center.x = self.view.center.x
                            animationView.center.y = self.view.center.y - self.view.frame.maxY/5
                            // animationView.center = self.view.center
                            animationView.contentMode = .scaleAspectFill
                            self.view.addSubview(animationView)
                            animationView.play{ (finished) in
                                animationView.removeFromSuperview()
                                print("going back")
                                self.dismiss(animated: true, completion: nil)
                            }
                            
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
                    if(likelihood.likelihood < maxLikelihood * 0.2){
                        break
                    }
                    else{
                        //print("Name: \(String(describing: place.name))! Likelihood: \(likelihood.likelihood)")
                        //print("Lat: \(place.coordinate.latitude) Lng: \(place.coordinate.longitude)")
                        
                        self.places.append(Place(placeID: place.placeID!, placeName: place.name!, likelihood: "\(likelihood.likelihood)"))
                    }
                }
            }
            
            self.places.append(Place(placeID: "Other", placeName: "* Nowhere in particular *", likelihood: "-1"))
            
            print("reloading data")
            self.placesView.reloadData()

            self.startGettingLocation()
        })
        
        
    }
    
    func startGettingLocation() {
        locManager.requestWhenInUseAuthorization()
        if((CLLocationManager.authorizationStatus() == .authorizedWhenInUse) || (CLLocationManager.authorizationStatus() ==  .authorizedAlways)) {
            locManager.startUpdatingLocation()
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        print("going back")
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cache(_ sender: Any) {
        if (message.text != "" && selectedPlace != nil) {
            print("message text: \(message.text!)")
            // message.resignFirstResponder()
            self.dropMessage = true
            self.cacheMessage()
        } else {
            print("didn't select place")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        print("inside location manager!")
        
        if let location = locations.first {

            self.currentLocation = location
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        // Combine the textView text and the replacement text to
        // create the updated text string
        let currentText:String = textView.text
        
        if (currentText.count > 120) {
            return false
        }
        
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
            print("hey")
            let weightedLength = NSString(string: textView.text).length
            counterView.update(with: textView, textWeightedLength: weightedLength)
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
    
    // text field changes
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if(string == "\n") {
            textField.resignFirstResponder()
            return false
        }
        return true
    }
    
    func animate() {
        animationView.frame = containerView.bounds
        animationView.contentMode = .scaleAspectFill
        animationView.animationSpeed = 1
        self.containerView.addSubview(animationView)
        animationView.play()
        animationView.loopMode = .loop
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
