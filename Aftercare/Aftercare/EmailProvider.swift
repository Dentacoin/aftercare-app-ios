//
//  EmailProvider.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 8/29/17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import Foundation
import UIKit

class EmailProvider: EmailProviderProtocol, UserDataProviderProtocol {
    
    //MARK: - constants
    
    fileprivate let defaults = UserDefaults.standard
    
    //MARK: - fileprivate vars
    
    fileprivate var loggedIn = false
    
    static let shared = EmailProvider()
    private init() { }
    
    //MARK: - public vars
    
    var firstName: String? {
        get {
            if let name = defaults.value(forKey: UserDefaultsKeys.FirstName.rawValue) as? String {
                return name
            }
            return nil
        }
    }
    
    var lastName: String? {
        get {
            if let name = defaults.value(forKey: UserDefaultsKeys.LastName.rawValue) as? String {
                return name
            }
            return nil
        }
    }
    
    var email: String? {
        get {
            if let emailAddress = defaults.value(forKey: UserDefaultsKeys.Email.rawValue) as? String {
                return emailAddress
            }
            return nil
        }
    }
    
    var avatarURL: String? {
        get {
            if let avatar = defaults.value(forKey: UserDefaultsKeys.Avatar.rawValue) as? String {
                return avatar
            }
            return nil
        }
    }
    
    var gender: String? {
        get {
            if let gend = defaults.value(forKey: UserDefaultsKeys.Gender.rawValue) as? String {
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
    
    var password: String? {
        get {
            if let pass = defaults.value(forKey: UserDefaultsKeys.Password.rawValue) as? String {
                return pass
            }
            return nil
        }
    }
    
    //MARK: - Public methods
    
    func logout() {
        
        defaults.setValue(nil, forKey: UserDefaultsKeys.Token.rawValue)
        defaults.setValue(nil, forKey: UserDefaultsKeys.TokenValidTo.rawValue)
        defaults.setValue(nil, forKey: UserDefaultsKeys.Email.rawValue)
        defaults.setValue(nil, forKey: UserDefaultsKeys.Password.rawValue)
        defaults.setValue(nil, forKey: UserDefaultsKeys.Avatar.rawValue)
        defaults.setValue(nil, forKey: UserDefaultsKeys.FirstName.rawValue)
        defaults.setValue(nil, forKey: UserDefaultsKeys.LastName.rawValue)
        defaults.setValue(nil, forKey: UserDefaultsKeys.Gender.rawValue)
        
        loggedIn = false
    }
    
    func saveUserSession(_ session: UserSessionData) {
        self.defaults.setValue(session.token, forKey: "token")
        self.defaults.setValue(session.validTo, forKey: "token_valid_to")
        defaults.synchronize()
        
    }
    
    //MARK: - fileprivate methods
    
    
}

extension EmailProvider: DataProviderSerializedType {
    typealias EParameters = EmailRequestData
}

fileprivate enum UserDefaultsKeys: String {
    
    case Token = "uToken"
    case TokenValidTo = "uTokenValidTo"
    case Email = "uEmail"
    case Password = "uPassword"
    case Avatar = "uAvatar"
    case FirstName = "uFirstName"
    case LastName = "uLastName"
    case Gender = "uGender"
    
}
