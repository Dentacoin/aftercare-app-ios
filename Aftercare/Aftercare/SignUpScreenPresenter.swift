//
//  SignUpScreenPresenter.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 8/22/17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import UIKit

//MARK: - SignUp Screen Presenter Protocols

// In most cases equals Coordinator Output Protocol
protocol SignUpScreenPresenterInputProtocol: PresenterInputProtocol, SignUpScreenCoordinatorOutputProtocol {}
protocol SignUpScreenPresenterOutputProtocol: PresenterOutputProtocol {
    func showWelcomeScreen()
    func showErrorMessage(_ message: String)
    func userIsNotConsentOnTermsAndConditions()
    func userDidCancelToAuthenticate()
}

class SignUpScreenPresenter {
    
    private(set) weak var output: SignUpScreenPresenterOutputProtocol?
    
    //MARK: - Lifecycle
    
    init(output: SignUpScreenPresenterOutputProtocol) {
        self.output = output
    }
    
}

extension SignUpScreenPresenter: SignUpScreenPresenterInputProtocol {
    
    // TODO: fix naming: DidLogin and DidFailToLogin in SignUpScreenPresenter class. Replace with DidAuthenticate, DidFailToAuthenticate
    
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
