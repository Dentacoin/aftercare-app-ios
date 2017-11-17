//
//  SignUpScreenPresenter.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 8/22/17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import Foundation

//MARK: - SignUp Screen Presenter Protocols

// In most cases equals Coordinator Output Protocol
protocol SignUpScreenPresenterInputProtocol: PresenterInputProtocol, SignUpScreenCoordinatorOutputProtocol {}
protocol SignUpScreenPresenterOutputProtocol: PresenterOutputProtocol {
    func showWelcomeScreen()
    func showUserAgreementScreen(_ data: AuthenticationRequestProtocol)
    func showErrorMessage(_ message: String)
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
    
    func userRequestSignUp(_ data: AuthenticationRequestProtocol) {
        output?.showUserAgreementScreen(data)
    }
    
    func userDidLogin() {
        output?.showWelcomeScreen()
    }
    
    func userDidFailToLogin(error: NSError) {
        UserDataContainer.shared.logout()//this clears any data saved during unsuccessful attempt to log-in
        output?.showErrorMessage(error.localizedDescription)
    }
    
    func userDidCancelToAuthenticate() {
        output?.userDidCancelToAuthenticate()
    }
    
}
