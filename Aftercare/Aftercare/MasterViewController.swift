//
//  MasterViewController.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 8/4/17.
//  Copyright © 2017 Dimitar Grudev. All rights reserved.
//

import UIKit

enum ChildViewController {
    case main
    case splash
}

final class MasterViewController: UIViewController {
    
    //MARK: - Public
    
    var currentChildViewController: ChildViewController = .main {
        didSet {
            updateView()
        }
    }
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupView()
    }
    
    //
    
    var preloadMainController: Bool = false {
        didSet {
            if preloadMainController {
                _ = viewController.view
            }
        }
    }
    
    //MARK: - fileprivates
    
    fileprivate let viewController: MainMenuViewController! = UIStoryboard.main.instantiateViewController()
    
    //MARK: - Child Controllers Helpers
    
    private lazy var splashViewController: UINavigationController = {
        // Instantiate View Controller
        let viewController: SplashScreenViewController! =
            UIStoryboard.login.instantiateViewController()
        
        let navController = UINavigationController(rootViewController: viewController)
        navController.setNavigationBarHidden(true, animated: false)
        
        // Add View Controller as Child View Controller
        self.add(asChildViewController: navController)
        
        return navController
    }()

    private lazy var mainViewController: UINavigationController = {
        // Instantiate View Controller
        
        let viewController: MainMenuViewController?
        
        if self.preloadMainController {
            viewController = self.viewController
        } else {
            viewController = UIStoryboard.main.instantiateViewController()
        }
        
        let navController = UINavigationController(rootViewController: viewController!)
        navController.setNavigationBarHidden(true, animated: false)
        
        // Add View Controller as Child View Controller
        self.add(asChildViewController: navController)
        
        return navController
    }()
    
    private func add(asChildViewController viewController: UIViewController) {
        // Add Child View Controller
        addChildViewController(viewController)
        
        // Add Child View as Subview
        view.addSubview(viewController.view)
        
        // Configure Child View
        viewController.view.frame = view.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Notify Child View Controller
        viewController.didMove(toParentViewController: self)
    }
    
    private func remove(asChildViewController viewController: UIViewController) {
        // Notify Child View Controller
        viewController.willMove(toParentViewController: nil)
        
        // Remove Child View From Superview
        viewController.view.removeFromSuperview()
        
        // Notify Child View Controller
        viewController.removeFromParentViewController()
    }
    
    //MARK: - View
    
    private func setupView() {
        // Do something
    }
    
    private func updateView() {
        switch currentChildViewController {
        case .main:
            remove(asChildViewController: splashViewController)
            add(asChildViewController: mainViewController)
        case .splash:
            remove(asChildViewController: mainViewController)
            add(asChildViewController: splashViewController)
        }
    }
    
}
