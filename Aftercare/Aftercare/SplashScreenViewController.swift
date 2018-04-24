//
//  SplashScreenViewController.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 8/7/17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import UIKit

class SplashScreenViewController : UIViewController {
    
    //MARK - IBOutlets
    
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    //MARK - Lifecycle 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
}

//MARK: - Theme and components setup

extension SplashScreenViewController {

    fileprivate func setup() {
        
        //MARK - setup the theme
        
        let themeManager = ThemeManager.shared
        
        themeManager.setDCBlueTheme(to: self.signUpButton, ofType: .ButtonDefault)
        self.signUpButton.titleLabel?.text = "btn_auth_signup".localized()
        
        themeManager.setDCBlueTheme(to: self.loginButton, ofType: .ButtonDefault)
        self.loginButton.titleLabel?.text = "btn_auth_login".localized()
        
    }
    
}

//MARK: - IBActions

extension SplashScreenViewController {
    
    @IBAction func signupButtonPressed(_ sender: UIButton) {
        if let navController = self.navigationController {
            
            let controller: SignUpScreenViewController! =
                UIStoryboard.login.instantiateViewController()
            
            navController.pushViewController(controller, animated: true)
        }
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        if let navController = self.navigationController {
            
            let controller: LoginScreenViewController! =
                UIStoryboard.login.instantiateViewController()
            
            navController.pushViewController(controller, animated: true)
        }
    }
    
}
