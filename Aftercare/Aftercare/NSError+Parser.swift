//
//  NSError+Parser.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 9/30/17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import Foundation

extension NSError {
    
    public convenience init(code: Int, errorKey: String) {
        
        let domain = "com.dentacoin.mobileapp.api.error"
        var description: String = NSLocalizedString("Unknown Error: \(errorKey)", comment: "")
        
        if let key = ErrorKeys(rawValue: errorKey) {
        
            switch key {
            case .PasswordShort:
                description = NSLocalizedString("Password is too short", comment: "")
                break
            case .InvalidEmailOrPassword:
                description = NSLocalizedString("Invalid Email or Password", comment: "")
                break
            case .InvalidGender:
                description = NSLocalizedString("Invalid Gender Type", comment: "")
                break
            case .InvalidCountry:
                description = NSLocalizedString("Invalid Country", comment: "")
                break
            case .InvalidBirthDay:
                description = NSLocalizedString("Invalid Birth Date", comment: "")
                break
            case .InvalidAvatar:
                description = NSLocalizedString("Invalid Avatar format", comment: "")
                break
            case .UserNotExist:
                description = NSLocalizedString("User Doesn't exist ", comment: "")
                break
            case .MissingEmail:
                description = NSLocalizedString("Missing Email", comment: "")
                break
            case .InvalidEmail:
                description = NSLocalizedString("Invalid Email Address", comment: "")
                break
            case .MissingPassword:
                description = NSLocalizedString("Missing Password", comment: "")
                break
            case .EmailAlreadyRegistered:
                description = NSLocalizedString("Email Address Already Registered", comment: "")
                break
            case .MissignFBID:
                description = NSLocalizedString("Missing Facebook ID", comment: "")
                break
            case .MissingFBToken:
                description = NSLocalizedString("Missing Facebook Token", comment: "")
                break
            case .MissingGoogleID:
                description = NSLocalizedString("Missing Google ID", comment: "")
                break
            case .MissingGoogleToken:
                description = NSLocalizedString("Missing Google Token", comment: "")
                break
            case .MissingTwitterID:
                description = NSLocalizedString("Missing Twitter ID", comment: "")
                break
            case .MissingTwitterToken:
                description = NSLocalizedString("Missing Twitter Token", comment: "")
                break
            case .MissingTwitterTokenSecret:
                description = NSLocalizedString("Missing Twitter Token Secret", comment: "")
                break
            case .CanceledAuthentication:
                description = NSLocalizedString("Canceled Authentication By The User", comment: "")
                break
            case .UserCannotWithdraw:
                description = NSLocalizedString("Sorry but you have to use Dentacare app for at least 3 months to be able to withdraw earned DCN!", comment: "")
                break
            }
            
        }
        
        let userInfo: [String : Any] = [
            NSLocalizedDescriptionKey : description as Any
        ]
        
        self.init(domain: domain, code: code, userInfo: userInfo)
    }
    
    class func createCancelAuthenticationError() -> NSError {
        return NSError(code: -1, errorKey: ErrorKeys.CanceledAuthentication.rawValue)
    }
    
}

enum ErrorKeys: String, RawRepresentable {
    
    case PasswordShort = "password_short"
    case InvalidEmailOrPassword = "invalid_email_password"
    case InvalidGender = "invalid_gender"
    case InvalidCountry = "invalid_country"
    case InvalidBirthDay = "invalid_birthday"
    case InvalidAvatar = "invalid_avatar"
    case UserNotExist = "user_not_exist"
    
    case MissingEmail = "missing_email"
    case InvalidEmail = "invalid_email"
    case MissingPassword = "missing_password"
    case EmailAlreadyRegistered = "email_already_registered"
    case MissignFBID = "missing_facebook_id"
    case MissingFBToken = "missing_facebook_token"
    case MissingGoogleID = "missing_google_id"
    case MissingGoogleToken = "missing_google_token"
    case MissingTwitterID = "missing_twitter_id"
    case MissingTwitterToken = "missing_twitter_token"
    case MissingTwitterTokenSecret = "missing_twitter_token_secret"
    
    case CanceledAuthentication = "canceled_authentication_by_the_user"
    case UserCannotWithdraw = "user_cannot_withdraw"
}
