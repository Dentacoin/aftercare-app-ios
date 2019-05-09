//
//  EmailProvider.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 8/29/17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import UIKit

class EmailProvider: EmailProviderProtocol, UserDataProviderProtocol {
    
    //MARK: - fileprivate vars
    
    fileprivate var loggedIn = false
    
    static let shared = EmailProvider()
    private init() { }
    
    //MARK: - public vars
    
    var firstName: String? {
        get {
            if let name: String = UserDefaultsManager.shared.getValue(forKey: UserDefaultsKeys.FirstName.rawValue) {
                return name
            }
            return nil
        }
    }
    
    var lastName: String? {
        get {
            if let name: String = UserDefaultsManager.shared.getValue(forKey: UserDefaultsKeys.LastName.rawValue) {
                return name
            }
            return nil
        }
    }
    
    var email: String? {
        get {
            if let emailAddress: String = UserDefaultsManager.shared.getValue(forKey: UserDefaultsKeys.Email.rawValue) {
                return emailAddress
            }
            return nil
        }
    }
    
    var avatarURL: String? {
        get {
            if let avatar: String = UserDefaultsManager.shared.getValue(forKey: UserDefaultsKeys.Avatar.rawValue) {
                return avatar
            }
            return nil
        }
    }
    
    var gender: String? {
        get {
            if let gend: String = UserDefaultsManager.shared.getValue(forKey: UserDefaultsKeys.Gender.rawValue) {
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
            if let pass: String = UserDefaultsManager.shared.getValue(forKey: UserDefaultsKeys.Password.rawValue) {
                return pass
            }
            return nil
        }
    }
    
    //MARK: - Public methods
    
    func logout() {
        
        UserDefaultsManager.shared.clearValue(forKey: UserDefaultsKeys.Token.rawValue)
        UserDefaultsManager.shared.clearValue(forKey: UserDefaultsKeys.Token.rawValue)
        UserDefaultsManager.shared.clearValue(forKey: UserDefaultsKeys.TokenValidTo.rawValue)
        UserDefaultsManager.shared.clearValue(forKey: UserDefaultsKeys.Email.rawValue)
        UserDefaultsManager.shared.clearValue(forKey: UserDefaultsKeys.Password.rawValue)
        UserDefaultsManager.shared.clearValue(forKey: UserDefaultsKeys.Avatar.rawValue)
        UserDefaultsManager.shared.clearValue(forKey: UserDefaultsKeys.FirstName.rawValue)
        UserDefaultsManager.shared.clearValue(forKey: UserDefaultsKeys.LastName.rawValue)
        UserDefaultsManager.shared.clearValue(forKey: UserDefaultsKeys.Gender.rawValue)
        
        loggedIn = false
    }
    
    func saveUserSession(_ session: UserSessionData) {
        UserDefaultsManager.shared.setGlobalValue(session.token, forKey: "token")
        UserDefaultsManager.shared.setGlobalValue(session.validTo, forKey: "token_valid_to")
    }
    
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
