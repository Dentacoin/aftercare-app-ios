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
        
        if code == ErrorCodes.noInternetConnection.rawValue {
            description = NSLocalizedString("The Internet connection appears to be offline.", comment: "")
        } else  if let key = ErrorKeys(rawValue: errorKey) {
            switch key {
                case .passwordShort:
                    description = NSLocalizedString("Password is too short", comment: "")
                case .invalidEmailOrPassword:
                    description = NSLocalizedString("Invalid Email or Password", comment: "")
                case .invalidGender:
                    description = NSLocalizedString("Invalid Gender Type", comment: "")
                case .invalidCountry:
                    description = NSLocalizedString("Invalid Country", comment: "")
                case .invalidBirthDay:
                    description = NSLocalizedString("Invalid Birth Date", comment: "")
                case .invalidAvatar:
                    description = NSLocalizedString("Invalid Avatar format", comment: "")
                case .userNotExist:
                    description = NSLocalizedString("User Doesn't exist ", comment: "")
                case .missingEmail:
                    description = NSLocalizedString("Missing Email", comment: "")
                case .invalidEmail:
                    description = NSLocalizedString("Invalid Email Address", comment: "")
                case .missingPassword:
                    description = NSLocalizedString("Missing Password", comment: "")
                case .emailAlreadyRegistered:
                    description = NSLocalizedString("Email Address Already Registered", comment: "")
                case .missignFBID:
                    description = NSLocalizedString("Missing Facebook ID", comment: "")
                case .missingFBToken:
                    description = NSLocalizedString("Missing Facebook Token", comment: "")
                case .missingGoogleID:
                    description = NSLocalizedString("Missing Google ID", comment: "")
                case .missingGoogleToken:
                    description = NSLocalizedString("Missing Google Token", comment: "")
                case .missingTwitterID:
                    description = NSLocalizedString("Missing Twitter ID", comment: "")
                case .missingTwitterToken:
                    description = NSLocalizedString("Missing Twitter Token", comment: "")
                case .missingTwitterTokenSecret:
                    description = NSLocalizedString("Missing Twitter Token Secret", comment: "")
                case .canceledAuthentication:
                    description = NSLocalizedString("Canceled Authentication By The User", comment: "")
                case .userCannotWithdraw:
                    description = NSLocalizedString("Sorry but you have to use Dentacare app for at least 3 months to be able to withdraw earned DCN!", comment: "")
                case .userEmailConfirmed:
                    description = NSLocalizedString("User Email Already Confirmed", comment: "")
                case .userEmailConfirmationOverload:
                    description = NSLocalizedString("Too many email confirmation requests! Please try again later.", comment: "")
                case .failedDueToUnconfirmedEmail:
                    description = NSLocalizedString("Operation failed due to unconfirmed email address.", comment: "")
                case .invalidCaptchaCode:
                    description = NSLocalizedString("Invalid Captcha Code! Please go back and re-enter the captcha code.", comment: "")
                case .errorDeletingCode:
                    description = NSLocalizedString("Something whent wrong, and we couldn't delete your profile. Please try again later.", comment: "")
                case .missingCaptchaCode:
                    description = NSLocalizedString("Missing captcha code!", comment: "")
                case .missingCaptchaId:
                    description = NSLocalizedString("Internal error: Missing captcha ID!", comment: "")
                case .jurneyNotStartedYet:
                    description = NSLocalizedString("User didn't start any jurney yet.", comment: "")
            }
            
        }
        
        let userInfo: [String : Any] = [
            NSLocalizedDescriptionKey : description as Any
        ]
        
        self.init(domain: domain, code: code, userInfo: userInfo)
    }
    
    class func createCancelAuthenticationError() -> NSError {
        return NSError(code: ErrorCodes.canceledAuthentication.rawValue, errorKey: ErrorKeys.canceledAuthentication.rawValue)
    }
    
}

enum ErrorCodes: Int, RawRepresentable {
    case canceledAuthentication = -1
    case noInternetConnection = -1009
}

enum ErrorKeys: String, RawRepresentable {
    
    case passwordShort = "password_short"
    case invalidEmailOrPassword = "invalid_email_password"
    case invalidGender = "invalid_gender"
    case invalidCountry = "invalid_country"
    case invalidBirthDay = "invalid_birthday"
    case invalidAvatar = "invalid_avatar"
    case userNotExist = "user_not_exist"
    
    case missingEmail = "missing_email"
    case invalidEmail = "invalid_email"
    case missingPassword = "missing_password"
    case emailAlreadyRegistered = "email_already_registered"
    case missignFBID = "missing_facebook_id"
    case missingFBToken = "missing_facebook_token"
    case missingGoogleID = "missing_google_id"
    case missingGoogleToken = "missing_google_token"
    case missingTwitterID = "missing_twitter_id"
    case missingTwitterToken = "missing_twitter_token"
    case missingTwitterTokenSecret = "missing_twitter_token_secret"
    
    case canceledAuthentication = "canceled_authentication_by_the_user"
    case userCannotWithdraw = "user_cannot_withdraw"
    
    case userEmailConfirmed = "user_already_confirmed"
    case userEmailConfirmationOverload = "too_many_requests"
    
    case failedDueToUnconfirmedEmail = "email_not_confirmed"
    case invalidCaptchaCode = "invalid_captcha_code"
    case errorDeletingCode = "error_deleting_user"
    case missingCaptchaId = "missing_captcha_id"
    case missingCaptchaCode = "missing_captcha_code"
    
    case jurneyNotStartedYet = "not_started_yet"
}
