//
// Aftercare
// Created by Dimitar Grudev on 9.10.18.
// Copyright © 2018 Stichting Administratiekantoor Dentacoin.
//

import UIKit

protocol LoginScreenPresenterInputProtocol: PresenterInputProtocol, LoginScreenCoordinatorOutputProtocol {}
protocol LoginScreenPresenterOutputProtocol: PresenterOutputProtocol {
    func showWelcomeScreen()
    func showErrorMessage(_ message: String)
    func userIsNotConsentOnTermsAndConditions()
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
    
    func userDidSignUp() {
        output?.showWelcomeScreen()
    }
    
    func userDidFailToSignUp(error: NSError) {
        output?.showErrorMessage(error.localizedDescription)
    }
    
    func userDidLogin() {
        output?.showWelcomeScreen()
    }
    
    func userDidFailToLogin(error: NSError) {
        UserDataContainer.shared.logout()//this clears any data saved during unsuccessful attempt to log-in
        output?.showErrorMessage(error.localizedDescription)
    }
    
    func userIsNotConsentOnTermsAndConditions() {
        output?.userIsNotConsentOnTermsAndConditions()
    }
    
    func userDidCancelToAuthenticate() {
        output?.userDidCancelToAuthenticate()
    }
    
}
