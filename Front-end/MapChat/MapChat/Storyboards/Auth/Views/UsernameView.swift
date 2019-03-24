//
//  SignUpView.swift
//  MapChat
//
//  Created by Duncan Hall on 2/24/19.
//  Copyright © 2019 CSE442Group. All rights reserved.
//

import Foundation
import UIKit

class UsernameView: UIViewController {
    
    var input_elements:[AuthenticationHelper.input_element] = []
    
    @IBOutlet weak var username: UITextField!
    // @IBOutlet weak var display_name: UITextField!
    
    var sign_in_button: UIButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        input_elements.append(AuthenticationHelper.input_element(element_literal: username, element_name: "username"))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        sign_in_button = UIButton(frame: CGRect(x: 0, y: (self.view.frame.maxY - self.view.frame.maxY/12), width: (self.view.frame.maxX - self.view.frame.maxX/6), height: 50))
        
        // button text "sign in"
        sign_in_button.setTitle("Continue", for: .normal)
        
        // add button target
        sign_in_button.addTarget(self, action: #selector(next_view), for: .touchUpInside)
        
        // button color white
        sign_in_button.backgroundColor = UIColor.blue
        
        // center within view
        sign_in_button.center.x = self.view.frame.midX
        
        // round button
        sign_in_button.layer.cornerRadius = 10
        // button.layer.borderWidth = 1
        // button.layer.borderColor = UIColor.black.cgColor
        
        // add button to view
        self.view.addSubview(sign_in_button)
        
        sign_in_button.bindToKeyboard()
        self.username.becomeFirstResponder()
    }
    
    @objc func next_view() {
        
        if (AuthenticationHelper.check_input(input_elements: input_elements).count == 0) {
            print("good")
            AuthenticationHelper.sharedInstance.current_user.username = username.text!
            self.performSegue(withIdentifier: "to_name", sender: self)
        } else {
            // there are errors
            // get first element that cause issue
            print("first element issue: \(AuthenticationHelper.check_input(input_elements: input_elements)[0])")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //self.username.endEditing(true)
        self.username.resignFirstResponder()
    }

    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}


extension UIView {
    func bindToKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func keyboardWillChange(_ notification: NSNotification) {
        let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        let curve = notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt
        let begginingFrame = (notification.userInfo![UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let endFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let deltaY = endFrame.origin.y - begginingFrame.origin.y
        
        UIView.animateKeyframes(withDuration: duration, delay: 0.0, options: UIView.KeyframeAnimationOptions(rawValue: curve), animations: {
            self.frame.origin.y += deltaY
        }, completion: nil)
    }
}


class SegueFromLeft: UIStoryboardSegue
{
    override func perform(){
        
        let src = self.source
        let dst = self.destination
        
        src.view.superview?.insertSubview(dst.view, aboveSubview: src.view)
        dst.view.transform = CGAffineTransform(translationX: -src.view.frame.size.width, y: 0)
        
        UIView.animate(withDuration: 0.25,
                       delay: 0.0,
                       options: UIView.AnimationOptions.curveEaseInOut,
                       animations: {
                        dst.view.transform = CGAffineTransform(translationX: 0, y: 0)
        },
                       completion: { finished in
                        src.present(dst, animated: false, completion: nil)
        })
    }
}

class SegueFromRight: UIStoryboardSegue {
    override func perform() {
        let src = self.source
        let dst = self.destination
        
        src.view.superview?.insertSubview(dst.view, aboveSubview: src.view)
        dst.view.transform = CGAffineTransform(translationX: src.view.frame.size.width*2, y: 0) //Double the X-Axis
        UIView.animate(withDuration: 0.25, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            dst.view.transform = CGAffineTransform(translationX: 0, y: 0)
        }) { (finished) in
            src.present(dst, animated: false, completion: nil)
        }
    }
}
