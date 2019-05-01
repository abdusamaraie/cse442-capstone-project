//
//  PageViewController.swift
//  MapChat
//
//  Created by Baily Troyer on 2/24/19.
//  Copyright © 2019 CSE442Group. All rights reserved.
//

import Foundation
import UIKit

class PageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    var pageControl = UIPageControl()
    var sign_in_button = UIButton()
    var sign_up_button = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("test")
        
        self.dataSource = self
        self.delegate = self
        
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
        
        configurePageControl()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // button frame (X,Y,width, height)
        sign_in_button = UIButton(frame: CGRect(x: 0, y: (self.view.frame.maxY - self.view.frame.maxY/6), width: (self.view.frame.maxX - self.view.frame.maxX/4), height: 40))
        
        // button text "sign in"
        sign_in_button.setTitle("Sign in", for: .normal)
        sign_in_button.setTitleColor(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1), for: .normal)
        
        // add button target
        sign_in_button.addTarget(self, action: #selector(sign_in), for: .touchUpInside)
        
        // button color white
        sign_in_button.backgroundColor = UIColor.white
        
        // rounded
        sign_in_button.layer.cornerRadius = 10
        
        // center within view
        sign_in_button.center.x = self.view.frame.midX
        
        sign_in_button.addTarget(self, action: #selector(sign_in), for: .touchUpInside)
        
        //set alpha for fade-in animation
        sign_in_button.alpha = 0.0
        
        // add button to view
        self.view.addSubview(sign_in_button)
        
        //do fade-in animation
        UIView.animate(withDuration: 0.8, animations: {
            self.sign_in_button.alpha = 1.0
        })
        
        // button frame (X,Y,width, height)
        sign_up_button = UIButton(frame: CGRect(x: 0, y: (self.view.frame.maxY - self.view.frame.maxY/6) + self.view.frame.maxY/16, width: (self.view.frame.maxX - self.view.frame.maxX/4), height: 40))

        // button text "sign up"
        sign_up_button.setTitle("Sign up", for: .normal)
        sign_up_button.setTitleColor(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1), for: .normal)
        
        // add button target
        sign_up_button.addTarget(self, action: #selector(sign_up), for: .touchUpInside)

        // center within view
        sign_up_button.center.x = self.view.frame.midX
        
        sign_up_button.addTarget(self, action: #selector(sign_up), for: .touchUpInside)
        
        //set color
        //sign_up_button.backgroundColor = .white //UIColor(red: 69/255, green: 193/255, blue: 233/255, alpha: 1)
        
        //set alpha for fade animation
        sign_up_button.alpha = 0.0

        // add button to view
        self.view.addSubview(sign_up_button)
        
        //do fade-in animation
        UIView.animate(withDuration: 0.8, animations: {
            self.sign_up_button.alpha = 1.0
        })
    }
    
    @objc func sign_in() {
        //self.performSegue(withIdentifier: "to_sign_in", sender: self)
        print("sign in")

        self.performSegue(withIdentifier: "to_auth2", sender: self)

    }
    
    @objc func sign_up() {
        //self.performSegue(withIdentifier: "to_sign_up", sender: self)
        print("sign up")

        self.performSegue(withIdentifier: "to_auth", sender: self)

    }
    
    func configurePageControl() {
        // The total number of pages that are available is based on how many available colors we have.
        pageControl = UIPageControl(frame: CGRect(x: 0, y: (self.view.frame.maxY - self.view.frame.maxY/4.5), width: UIScreen.main.bounds.width, height: 40))
        self.pageControl.numberOfPages = orderedViewControllers.count
        self.pageControl.currentPage = 0
        self.pageControl.tintColor = UIColor.black
        self.pageControl.pageIndicatorTintColor = UIColor.white
        self.pageControl.currentPageIndicatorTintColor = UIColor.black
        self.view.addSubview(pageControl)
    }
    
    // MARK: Delegate functions
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let pageContentViewController = pageViewController.viewControllers![0]
        self.pageControl.currentPage = orderedViewControllers.index(of: pageContentViewController)!
    }
    
    func newVc(viewController: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: viewController)
    }
    
    lazy var orderedViewControllers: [UIViewController] = {
        return [self.newVc(viewController: "sOne"),
                self.newVc(viewController: "sTwo"),
                self.newVc(viewController: "sThree")]
    }()

    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        // User is on the first view controller and swiped left to loop to
        // the last view controller.
        guard previousIndex >= 0 else {
            return orderedViewControllers.last
            // Uncommment the line below, remove the line above if you don't want the page control to loop.
            // return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        // User is on the last view controller and swiped right to loop to
        // the first view controller.
        guard orderedViewControllersCount != nextIndex else {
            return orderedViewControllers.first
            // Uncommment the line below, remove the line above if you don't want the page control to loop.
            // return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
    
}
