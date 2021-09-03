//
//  AuthenticationRequests.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 13.10.17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import Foundation

class FacebookRequestData: Encodable, AuthenticationRequestProtocol {
    
    var email: String
    var facebookID: String
    var facebookAccessToken: String
    var firstName: String?
    var lastName: String?
    var gender: GenderType?
    var avatar64: String?
    var consent: Bool?
    
    init(email: String, id: String, token: String) {
        self.email = email
        self.facebookID = id
        self.facebookAccessToken = token
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: FacebookRequestKeys.self)
        
        try! container.encode(self.email, forKey: .email)
        try! container.encode(self.facebookID, forKey: .facebookID)
        try! container.encode(self.facebookAccessToken, forKey: .facebookAccessToken)
        
        if let firstName = self.firstName {
            try! container.encode(firstName, forKey: .firstName)
        }
        if let lastName = self.lastName {
            try! container.encode(lastName, forKey: .lastName)
        }
        if let gender = self.gender {
            try! container.encode(gender, forKey: .gender)
        }
        
    }
    
    enum FacebookRequestKeys: String, CodingKey {
        case email
        case facebookID
        case facebookAccessToken
        case firstName = "firstname"
        case lastName = "lastname"
        case gender
        case avatar64 = "avatar_64"
        case consent
    }
}

class AppleRequestData: Encodable, AuthenticationRequestProtocol {
    
   // var email: String?
    var appleLoginId: String
    //var appleAccessToken: String?
    var firstName: String?
    var lastName: String?
    var gender: GenderType?
    var avatar64: String?
    var consent: Bool?
    
    init( id: String) {
        //self.email = email
        self.appleLoginId = id
       // self.appleAccessToken = token
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: AppleRequestKeys.self)
        
       // try! container.encode(self.email, forKey: .email)
        try! container.encode(self.appleLoginId, forKey: .appleLoginId)
       // try! container.encode(self.appleAccessToken, forKey: .appleAccessToken)
        
        if let firstName = self.firstName {
            try! container.encode(firstName, forKey: .firstName)
        }
        if let lastName = self.lastName {
            try! container.encode(lastName, forKey: .lastName)
        }
        if let gender = self.gender {
            try! container.encode(gender, forKey: .gender)
        }
        
    }
    
    enum AppleRequestKeys: String, CodingKey {
        //case email
        case appleLoginId
       // case appleAccessToken
        case firstName = "firstname"
        case lastName = "lastname"
        case gender
        case avatar64 = "avatar_64"
        case consent
    }
}


class TwitterRequestData: Encodable, AuthenticationRequestProtocol {
    
    var email: String
    var twitterID: String
    var twitterAccessToken: String
    var twitterAccessTokenSecret: String
    var firstName: String?
    var lastName: String?
    var gender: GenderType?
    var avatar64: String?
    var consent: Bool?
    
    init(email: String, id: String, token: String, secret: String) {
        self.email = email
        self.twitterID = id
        self.twitterAccessToken = token
        self.twitterAccessTokenSecret = secret
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: TwitterRequestKeys.self)
        
        try! container.encode(self.email, forKey: .email)
        try! container.encode(self.twitterID, forKey: .twitterID)
        try! container.encode(self.twitterAccessToken, forKey: .twitterAccessToken)
        try! container.encode(self.twitterAccessTokenSecret, forKey: .twitterAccessTokenSecret)
        
        if let firstName = self.firstName {
            try! container.encode(firstName, forKey: .firstName)
        }
        if let lastName = self.lastName {
            try! container.encode(lastName, forKey: .lastName)
        }
        if let gender = self.gender {
            try! container.encode(gender, forKey: .gender)
        }
        if let consent = self.consent {
            try! container.encode(consent, forKey: .consent)
        }
    }
    
    enum TwitterRequestKeys: String, CodingKey {
        case email
        case twitterID
        case twitterAccessToken
        case twitterAccessTokenSecret
        case firstName = "firstname"
        case lastName = "lastname"
        case gender
        case avatar64 = "avatar_64"
        case consent
    }
}

class GoogleRequestData: Encodable, AuthenticationRequestProtocol {
    var email: String
    var googleID: String
    var googleAccessToken: String
    var firstName: String?
    var lastName: String?
    var gender: GenderType?
    var avatar64: String?
    var consent: Bool?
    
    init(email: String, id: String, token: String) {
        self.email = email
        self.googleID = id
        self.googleAccessToken = token
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: GoogleRequestKeys.self)
        
        try! container.encode(self.email, forKey: .email)
        try! container.encode(self.googleID, forKey: .googleID)
        try! container.encode(self.googleAccessToken, forKey: .googleAccessToken)
        
        if let firstName = self.firstName {
            try! container.encode(firstName, forKey: .firstName)
        }
        if let lastName = self.lastName {
            try! container.encode(lastName, forKey: .lastName)
        }
        if let gender = self.gender {
            try! container.encode(gender, forKey: .gender)
        }
        if let consent = self.consent {
            try! container.encode(consent, forKey: .consent)
        }
    }
    
    enum GoogleRequestKeys: String, CodingKey {
        case email
        case googleID
        case googleAccessToken
        case firstName = "firstname"
        case lastName = "lastname"
        case gender
        case avatar64 = "avatar_64"
        case consent
    }
    
}

class EmailRequestData: Encodable, AuthenticationRequestProtocol {
    
    var email: String
    var password: String
    var firstName: String?
    var lastName: String?
    var gender: GenderType?
    var avatar64: String?
    var captchaCode: String?
    var captchaId: Int?
    var consent: Bool?
    
    init(email: String, password: String) {
        self.email = email
        self.password = password
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: EmailRequestKeys.self)
        
        try! container.encode(self.email, forKey: .email)
        try! container.encode(self.password, forKey: .password)
        
        if let firstName = self.firstName {
            try! container.encode(firstName, forKey: .firstName)
        }
        if let lastName = self.lastName {
            try! container.encode(lastName, forKey: .lastName)
        }
        if let gender = self.gender {
            try! container.encode(gender, forKey: .gender)
        }
        if let avatar = self.avatar64 {
            try! container.encode(avatar, forKey: .avatar64)
        }
        if let captchaCode = self.captchaCode {
            try! container.encode(captchaCode, forKey: .captchaCode)
        }
        if let captchaId = self.captchaId {
            try! container.encode(captchaId, forKey: .captchaId)
        }
        if let consent = self.consent {
            try! container.encode(consent, forKey: .consent)
        }
    }
    
    enum EmailRequestKeys: String, CodingKey {
        case email
        case password
        case firstName = "firstname"
        case lastName = "lastname"
        case gender
        case avatar64 = "avatar_64"
        case captchaCode
        case captchaId
        case consent
    }
    
}

//MARK: - Protocols

protocol AuthenticationRequestProtocol {
    var firstName: String? { get set }
    var lastName: String? { get set }
    var gender: GenderType? { get set }
    var avatar64: String? { get set }
    var consent: Bool? { get set }
}
