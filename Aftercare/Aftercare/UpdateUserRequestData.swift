//
//  UpdateUserRequestData.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 20.10.17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import Foundation

struct UpdateUserRequestData: Encodable {
    
    // TODO: I should deprecate this object and use the UserData object insted with custom encode method
    
    var firstName: String?
    var lastName: String?
    var gender: GenderType?
    var birthDay: String?
    var postalCode: String?
    var country: String?
    var city: String?
    var password: String?
    var consent: Bool?
    var avatarBase64: String?
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: UpdateUserRequestKeys.self)
        
        if let firstName = self.firstName {
            try! container.encode(firstName, forKey: .firstName)
        }
        
        if let lastName = self.lastName {
            try! container.encode(lastName, forKey: .lastName)
        }
        
        if let gender = self.gender {
            try! container.encode(gender, forKey: .gender)
        }
        
        if let birthDay = self.birthDay {
            try! container.encode(birthDay, forKey: .birthDay)
        }
        
        if let postalCode = self.postalCode {
            try! container.encode(postalCode, forKey: .postalCode)
        }
        
        if let country = self.country {
            try! container.encode(country, forKey: .country)
        }
        
        if let city = self.city {
            try! container.encode(city, forKey: .city)
        }
        
        if let consent = self.consent {
            try! container.encode(consent, forKey: .consent)
        }
        
        if let password = self.password {
            try! container.encode(password, forKey: .password)
        }
        
        if let avatarBase64 = self.avatarBase64 {
            try! container.encode(avatarBase64, forKey: .avatarBase64)
        }
    }
    
    fileprivate enum UpdateUserRequestKeys: String, CodingKey {
        case firstName = "firstname"
        case lastName = "lastname"
        case gender
        case birthDay = "birthday"
        case postalCode
        case country
        case city
        case password
        case consent
        case avatarBase64 = "avatar_64"
    }
    
}
