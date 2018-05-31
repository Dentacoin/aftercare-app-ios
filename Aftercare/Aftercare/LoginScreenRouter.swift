//
//  LoginScreenRouter.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 8/22/17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import UIKit

//MARK: - Login Router Protocol

protocol LoginScreenRouterProtocol {
    func navigateToWelcomeScreen()
    func showUserAgreementScreen()
    func showForgotPasswordScreen()
}

class LoginScreenRouter {
    
    private(set) weak var viewController: LoginScreenViewController?
    
    //MARK: - Lifecycle
    
    init(viewController: LoginScreenViewController) {
        self.viewController =  viewController
    }
    
}

extension LoginScreenRouter: LoginScreenRouterProtocol {

    func navigateToWelcomeScreen() {
        if let navController = viewController?.navigationController {
            
            let controller: WelcomeScreenViewController! =
                UIStoryboard.main.instantiateViewController()
            
            navController.pushViewController(controller, animated: true)
        }
    }
    
    func showUserAgreementScreen() {
        if let navController = viewController?.navigationController {
            
            let controller: UserAgreementScreenViewController! =
                UIStoryboard.main.instantiateViewController()
            
            navController.pushViewController(controller, animated: true)
        }
    }
    
    func showForgotPasswordScreen() {
        if let navController = viewController?.navigationController {
            
            let controller: ForgotYourPasswordScreenViewController! =
                UIStoryboard.main.instantiateViewController()
            
            navController.pushViewController(controller, animated: true)
        }
    }
}
