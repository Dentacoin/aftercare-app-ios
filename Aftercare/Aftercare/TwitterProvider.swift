//
//  TwitterProvider.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 8/29/17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import UIKit
import TwitterKit

class TwitterProvider {
    
    static let shared = TwitterProvider()
    private init() { }
    
    //MARK: - fileprivate vars
    
    fileprivate var loggedIn = false
    fileprivate var userToken = ""
    
    //MARK: - Public properties
    
    var userID: String? {
        get {
            if let id: String = UserDefaultsManager.shared.getValue(forKey: TwitterDefaultsKeys.UserTwitterID.rawValue) {
                return id
            }
            return nil
        }
    }
    
    var token: String? {
        get {
            if let token: String = UserDefaultsManager.shared.getValue(forKey: TwitterDefaultsKeys.Token.rawValue) {
                return token
            }
            return nil
        }
    }
    
    var tokenSecret: String? {
        get {
            if let secret: String = UserDefaultsManager.shared.getValue(forKey: TwitterDefaultsKeys.TokenSecret.rawValue) {
                return secret
            }
            return nil
        }
    }
    
    func logout() {
        loggedIn = false
    }
    
}

//MARK: - TwitterProviderProtocol

extension TwitterProvider: TwitterProviderProtocol {
    
    //MARK: - Public methods
    
    func requestAuthentication(from controller: UIViewController, completionHandler: @escaping LoginRequestResult) {
        
        TWTRTwitter.sharedInstance().logIn(completion: { [weak self] (session, error) in
            if let session = session {
                print("signed in as \(session.userName)")
                
                let requestData = TwitterRequestData(
                    email: "",
                    id: session.userID,
                    token: session.authToken,
                    secret: session.authTokenSecret
                )
                
                var fullNameArr = session.userName.components(separatedBy: " ")
                UserDefaultsManager.shared.setValue(fullNameArr[0], forKey: TwitterDefaultsKeys.FirstName.rawValue)
                
                if fullNameArr.count > 1 {
                    UserDefaultsManager.shared.setValue(fullNameArr[1], forKey: TwitterDefaultsKeys.LastName.rawValue)
                }
                
                //Request user email address required for login on the dentacoin server
                let client = TWTRAPIClient.withCurrentUser()
                client.requestEmail { [weak self] email, error in
                    if let email = email {
                        
                        self?.loggedIn = true
                        requestData.email = email
                        completionHandler(requestData, nil)
                        
                    } else {
                        if let error = error as NSError? {
                            self?.loggedIn = false
                            let errorData = ErrorData(code: error.code, errors: [error.localizedDescription])
                            completionHandler(nil, errorData)
                        }
                    }
                }
                
                //TODO: - retreive user avatar
                
            } else {
                if let error = error as NSError? {
                    let errorData = ErrorData(code: error.code, errors: [error.localizedDescription])
                    completionHandler(nil, errorData)
                }
            }
        })
        
    }
    
}

extension TwitterProvider: DataProviderSerializedType {
    typealias EParameters = TwitterRequestData
}

//MARK: - UserDataProviderProtocol

extension TwitterProvider: UserDataProviderProtocol {
    
    var email: String? {
        get {
            if let emailAddress: String = UserDefaultsManager.shared.getValue(forKey: TwitterDefaultsKeys.Email.rawValue) {
                return emailAddress
            }
            return nil
        }
    }
    
    var firstName: String? {
        get {
            if let name: String = UserDefaultsManager.shared.getValue(forKey: TwitterDefaultsKeys.FirstName.rawValue) {
                return name
            }
            return nil
        }
    }
    
    var lastName: String? {
        get {
            if let name: String = UserDefaultsManager.shared.getValue(forKey: TwitterDefaultsKeys.LastName.rawValue) {
                return name
            }
            return nil
        }
    }
    
    var avatarURL: String? {
        get {
            if let avatar: String = UserDefaultsManager.shared.getValue(forKey: TwitterDefaultsKeys.Avatar.rawValue) {
                return avatar
            }
            return nil
        }
    }
    
    var gender: String? {
        get {
            if let gend: String = UserDefaultsManager.shared.getValue(forKey: TwitterDefaultsKeys.Gender.rawValue) {
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

fileprivate enum TwitterDefaultsKeys: String {
    case Error = "error"
    case Token = "twitterAccessToken"
    case TokenSecret = "twitterAccessTokenSecret"
    case TokenValidTo = "twitterTokenValidTo"
    case UserTwitterID = "twitterID"
    case Email = "twitterUserEmail"
    case Avatar = "twitterUserAvatar"
    case FirstName = "twitterUserFirstName"
    case LastName = "twitterUserLastName"
    case Gender = "twitterUserGender"
}
