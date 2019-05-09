//
//  SignUpScreenRouter.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 8/22/17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import UIKit

//MARK: - Login Router Protocol

typealias AgreementCompletion = (_ consent: Bool) -> Void

protocol SignUpScreenRouterProtocol {
    func navigateToWelcomeScreen()
    func showUserAgreementScreen(_ completion: @escaping AgreementCompletion)
}

class SignUpScreenRouter {
    
    private(set) weak var viewController: SignUpScreenViewController?
    
    private var userAgreementController: UserAgreementScreenViewController!
    private var onAgreementCompletion: AgreementCompletion!
    //MARK: - Lifecycle
    
    init(viewController: SignUpScreenViewController) {
        self.viewController =  viewController
    }
    
}

extension SignUpScreenRouter: SignUpScreenRouterProtocol {

    // TODO: fix naming inconsistancy - navigateToWelcomeScreen and showUserAgreementScreen methods
    
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

}

// MARK: - UserAgreementScreenDelegate

extension SignUpScreenRouter: UserAgreementScreenDelegate {

    func userDidAgree() {
        userAgreementController.dismiss(animated: true, completion: nil)
        onAgreementCompletion(true)
    }

    func userDidDecline() {
        userAgreementController.dismiss(animated: true, completion: nil)
        onAgreementCompletion(false)
    }

}
