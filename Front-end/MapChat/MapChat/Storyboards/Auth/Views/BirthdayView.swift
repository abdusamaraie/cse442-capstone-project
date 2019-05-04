//
//  BirthdayView.swift
//  MapChat
//
//  Created by Baily Troyer on 4/27/19.
//  Copyright © 2019 CSE442Group. All rights reserved.
//

import Foundation
import Lottie
import UIKit

class BirthdayView: UIViewController {

    @IBOutlet weak var birthdayField: UITextField!
    
    var next_button: UIButton = UIButton()
    let datePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let animationView:AnimationView = AnimationView(name: "cachr_white_full") {
            animationView.frame = CGRect(x: 0, y: 0, width: 480, height: 48)
            
            // label.center.y = view.center.y
            animationView.center.x = self.view.center.x
            animationView.center.y = self.view.frame.height/8
            animationView.contentMode = .scaleAspectFill
            animationView.loopMode = LottieLoopMode.loop
            
            self.view.addSubview(animationView)
            
            animationView.play()
        }
        
        showDatePicker()
    }
    
    func showDatePicker(){
        //Formate Date
        datePicker.datePickerMode = .date
        
        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
        
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        
        birthdayField.inputAccessoryView = toolbar
        birthdayField.inputView = datePicker
        
    }
    
    @objc func donedatePicker(){
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        birthdayField.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    @objc func cancelDatePicker(){
        self.view.endEditing(true)
    }

    
    override func viewDidAppear(_ animated: Bool) {
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
        
        next_button.bindToKeyboard()
        
        self.birthdayField.becomeFirstResponder()
        
    }
    
    @objc func next_view() {
        if birthdayField.text != "" {
            print("brithday: \(birthdayField.text!)")
            AuthenticationHelper.sharedInstance.current_user.birthday = "\(birthdayField.text!)"
            self.performSegue(withIdentifier: "to_location", sender: self)
        } else {
            birthdayField.backgroundColor = UIColor.red
            birthdayField.alpha = 0.8
        }
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
