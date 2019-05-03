//
//  SignUpView.swift
//  MapChat
//
//  Created by Duncan Hall on 2/24/19.
//  Copyright © 2019 CSE442Group. All rights reserved.
//

import Foundation
import UIKit
import Lottie

class UsernameView: UIViewController {
    
    var input_elements:[AuthenticationHelper.input_element] = []
    
    @IBOutlet weak var username: UITextField!
    // @IBOutlet weak var display_name: UITextField!
    
    var sign_in_button: UIButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        input_elements.append(AuthenticationHelper.input_element(element_literal: username, element_name: "username"))
        
        username.addTarget(self, action: #selector(textFieldDidChange(_:)),
                           for: UIControl.Event.editingChanged)
        
        
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
        
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        textField.backgroundColor = nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        sign_in_button = UIButton(frame: CGRect(x: 0, y: (self.view.frame.maxY - self.view.frame.maxY/12), width: (self.view.frame.maxX - self.view.frame.maxX/6), height: 50))
        
        // button text "sign in"
        sign_in_button.setTitle("Continue", for: .normal)
        
        // add button target
        sign_in_button.addTarget(self, action: #selector(next_view), for: .touchUpInside)
        
        // button color white
        sign_in_button.backgroundColor = UIColor.white
        
        // center within view
        sign_in_button.center.x = self.view.frame.midX
        
        // round button
        sign_in_button.layer.cornerRadius = 10
        // button.layer.borderWidth = 1
        // button.layer.borderColor = UIColor.black.cgColor
        
        sign_in_button.setTitleColor(UIColor.gray, for: .normal)
        
        // add button to view
        self.view.addSubview(sign_in_button)
        
        sign_in_button.bindToKeyboard()
        self.username.becomeFirstResponder()
        
    }
    
    @objc func next_view() {
        
        if (AuthenticationHelper.check_input(input_elements: input_elements).count == 0) {
            print("good")
            AuthenticationHelper.sharedInstance.current_user.username = username.text!
            self.performSegue(withIdentifier: "to_password", sender: self)
        } else {
            // there are errors
            // get first element that cause issue
            //print("first element issue: \(AuthenticationHelper.check_input(input_elements: input_elements)[0])")
            print("ELEMENTS: \(AuthenticationHelper.check_input(input_elements: input_elements))")
            
            for element in AuthenticationHelper.check_input(input_elements: input_elements) {
                element.element_literal.backgroundColor = UIColor.red
                element.element_literal.alpha = 0.6
            }
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
