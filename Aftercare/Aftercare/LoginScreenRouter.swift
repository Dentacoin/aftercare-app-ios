//
// Aftercare
// Created by Dimitar Grudev on 9.10.18.
// Copyright © 2018 Stichting Administratiekantoor Dentacoin.
//

import UIKit

protocol LoginScreenRouterProtocol {
    func navigateToWelcomeScreen()
    func showUserAgreementScreen(_ completion: @escaping AgreementCompletion)
    func showLoginWithEmailScreen()
}

class LoginScreenRouter {
    
    private(set) weak var viewController: LoginScreenViewController?
    
    fileprivate var userAgreementController: UserAgreementScreenViewController!
    private var onAgreementCompletion: AgreementCompletion!
    
    //MARK: - Lifecycle
    
    init(viewController: LoginScreenViewController) {
        self.viewController =  viewController
    }
    
}

extension LoginScreenRouter: LoginScreenRouterProtocol {
    
    func showLoginWithEmailScreen() {
        if let navController = viewController?.navigationController {
            let controller: LoginWithEmailScreenViewController! = UIStoryboard.main.instantiateViewController()
            navController.pushViewController(controller, animated: true)
        }
    }
    
    func navigateToWelcomeScreen() {
        if let navController = viewController?.navigationController {
            let controller: WelcomeScreenViewController! = UIStoryboard.main.instantiateViewController()
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

extension LoginScreenRouter: UserAgreementScreenDelegate {
    
    func userDidAgree() {
        userAgreementController.dismiss(animated: true, completion: nil)
        onAgreementCompletion(true)
    }
    
    func userDidDecline() {
        userAgreementController.dismiss(animated: true, completion: nil)
        onAgreementCompletion(false)
    }
    
}
