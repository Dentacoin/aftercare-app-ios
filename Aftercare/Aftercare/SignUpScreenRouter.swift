//
//  SignUpScreenRouter.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 8/22/17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import UIKit

//MARK: - Login Router Protocol

protocol SignUpScreenRouterProtocol {
    func navigateToWelcomeScreen()
    func showUserAgreementScreen(_ data: AuthenticationRequestProtocol)
}

class SignUpScreenRouter {
    
    private(set) weak var viewController: SignUpScreenViewController?
    
    //MARK: - Lifecycle
    
    init(viewController: SignUpScreenViewController) {
        self.viewController =  viewController
    }
    
}

extension SignUpScreenRouter: SignUpScreenRouterProtocol {

    func navigateToWelcomeScreen() {
        if let navController = viewController?.navigationController {
            
            let controller: WelcomeScreenViewController! =
                UIStoryboard.main.instantiateViewController()
            
            navController.pushViewController(controller, animated: true)
        }
    }
    
    func showUserAgreementScreen(_ data: AuthenticationRequestProtocol) {
        if let navController = viewController?.navigationController {
            
            let controller: UserAgreementScreenViewController! =
                UIStoryboard.main.instantiateViewController()
            controller.config(data)
            navController.pushViewController(controller, animated: true)
        }
    }

}
