//
//  LoginScreenPresenter.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 8/22/17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import Foundation
import UIKit

//MARK: - Login Screen Presenter Protocols

// In most cases equals Coordinator Output Protocol
protocol LoginScreenPresenterInputProtocol: PresenterInputProtocol, LoginScreenCoordinatorOutputProtocol {}
protocol LoginScreenPresenterOutputProtocol: PresenterOutputProtocol {
    func showWelcomeScreen()
    func showErrorMessage(_ message: String)
    func userNotConsentToTermsAndConditions()
    func userDidCancelToAuthenticate()
}

class LoginScreenPresenter {
    
    private(set) weak var output: LoginScreenPresenterOutputProtocol?
    
    //MARK: - Lifecycle
    
    init(output: LoginScreenPresenterOutputProtocol) {
        self.output = output
    }
    
}

extension LoginScreenPresenter: LoginScreenPresenterInputProtocol {

    func userDidLogin() {
        output?.showWelcomeScreen()
    }
    
    func userDidFailToLogin(error: NSError) {
        UserDataContainer.shared.logout()//this clears any data saved during unsuccessful attempt to sign-up
        output?.showErrorMessage(error.localizedDescription)
    }
    
    func userDidSignUp() {
        output?.showWelcomeScreen()
    }
    
    func userDidFailToSignUp(error: NSError) {
        UserDataContainer.shared.logout()//this clears any data saved during unsuccessful attempt to log-in
        output?.showErrorMessage(error.localizedDescription)
    }
    
    func userIsNotConsentOnTermsAndConditions() {
        output?.userNotConsentToTermsAndConditions()
    }
    
    func userDidCancelToAuthenticate() {
        output?.userDidCancelToAuthenticate()
    }

}
