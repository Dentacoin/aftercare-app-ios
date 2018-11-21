//
//  LoginScreenRouter.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 8/22/17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import UIKit

//MARK: - Login Router Protocol

protocol LoginWithEmailScreenRouterProtocol {
    func navigateToWelcomeScreen()
    func showUserAgreementScreen(_ completion: @escaping AgreementCompletion)
    func showForgotPasswordScreen()
}

class LoginWithEmailScreenRouter {
    
    private(set) weak var viewController: LoginWithEmailScreenViewController?
    
    fileprivate var userAgreementController: UserAgreementScreenViewController!
    private var onAgreementCompletion: AgreementCompletion!
    //MARK: - Lifecycle
    
    init(viewController: LoginWithEmailScreenViewController) {
        self.viewController =  viewController
    }
    
}

extension LoginWithEmailScreenRouter: LoginWithEmailScreenRouterProtocol {

    func navigateToWelcomeScreen() {
        if let navController = viewController?.navigationController {
            
            let controller: WelcomeScreenViewController! =
                UIStoryboard.main.instantiateViewController()
            
            navController.pushViewController(controller, animated: true)
        }
    }
    
    func showUserAgreementScreen(_ completion: @escaping AgreementCompletion) {
        if let navController = viewController?.navigationController {
            onAgreementCompletion = completion
            userAgreementController = UIStoryboard.main.instantiateViewController()
            userAgreementController.delegate = self
            navController.present(userAgreementController, animated: true, completion: nil)
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

// MARK: - UserAgreementScreenDelegate

extension LoginWithEmailScreenRouter: UserAgreementScreenDelegate {
    
    func userDidAgree() {
        userAgreementController.dismiss(animated: true, completion: nil)
        onAgreementCompletion(true)
    }
    
    func userDidDecline() {
        userAgreementController.dismiss(animated: true, completion: nil)
        onAgreementCompletion(false)
    }
    
}

