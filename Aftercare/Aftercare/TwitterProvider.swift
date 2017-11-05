//
//  TwitterProvider.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 8/29/17.
//  Copyright © 2017 Dimitar Grudev. All rights reserved.
//

import UIKit
import TwitterKit

class TwitterProvider {
    
    static let shared = TwitterProvider()
    private init() { }
    
    //MARK: - fileprivate constants
    
    fileprivate let defaults = UserDefaults.standard
    
    //MARK: - fileprivate vars
    
    fileprivate var loggedIn = false
    fileprivate var userToken = ""
    
    //MARK: - Public properties
    
    var userID: String? {
        get {
            if let id = defaults.value(forKey: TwitterDefaultsKeys.UserTwitterID.rawValue) as? String {
                return id
            }
            return nil
        }
    }
    
    var token: String? {
        get {
            if let token = defaults.value(forKey: TwitterDefaultsKeys.Token.rawValue) as? String {
                return token
            }
            return nil
        }
    }
    
    var tokenSecret: String? {
        get {
            if let secret = defaults.value(forKey: TwitterDefaultsKeys.TokenSecret.rawValue) as? String {
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
        
        Twitter.sharedInstance().logIn(completion: { [weak self] (session, error) in
            if let session = session {
                print("signed in as \(session.userName)")
                
                let requestData = TwitterRequestData(
                    email: "",
                    id: session.userID,
                    token: session.authToken,
                    secret: session.authTokenSecret
                )
                
                var fullNameArr = session.userName.components(separatedBy: " ")
                self?.defaults.set(fullNameArr[0], forKey: TwitterDefaultsKeys.FirstName.rawValue)
                
                if fullNameArr.count > 1 {
                    self?.defaults.set(fullNameArr[1], forKey: TwitterDefaultsKeys.LastName.rawValue)
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
            if let emailAddress = defaults.value(forKey: TwitterDefaultsKeys.Email.rawValue) as? String {
                return emailAddress
            }
            return nil
        }
    }
    
    var firstName: String? {
        get {
            if let name = defaults.value(forKey: TwitterDefaultsKeys.FirstName.rawValue) as? String {
                return name
            }
            return nil
        }
    }
    
    var lastName: String? {
        get {
            if let name = defaults.value(forKey: TwitterDefaultsKeys.LastName.rawValue) as? String {
                return name
            }
            return nil
        }
    }
    
    var avatarURL: String? {
        get {
            if let avatar = defaults.value(forKey: TwitterDefaultsKeys.Avatar.rawValue) as? String {
                return avatar
            }
            return nil
        }
    }
    
    var gender: String? {
        get {
            if let gend = defaults.value(forKey: TwitterDefaultsKeys.Gender.rawValue) as? String {
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
