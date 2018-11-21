//
//  LoginScreenCoordinator.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 8/22/17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import UIKit

//MARK: - Login Screen Coordinator Protocols

protocol LoginWithEmailScreenCoordinatorInputProtocol: CoordinatorInputProtocol, LoginWithEmailScreenControllerOutputProtocol {}
protocol LoginWithEmailScreenCoordinatorOutputProtocol: CoordinatorOutputProtocol {
    func userDidSignUp()
    func userDidFailToSignUp(error: NSError)
    func userDidLogin()
    func userDidFailToLogin(error: NSError)
    func userIsNotConsentOnTermsAndConditions()
    func userDidCancelToAuthenticate()
}

class LoginWithEmailScreenCoordinator {
    
    let output: LoginWithEmailScreenPresenterInputProtocol!
    
    //MARK: - Fileprivates
    
    fileprivate var userInfo: UserData?
    
    //MARK: - Lifecycle
    
    init(output: LoginWithEmailScreenPresenterInputProtocol) {
        self.output = output
    }
    
}

extension LoginWithEmailScreenCoordinator: LoginWithEmailScreenCoordinatorInputProtocol {
    
    func requestLoginWith(provider: SocialLoginProviderProtocol, in controller: UIViewController) {
        
        provider.requestAuthentication(from: controller) { [weak self] result, error in
            
            //1. authentication with social network
            
            //Check for errors
            if let error = error {
                if error.code == -1 {//canceled by the user
                    self?.output.userDidCancelToAuthenticate()
                    return
                }
                self?.output.userDidFailToLogin(error: error.toNSError())
                return
            }
            
            if let result = result {
                
                if let dataContainer: UserDataProviderProtocol = result as? UserDataProviderProtocol {
                    
                    guard let email = dataContainer.email else {
                        return print("Fatal Error: missing user email")
                    }
                    
                    self?.userInfo = UserData(
                        id: 0,
                        email: email,
                        firstName: dataContainer.firstName,
                        lastName: dataContainer.lastName,
                        gender: GenderType(rawValue: dataContainer.gender ?? GenderType.unspecified.rawValue)!,
                        postalCode: nil,
                        country: nil,
                        city: nil,
                        consent: true,
                        birthDay: nil,
                        password: nil,
                        avatar_64: nil
                    )
                }
                
                self?.internalLogin(result)
            }
        }
    }
    
    func requestLoginWith(email: String, password: String) {
        
        let requestData = EmailRequestData(email: email, password: password)
        
        APIProvider.login(withEmail: requestData) { [weak self] response, error in
            
            if let error = error {
                self?.output.userDidFailToLogin(error: error.toNSError())
                return
            }
            
            guard let session = response else { return }
            EmailProvider.shared.saveUserSession(session)//save received email session
            
            APIProvider.retreiveUserInfo() { [weak self] userData, error in
                if let error = error {
                    self?.output.userDidFailToLogin(error: error.toNSError())
                    return
                }
                if let data = userData {
                    UserDataContainer.shared.userInfo = data
                    if let consent = data.consent {
                        if !consent {
                            self?.output.userIsNotConsentOnTermsAndConditions()
                            return
                        }
                    }
                    self?.output.userDidLogin()
                }
                
            }
            
        }
        
    }
    
    func updateUserConsentOnTermsAndConditions() {
        
        let userData = UserDataContainer.shared.userInfo
        guard var updateUserRequestData = userData?.toUpdateUserRequestData() else {
            assertionFailure("Error: LoginScreenCoordinator: updateUserConsentOnTermsAndConditions() :: unable to retreive valid updateUserRequestData")
            return
        }
        
        updateUserRequestData.consent = true
        
        APIProvider.updateUser(updateUserRequestData) { data, error in
            if let error = error?.toNSError() {
                print("Error: couldn't update user's consent on Terms And Conditions with error: \(error)")
                return
            }
            
            guard let data = data else {
                print("Error: Invalid user data : couldn't update user's consent on Terms And Conditions")
                return
            }
            UserDataContainer.shared.userInfo = data
        }
    }
    
    //MARK: - fileprivate methods
    
    fileprivate func internalLogin(_ params: AuthenticationResponseProtocol) {
        //Attempt internal login-in on our server with social media credentials
        
        APIProvider.loginWithSocialNetwork(params: params) { [weak self] result, error in
            
            if let error = error?.toNSError() {
                if error.code == 417 {//User doesn't exist, try to sign-up
                    
                    self?.internalSignUp(params)
                    
                } else {
                    //Unsuccessful login attempt
                    self?.output.userDidFailToLogin(error: error)
                }
            }
            
            guard let session = result else { return }
            EmailProvider.shared.saveUserSession(session)//save received email session
            
            APIProvider.retreiveUserInfo() { [weak self] userData, error in
                if let error = error {
                    self?.output.userDidFailToLogin(error: error.toNSError())
                    return
                }
                if let data = userData {
                    UserDataContainer.shared.userInfo = data
                    if let consent = data.consent {
                        if !consent {
                            self?.output.userIsNotConsentOnTermsAndConditions()
                            return
                        }
                    }
                    self?.output.userDidLogin()
                }
            }
            
        }
    }
    
    fileprivate func internalSignUp(_ params: AuthenticationResponseProtocol) {
        
        var requestParams = params
        requestParams.firstName = self.userInfo?.firstName
        requestParams.lastName = self.userInfo?.lastName
        requestParams.gender = self.userInfo?.gender
        
        APIProvider.signUpWithSocial(params: requestParams) { [weak self] response, error in
            
            if let error = error?.toNSError() {
                self?.output.userDidFailToSignUp(error: error)
                return
            }
            
            guard let session = response else { return }
            EmailProvider.shared.saveUserSession(session)//save received email session
            
            APIProvider.retreiveUserInfo() { [weak self] userData, error in
                if let error = error {
                    self?.output.userDidFailToSignUp(error: error.toNSError())
                    return
                }
                if let data = userData {
                    UserDataContainer.shared.userInfo = data
                    if let consent = data.consent, !consent {
                        self?.output.userIsNotConsentOnTermsAndConditions()
                    } else {
                        self?.output.userDidSignUp()
                    }
                }
            }
            
        }
    }
}
