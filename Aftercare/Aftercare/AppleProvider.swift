//
//  AppleProvider.swift
//  Aftercare
//
//  Created by Apple on 9/1/21.
//  Copyright © 2021 Dimitar Grudev. All rights reserved.
//

import Foundation
import AuthenticationServices


class AppleProvider : NSObject {
    
    static let shared = AppleProvider()
    
    //singleton constructor
    override private init() {
        
        super.init()
      
    }
    
    //MARK: - fileprivate vars
    fileprivate var loggedIn = false
    fileprivate var controller: UIViewController?
    fileprivate var completion: LoginRequestResult?
    fileprivate var appleSignInViewController: UIViewController?
    
    //MARK: - Public properties
    
    var userID: String? {
        get {
            
            if let id: String = UserDefaultsManager.shared.getValue(forKey: AppleDefaultsKeys.appleLoginId.rawValue) {
                return id
            }
            return nil
        }
    }
    
    var token: String? {
        get {
            if let token: String = UserDefaultsManager.shared.getValue(forKey: AppleDefaultsKeys.Token.rawValue) {
                return token
            }
            return nil
        }
    }
    
    var tokenValidTo: Date? {
        get {
            if let date: Date = UserDefaultsManager.shared.getValue(forKey: AppleDefaultsKeys.TokenValidTo.rawValue) {
                return date
            }
            return nil
        }
    }
    
    func logout() {
        
        //TODO - logout from FB SDK
        
        loggedIn = false
        
    }
    


    
}
extension AppleProvider : AppleProviderProtocol{
    
    func requestAuthentication(from controller: UIViewController, completionHandler: @escaping LoginRequestResult) {
        
        
        if #available(iOS 13.0, *) {
            let appleidprovider = ASAuthorizationAppleIDProvider()
            let request = appleidprovider.createRequest()
            request.requestedScopes = [.email,.fullName]
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
            self.controller = controller
            self.completion = completionHandler
            
        } else {
            // Fallback on earlier versions
        }
        
        
       
        
    }
    
    
}

extension AppleProvider :  ASAuthorizationControllerDelegate{
    
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print(error.localizedDescription)
        
    }
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        switch authorization.credential {
        case let credentials as ASAuthorizationAppleIDCredential:
            print("Email: \(credentials.user)")
            print("Token: \(credentials.identityToken!)")
            print("Token string: \(credentials.identityToken?.base64EncodedString() ?? nil)")
           
            guard let idTokenString = String(data: credentials.identityToken!, encoding: .utf8) else {
            print("Unable to serialize token string from data: \(credentials.identityToken.debugDescription)")
            
                return
            }
           
            print(idTokenString)
            
            
            let authenticationRequestData = AppleRequestData(id: idTokenString)
            
            self.loggedIn = true
            
            if let completion = self.completion {
               
                completion(authenticationRequestData, nil)
                self.appleSignInViewController?.removeFromParent()
               
            }
            
        default:
            break
        }
    }
    
}

extension AppleProvider: DataProviderSerializedType {
    typealias EParameters = AppleRequestData
}


extension AppleProvider: ASAuthorizationControllerPresentationContextProviding{

    @available(iOS 13.0, *)
    func presentationAnchor(for controller : ASAuthorizationController) -> ASPresentationAnchor {
        return (appleSignInViewController?.view.window!)!
    }
}

extension AppleProvider: UserDataProviderProtocol {
   
    var email: String? {
        get {
            if let email: String = UserDefaultsManager.shared.getValue(forKey: AppleDefaultsKeys.Email.rawValue) {
                return email
            }
            return nil
        }
    }
    
    var avatarURL: String? {
        get {
            if let url: String = UserDefaultsManager.shared.getValue(forKey: AppleDefaultsKeys.AvatarURL.rawValue) {
                return url
            }
            return nil
        }
    }
    
    var firstName: String? {
        get {
            if let name: String = UserDefaultsManager.shared.getValue(forKey: AppleDefaultsKeys.FirstName.rawValue) {
                return name
            }
            return nil
        }
    }
    
    var lastName: String? {
        get {
            if let name: String = UserDefaultsManager.shared.getValue(forKey: AppleDefaultsKeys.LastName.rawValue) {
                return name
            }
            return nil
        }
    }
    
    var gender: String? {
        get {
            if let gend: String = UserDefaultsManager.shared.getValue(forKey: AppleDefaultsKeys.Gender.rawValue) {
                return gend
            }
            return nil
        }
    }
    
    var isLoggedIn: Bool {
        get {
            return loggedIn
        }
    }
    
}


fileprivate enum AppleDefaultsKeys: String {
    case Error = "error"
    case Canceled = "isCanceled"
    case Token = "AppleAccessToken"
    case TokenValidTo = "AppleTokenValidTo"
    case appleLoginId = "appleLoginId"
    case Email = "appleUserEmail"
    case AvatarURL = "appleUserAvatar"
    case FirstName = "appleUserFirstName"
    case LastName = "appleUserLastName"
    case Gender = "aapleUserGender"
    
}

