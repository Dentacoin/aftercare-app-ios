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
    func userRequestSignUp(_ data: AuthenticationRequestProtocol)
    func userDidLogin()
    func userDidFailToLogin(error: NSError)
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
                
                if let dataContainer: UserDataProviderProtocol = provider as? UserDataProviderProtocol {
                    self?.userInfo = UserData(
                        firstName: dataContainer.firstName,
                        lastName: dataContainer.lastName,
                        gender: GenderType(rawValue: dataContainer.gender ?? GenderType.unspecified.rawValue)!,
                        email: dataContainer.email,
                        postalCode: nil,
                        country: nil,
                        city: nil,
                        birthDay: nil,
                        password: nil,
                        avatar_64: nil
                    )
                }
                
                self?.internalLogin(result)
            }
        }
    }
    
    func requestSignUpUser(firstName: String, lastName: String, email: String, password: String) {
        
        let emailSignUpData = EmailRequestData(email: email, password: password)
        emailSignUpData.firstName = firstName
        emailSignUpData.lastName = lastName
        emailSignUpData.avatar64 = UserDataContainer.shared.userAvatar?.toBase64()
        
        self.output.userRequestSignUp(emailSignUpData)
    }
    
    //MARK: - fileprivate methods
    
    fileprivate func internalLogin(_ params: AuthenticationRequestProtocol) {
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
                    self?.output.userDidLogin()
                }
            }
            
        }
    }
    
    fileprivate func internalSignUp(_ params: AuthenticationRequestProtocol) {
        
        var requestParams = params
        requestParams.firstName = self.userInfo?.firstName
        requestParams.lastName = self.userInfo?.lastName
        requestParams.gender = self.userInfo?.gender
        requestParams.avatar64 = UserDataContainer.shared.userAvatar?.toBase64()
        
        self.output.userRequestSignUp(requestParams)
    }
    
}
