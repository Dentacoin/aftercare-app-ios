//
// Aftercare
// Created by Dimitar Grudev on 9.10.18.
// Copyright © 2018 Stichting Administratiekantoor Dentacoin.
//

import UIKit

protocol LoginScreenCoordinatorInputProtocol: CoordinatorInputProtocol, LoginScreenControllerOutputProtocol {}
protocol LoginScreenCoordinatorOutputProtocol: CoordinatorOutputProtocol {
    func userDidSignUp()
    func userDidFailToSignUp(error: NSError)
    func userDidLogin()
    func userDidFailToLogin(error: NSError)
    func userIsNotConsentOnTermsAndConditions()
    func userDidCancelToAuthenticate()
}

class LoginScreenCoordinator {
    
    let output: LoginScreenPresenterInputProtocol!
    
    //MARK: - Fileprivate
    
    fileprivate var userInfo: UserData?
    
    //MARK: - Lifecycle
    
    init(output: LoginScreenPresenterInputProtocol) {
        self.output = output
    }
    
}

extension LoginScreenCoordinator: LoginScreenCoordinatorInputProtocol {
    
    func requestLoginWith(provider: SocialLoginProviderProtocol, in controller: UIViewController) {
        provider.requestAuthentication(from: controller) { [weak self] result, error in
            
            if let error = error {
                if error.code == -1 {// NOTE: - canceled by the user
                    self?.output.userDidCancelToAuthenticate()
                    return
                }
                self?.output.userDidFailToLogin(error: error.toNSError())
                return
            }
            
            if let result = result {
                
                if let dataContainer = result as? UserDataProviderProtocol {
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
                
                // NOTE: - [1.1] after successful login with social network we attempt to login to the backend
                self?.internalLoginWithSocial(result)
                // //(CivicRequestData(id: "b80eae173d5313a4335d687ffd7e390a78d2174a70efe998c2996efb0bb337e4", email: "xdkg@abv.bg"))
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
    
    // NOTE: - [1.1] internal login to the backend
    fileprivate func internalLoginWithSocial(_ params: AuthenticationResponseProtocol) {
        // NOTE: - Attempt internal login-in on our server with social media credentials
        
        APIProvider.loginWithSocialNetwork(params: params) { [weak self] result, error in
            
            if let error = error?.toNSError() {
                if error.code == 417 {// NOTE: - User doesn't exist, try to sign-up
                    self?.internalSignUpWithSocial(params)
                } else {
                    // NOTE: - Unsuccessful login attempt
                    self?.output.userDidFailToLogin(error: error)
                }
            }
            
            guard let session = result else { return }
            self?.saveUserSession(session)// NOTE: - save received user session
            self?.retreiveUserInfo()// NOTE: -  [1.2] logged in the backend, now we request the user data
        }
    }
    
    fileprivate func internalSignUpWithSocial(_ params: AuthenticationResponseProtocol) {
        
        // NOTE: - In this sign up method (with social credentials we don't need captcha code (obviously)
        
        var requestParams = params
        requestParams.firstName = self.userInfo?.firstName
        requestParams.lastName = self.userInfo?.lastName
        requestParams.gender = self.userInfo?.gender
        requestParams.avatar64 = UserDataContainer.shared.userAvatar?.toBase64()
        // NOTE: - The user can't reach to this point if doesn't consent so we assume that he consent to the Terms & Conditions of the app
        requestParams.consent = true
        
        APIProvider.signUpWithSocial(params: requestParams) { [weak self] result, error in
            if let error = error?.toNSError() {
                self?.output.userDidFailToLogin(error: error)
                return
            }
            
            guard let session = result else { return }
            self?.saveUserSession(session)// NOTE: - save received email session
            self?.retreiveUserInfo()
        }
    }
    
    fileprivate func saveUserSession(_ sessionData: UserSessionData) {
        EmailProvider.shared.saveUserSession(sessionData)
    }
    
    // NOTE: -  [1.2] Retreive the user data
    fileprivate func retreiveUserInfo() {
        APIProvider.retreiveUserInfo() { [weak self] userData, error in
            if let error = error {
                self?.output.userDidFailToLogin(error: error.toNSError())
                return
            }
            if let data = userData {
                UserDataContainer.shared.userInfo = data
                if let consent = data.consent, !consent {
                    self?.output.userIsNotConsentOnTermsAndConditions()
                } else {
                    // NOTE: -  [1.3] We are succsessfully signed-up / logged-in
                    self?.output.userDidLogin()
                }
            }
        }
    }
}
