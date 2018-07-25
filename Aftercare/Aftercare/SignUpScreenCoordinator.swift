//
//  SignUpScreenCoordinator.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 8/22/17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import UIKit

//MARK: - SignUp Screen Coordinator Protocols

protocol SignUpScreenCoordinatorInputProtocol: CoordinatorInputProtocol, SignUpScreenControllerOutputProtocol {}
protocol SignUpScreenCoordinatorOutputProtocol: CoordinatorOutputProtocol {
    func userDidLogin()
    func userDidFailToLogin(error: NSError)
    func userIsNotConsentOnTermsAndConditions()
    func userDidCancelToAuthenticate()
}

class SignUpScreenCoordinator {
    
    let output: SignUpScreenPresenterInputProtocol!
    
    //MARK: - Fileprivate
    
    fileprivate var userInfo: UserData?
    
    //MARK: - Lifecycle
    
    init(output: SignUpScreenPresenterInputProtocol) {
        self.output = output
    }
    
}

extension SignUpScreenCoordinator: SignUpScreenCoordinatorInputProtocol {
    
    // [1.0] request login with social network
    func requestLoginWith(provider: SocialLoginProviderProtocol, in controller: UIViewController) {
        
        provider.requestAuthentication(from: controller) { [weak self] result, error in
            
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
                        assertionFailure("Fatal Error: missing user email")
                        return
                    }
                    
                    self?.userInfo = UserData(
                        id: 0,
                        email: email,
                        firstName: dataContainer.firstName,
                        lastName: dataContainer.lastName,
                        gender: GenderType(rawValue: dataContainer.gender ?? GenderType.unspecified.rawValue)!
                    )
                }
                
                // [1.1] after successful login with social network we attempt to login to the backend
                self?.internalLoginWithSocial(result)
            }
        }
    }
    
    //[2.0] request sign up with email
    func requestSignUpUser(firstName: String, lastName: String, email: String, password: String, captchaId: Int, captchaCode: String) {
        
        let emailSignUpData = EmailRequestData(email: email, password: password)
        emailSignUpData.firstName = firstName
        emailSignUpData.lastName = lastName
        emailSignUpData.avatar64 = UserDataContainer.shared.userAvatar?.toBase64()
        
        emailSignUpData.captchaId = captchaId
        emailSignUpData.captchaCode = captchaCode
        emailSignUpData.consent = true
        
        APIProvider.signUp(withEmail: emailSignUpData) { [weak self] result, error in
            
            if let error = error?.toNSError() {
                self?.output.userDidFailToLogin(error: error)
                return
            }
            
            guard let session = result else {
                assertionFailure("Error: SignUpScreenCoordinator :: requestSignUpUser :: received invalid session result")
                return
            }
            
            self?.saveUserSession(session)
            self?.retreiveUserInfo()
            
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
    
    // [1.1] internal login to the backend
    fileprivate func internalLoginWithSocial(_ params: AuthenticationRequestProtocol) {
        //Attempt internal login-in on our server with social media credentials
        
        APIProvider.loginWithSocialNetwork(params: params) { [weak self] result, error in
            
            if let error = error?.toNSError() {
                if error.code == 417 {//User doesn't exist, try to sign-up
                    self?.internalSignUpWithSocial(params)
                } else {
                    //Unsuccessful login attempt
                    self?.output.userDidFailToLogin(error: error)
                }
            }
            
            guard let session = result else { return }
            self?.saveUserSession(session)//save received user session
            self?.retreiveUserInfo()// [1.2] logged in the backend, now we request the user data
        }
    }
    
    fileprivate func internalSignUpWithSocial(_ params: AuthenticationRequestProtocol) {
        
        //In this sign up method (with social credentials we don't need captcha code (obviously)
        
        var requestParams = params
        requestParams.firstName = self.userInfo?.firstName
        requestParams.lastName = self.userInfo?.lastName
        requestParams.gender = self.userInfo?.gender
        requestParams.avatar64 = UserDataContainer.shared.userAvatar?.toBase64()
        //The user can't reach to this point if doesn't consent so we assume that he consent to the Terms & Conditions of the app
        requestParams.consent = true
        
        APIProvider.signUpWithSocial(params: requestParams) { [weak self] result, error in
            if let error = error?.toNSError() {
                self?.output.userDidFailToLogin(error: error)
                return
            }
            
            guard let session = result else { return }
            self?.saveUserSession(session)//save received email session
            self?.retreiveUserInfo()
        }
    }
    
    fileprivate func saveUserSession(_ sessionData: UserSessionData) {
        EmailProvider.shared.saveUserSession(sessionData)
    }
    
    // [1.2] Retreive the user data
    fileprivate func retreiveUserInfo() {
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
                // [1.3] We are succsessfully signed-up / logged-in
                self?.output.userDidLogin()
            }
        }
    }
    
}
