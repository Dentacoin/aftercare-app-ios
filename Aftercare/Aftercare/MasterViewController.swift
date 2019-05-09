//
//  MasterViewController.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 8/4/17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import UIKit

enum ChildViewController {
    case main
    case begin
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
    
    //MARK: - fileprivates
    
    fileprivate let viewController: MainMenuViewController! = UIStoryboard.main.instantiateViewController()
    
    //MARK: - Child Controllers Helpers
    
    private lazy var beginViewController: UINavigationController = {
        // Instantiate View Controller
        let viewController: BeginScreenViewController! = UIStoryboard.main.instantiateViewController()
        let navController = UINavigationController(rootViewController: viewController)
        navController.setNavigationBarHidden(true, animated: false)
        
        // Add View Controller as Child View Controller
        self.add(asChildViewController: navController)
        
        return navController
    }()

    private lazy var mainViewController: UINavigationController = {
        // Instantiate View Controller
        let viewController: MainMenuViewController! = UIStoryboard.main.instantiateViewController()
        let navController = UINavigationController(rootViewController: viewController)
        navController.setNavigationBarHidden(true, animated: false)
        
        // Add View Controller as Child View Controller
        self.add(asChildViewController: navController)
        
        return navController
    }()
    
    private func add(asChildViewController viewController: UIViewController) {
        // Add Child View Controller
        addChild(viewController)
        
        // Add Child View as Subview
        view.addSubview(viewController.view)
        
        // Configure Child View
        viewController.view.frame = view.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Notify Child View Controller
        viewController.didMove(toParent: self)
    }
    
    private func remove(asChildViewController viewController: UIViewController) {
        // Notify Child View Controller
        viewController.willMove(toParent: nil)
        
        // Remove Child View From Superview
        viewController.view.removeFromSuperview()
        
        // Notify Child View Controller
        viewController.removeFromParent()
    }
    
    //MARK: - View
    
    private func setupView() {
        // Do something
    }
    
    private func updateView() {
        switch currentChildViewController {
        case .main:
            remove(asChildViewController: beginViewController)
            add(asChildViewController: mainViewController)
        case .begin:
            remove(asChildViewController: mainViewController)
            add(asChildViewController: beginViewController)
        }
    }
    
}
