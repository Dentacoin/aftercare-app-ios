//
//  SideMenuViewController.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 9/6/17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import Foundation
import UIKit

final class MainMenuViewController: UIViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var mainMenuButton: UIButton!
    
    //MARK: - fileprivates
    
    fileprivate var lastLoadedViewControllerID: String?
    
    fileprivate let sideMenuViewController: SideMenuViewController = {
        let menu: SideMenuViewController! = UIStoryboard.main.instantiateViewController()
        return menu
    }()
    
    fileprivate let backgroundView: UIViewController = {
       let vc = UIViewController()
        return vc
    }()
    
    fileprivate let lastViewController: UIViewController? = nil
    
    internal let navController: UINavigationController = {
        let navController = UINavigationController()
        return navController
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    fileprivate func setup() {
        navController.setNavigationBarHidden(true, animated: false)
        self.addChildViewController(navController)
        self.view.addSubview(navController.view)
        navController.view.frame = self.view.bounds
        navController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        navController.didMove(toParentViewController: self)
        
        //default home screen setup and load
        let homeScreen: ActionScreenViewController! = UIStoryboard.main.instantiateViewController()
        self.lastLoadedViewControllerID = String(describing: ActionScreenViewController.self)
        self.loadContent(homeScreen)
        
        //Setup Notifications
        NotificationsManager.shared.initialize()
    }
    
}

extension MainMenuViewController {
    
    fileprivate func loadContent(_ viewController: UIViewController, _ parameters: [String: Any]? = nil) {
        if let contentConformer = viewController as? ContentConformer {
            contentConformer.contentDelegate = self
            navController.pushViewController(contentConformer as! UIViewController, animated: true)
            if let data = parameters {
                contentConformer.config(data)
            }
        }
    }
    
}

//MARK: - conform to ContentDelegate

extension MainMenuViewController: ContentDelegate {
    
    func openMainMenu() {
        
        let screenFrame = CGRect(
            x: 0,
            y: 0,
            width: UIScreen.main.bounds.size.width,
            height: UIScreen.main.bounds.size.height
        )
        
        backgroundView.view.frame = screenFrame
        backgroundView.view.backgroundColor = UIColor.black.withAlphaComponent(0)
        self.view.addSubview(backgroundView.view)
        self.addChildViewController(backgroundView)
        
        sideMenuViewController.delegate = self
        self.view.addSubview(sideMenuViewController.view)
        
        self.addChildViewController(sideMenuViewController)
        sideMenuViewController.view.layoutIfNeeded()
        sideMenuViewController.view.frame = CGRect(
            x: 0 - UIScreen.main.bounds.size.width,
            y: 0,
            width: UIScreen.main.bounds.size.width,
            height: UIScreen.main.bounds.size.height
        )
        
        UIView.animate(withDuration: 0.3, animations: { [weak self] () -> Void in
            self?.sideMenuViewController.view.frame = CGRect(
                x: 0,
                y: 0,
                width: UIScreen.main.bounds.size.width,
                height: UIScreen.main.bounds.size.height
            )
            self?.backgroundView.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        }, completion:nil)
        
    }
    
    func requestLoadViewController(_ id: String, _ parameters: [String: Any]?) {
        self.menuItemSelected(id, parameters)
    }
    
    func backButtonIsPressed() {
        navController.popViewController(animated: true)
        
        if let vc = navController.topViewController {
            (vc as? ContentConformer)?.contentDelegate = self
            self.lastLoadedViewControllerID = NSStringFromClass(vc.classForCoder).components(separatedBy: ".").last!
            print("back to \(self.lastLoadedViewControllerID ?? "")")
        }
    }
    
}

//MARK: - SideMenuDelegate

extension MainMenuViewController: SideMenuDelegate {
    
    func menuItemSelected(_ id: String, _ parameters: [String: Any]?) {
        
        if let lastVCID = self.lastLoadedViewControllerID, id == lastVCID {
            return
        } else {
            self.lastLoadedViewControllerID = id
        }
        
        if let content = UIStoryboard.main.instantiateViewControllerWith(id: id) {
            self.loadContent(content, parameters)
        }
    }
    
    func logout() {
        
        if let navController = self.navigationController {
            
            UserDataContainer.shared.logout()
            
            let controller: LoginScreenViewController! =
                UIStoryboard.main.instantiateViewController()
            
            navController.pushViewController(controller, animated: true)
        }
        
    }
    
    func onCloseMenu() {
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.sideMenuViewController.view.frame = CGRect(
                x: -UIScreen.main.bounds.size.width,
                y: 0,
                width: UIScreen.main.bounds.size.width,
                height: UIScreen.main.bounds.size.height
            )
            self?.sideMenuViewController.view.layoutIfNeeded()
            self?.sideMenuViewController.view.backgroundColor = UIColor.clear
            self?.backgroundView.view.backgroundColor = UIColor.black.withAlphaComponent(0)
        }, completion: { [weak self] finished in
                self?.sideMenuViewController.view.removeFromSuperview()
                self?.sideMenuViewController.removeFromParentViewController()
                self?.backgroundView.view.removeFromSuperview()
                self?.backgroundView.removeFromParentViewController()
        })
    }
    
}






