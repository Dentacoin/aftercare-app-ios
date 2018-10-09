//
//  FacebookProvider.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 8/29/17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class FacebookProvider {
    
    static let shared = FacebookProvider()
    private init() { }
    
    //MARK: - fileprivate vars
    
    fileprivate var hasGrantedEmailPermisson = false
    fileprivate var hasGrantedProfilePermission = false
    fileprivate var loggedIn = false
    
    //MARK: - Public properties
    
    var userID: String? {
        get {
            
            if let id: String = UserDefaultsManager.shared.getValue(forKey: FacebookDefaultsKeys.UserFacebookID.rawValue) {
                return id
            }
            return nil
        }
    }
    
    var token: String? {
        get {
            if let token: String = UserDefaultsManager.shared.getValue(forKey: FacebookDefaultsKeys.Token.rawValue) {
                return token
            }
            return nil
        }
    }
    
    var tokenValidTo: Date? {
        get {
            if let date: Date = UserDefaultsManager.shared.getValue(forKey: FacebookDefaultsKeys.TokenValidTo.rawValue) {
                return date
            }
            return nil
        }
    }
    
    func logout() {
        
        //TODO - logout from FB SDK
        
        loggedIn = false
        
    }
    
    //MARK: - Fileprivates
    
    fileprivate func requestNewSession (
        in controller: UIViewController,
        _ onComplete: @escaping ( _ result: [String : Any]) -> Void
        ) {
        
        var sessionData: [String : Any] = [:]
        
        let login = FBSDKLoginManager()
        
        //login.loginBehavior = .web
        
        login.logIn(
            withReadPermissions: [FacebookUserPermissions.Email.rawValue, FacebookUserPermissions.PublicProfile.rawValue],
            from: controller
        ) { [weak self] (result, error) in
            
            if let error = error {
                
                sessionData.updateValue(error, forKey: FacebookDefaultsKeys.Error.rawValue)
                onComplete(sessionData)
                
            } else {
                
                if let canceled: Bool = result?.isCancelled, canceled == true {
                    sessionData.updateValue(canceled, forKey: FacebookDefaultsKeys.Canceled.rawValue)
                    onComplete(sessionData)
                    return
                }
                
                if let token = result?.token {
                    
                    self?.hasGrantedEmailPermisson = token.hasGranted(FacebookUserPermissions.Email.rawValue)
                    self?.hasGrantedProfilePermission = token.hasGranted(FacebookUserPermissions.PublicProfile.rawValue)
                    
                    self?.loggedIn = true
                    
                    sessionData.updateValue(token.tokenString, forKey: FacebookDefaultsKeys.Token.rawValue)
                    sessionData.updateValue(token.userID, forKey: FacebookDefaultsKeys.UserFacebookID.rawValue)
                    
                    UserDefaultsManager.shared.setValue(token.tokenString, forKey: FacebookDefaultsKeys.Token.rawValue)
                    UserDefaultsManager.shared.setValue(token.expirationDate, forKey: FacebookDefaultsKeys.TokenValidTo.rawValue)
                    UserDefaultsManager.shared.setValue(token.userID, forKey: FacebookDefaultsKeys.UserFacebookID.rawValue)
                    
                    print("token: \(token.tokenString), userID: \(String(describing: token.userID)), expires on: \(String(describing: token.expirationDate))")
                    
                    onComplete(sessionData)
                    
                }
                
            }
        }
    }
    
    fileprivate func validateCurrentSession(_ onCompletion: (_ valid: Bool) -> Void) {
        let now = Date()
        if let tokenValidTo: Date = UserDefaultsManager.shared.getValue(forKey: FacebookDefaultsKeys.TokenValidTo.rawValue) {
            if now < tokenValidTo {
                //we still have valid session
                loggedIn = true
            } else {
                //expired session
                loggedIn = false
            }
        } else {
            //no previous session found
            loggedIn = false
        }
        onCompletion(loggedIn)
    }
    
    fileprivate func requestUserData(_ onComplete: @escaping (_ data: [String : Any]?, _ error: NSError?) -> Void) {
        
        FBSDKGraphRequest(
            graphPath: "me",
            parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email , gender"]
            ).start(completionHandler: { (connection, result, error) in
                
                if error != nil {
                    onComplete(nil, error! as NSError)
                    return
                }
                
                if let data: [String : Any?] = result as? Dictionary {
                    
                    var sessionData: [String : Any] = [:]
                    
                    if let firstName = data["first_name"] as? String {
                        UserDefaultsManager.shared.setValue(firstName, forKey: FacebookDefaultsKeys.FirstName.rawValue)
                    }
                    if let lastName = data["last_name"] as? String {
                        UserDefaultsManager.shared.setValue(lastName, forKey: FacebookDefaultsKeys.LastName.rawValue)
                    }
                    if let email = data["email"] as? String {
                        UserDefaultsManager.shared.setValue(email, forKey: FacebookDefaultsKeys.Email.rawValue)
                        sessionData.updateValue(email, forKey: "email")
                    }
                    if let gender = data["gender"] as? String {
                        UserDefaultsManager.shared.setValue(gender, forKey: FacebookDefaultsKeys.Gender.rawValue)
                    }
                    
                    if let picUserData = data["picture"] as? NSDictionary {
                        if let picData = picUserData["data"] as? NSDictionary {
                            if let url = picData["url"] as? String {
                                UserDefaultsManager.shared.setValue(url, forKey: FacebookDefaultsKeys.AvatarURL.rawValue)
                            }
                        }
                    }
                    
                    onComplete(sessionData, nil)
                }
            })
    }
    
}

//MARK: - FacebookProviderProtocol

extension FacebookProvider: FacebookProviderProtocol {
    
    //MARK: - Public methods
    
    func requestAuthentication(from controller: UIViewController, completionHandler: @escaping LoginRequestResult) {
        
        //Request new facebook session
        requestNewSession(in: controller) { [weak self] data in
            
            if let error = data[FacebookDefaultsKeys.Error.rawValue] as? NSError {
                if error.code == 1 {//another possible place where we can receive cancel by the user authentication error
                    let errorData = ErrorData(code: -1, errors: [ErrorKey.canceledAuthentication.rawValue])
                    completionHandler(nil, errorData)
                    return
                }
                let errorData = ErrorData(code: error.code, errors: [error.localizedDescription])
                completionHandler(nil, errorData)
                return
            }
            
            if let _ = data[FacebookDefaultsKeys.Canceled.rawValue] {
                let errorData = ErrorData(code: -1, errors: [ErrorKey.canceledAuthentication.rawValue])
                completionHandler(nil, errorData)
                return
            }
            
            guard let id = data[FacebookDefaultsKeys.UserFacebookID.rawValue] as? String else { return }
            guard let token = data[FacebookDefaultsKeys.Token.rawValue] as? String else { return }
            
            let authenticationRequestData = FacebookRequestData(email: "", id: id, token: token)
            
            self?.requestUserData() { [weak self] (data, error) in
                
                if let error = error {
                    self?.loggedIn = false
                    let errorData = ErrorData(code: error.code, errors: [error.localizedDescription])
                    completionHandler(nil, errorData)
                    return
                }
                
                if let data = data, let email = data["email"] as? String {
                    authenticationRequestData.email = email
                }
                
                self?.loggedIn = true
                completionHandler(authenticationRequestData, nil)
            }
            
        }
        
    }
    
}

extension FacebookProvider: DataProviderSerializedType {
    typealias EParameters = FacebookRequestData
}

//MARK: - UserDataProviderProtocol

extension FacebookProvider: UserDataProviderProtocol {
    
    var email: String? {
        get {
            if let email: String = UserDefaultsManager.shared.getValue(forKey: FacebookDefaultsKeys.Email.rawValue) {
                return email
            }
            return nil
        }
    }
    
    var avatarURL: String? {
        get {
            if let url: String = UserDefaultsManager.shared.getValue(forKey: FacebookDefaultsKeys.AvatarURL.rawValue) {
                return url
            }
            return nil
        }
    }
    
    var firstName: String? {
        get {
            if let name: String = UserDefaultsManager.shared.getValue(forKey: FacebookDefaultsKeys.FirstName.rawValue) {
                return name
            }
            return nil
        }
    }
    
    var lastName: String? {
        get {
            if let name: String = UserDefaultsManager.shared.getValue(forKey: FacebookDefaultsKeys.LastName.rawValue) {
                return name
            }
            return nil
        }
    }
    
    var gender: String? {
        get {
            if let gend: String = UserDefaultsManager.shared.getValue(forKey: FacebookDefaultsKeys.Gender.rawValue) {
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

fileprivate enum FacebookUserPermissions: String {
    case Email = "email"
    case PublicProfile = "public_profile"
    case Friends = "user_friends"
}

fileprivate enum FacebookDefaultsKeys: String {
    case Error = "error"
    case Canceled = "isCanceled"
    case Token = "facebookAccessToken"
    case TokenValidTo = "facebookTokenValidTo"
    case UserFacebookID = "facebookID"
    case Email = "facebookUserEmail"
    case AvatarURL = "facebookUserAvatar"
    case FirstName = "facebookUserFirstName"
    case LastName = "facebookUserLastName"
    case Gender = "facebookUserGender"
    
}
