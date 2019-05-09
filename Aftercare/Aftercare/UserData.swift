//
//  UserData.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 4.10.17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import Foundation

struct UserData: Codable {
    
    //MARK: - fileprivate vars
    
    var id: Int
    var email: String
    
    var firstName: String?
    var lastName: String?
    var gender = GenderType.unspecified
    var postalCode: String?
    var country: String?
    var city: String?
    var consent: Bool?
    var birthDay: String?
    var lastLoginDate: String?
    var createdDate: String?
    var lastModifiedDate: String?
    var confirmed: Bool = false
    var password: String?
    var avatar: AvatarData?
    var avatar_64: String?
    
    init(
        id: Int,
        email: String,
        firstName: String?,
        lastName: String?,
        gender: GenderType = .unspecified,
        postalCode: String? = nil,
        country: String? = nil,
        city: String? = nil,
        consent: Bool? = nil,
        birthDay: String? = nil,
        password: String? = nil,
        avatar_64: String? = nil
        ) {
        
        self.id = id
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.gender = gender
        self.postalCode = postalCode
        self.country = country
        self.city = city
        self.consent = consent
        self.birthDay = birthDay
        self.lastLoginDate = nil
        self.createdDate = nil
        self.lastModifiedDate = nil
        self.password = password
        self.avatar_64 = avatar_64
        self.avatar = nil
        
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: UserKeys.self)
        
        self.id = try! values.decode(Int.self, forKey: .id)
        self.email = try! values.decode(String.self, forKey: .email)
        
        do {
            self.firstName = try values.decode(String?.self, forKey: .firstName)
        } catch {
            print("Parsing Error: UserData :: firstName property is missing!")
        }
        
        do {
            self.lastName = try values.decode(String?.self, forKey: .lastName)
        } catch {
            print("Parsing Error: UserData :: lastName property is missing!")
        }
        
        do {
            self.gender = try values.decode(GenderType.self, forKey: .gender)
        } catch {
            print("Parsing Error: UserData :: gender property is missing!")
        }
        
        do {
            self.postalCode = try values.decode(String?.self, forKey: .postalCode)
        } catch {
            print("Parsing Error: UserData :: postalCode property is missing!")
        }
        
        do {
            self.country = try values.decode(String?.self, forKey: .country)
        } catch {
            print("Parsing Error: UserData :: country property is missing!")
        }
        
        do {
            self.city = try values.decode(String?.self, forKey: .city)
        } catch {
            print("Parsing Error: UserData :: city property is missing!")
        }
        
        do {
            self.consent = try values.decode(Bool?.self, forKey: .consent)
        } catch {
            print("Parsing Error: UserData :: consent property is missing!")
        }
        
        do {
            self.birthDay = try values.decode(String?.self, forKey: .birthDay)
        } catch {
            print("Parsing Error: UserData :: birthDay property is missing")
        }
        do {
            self.lastLoginDate = try values.decode(String?.self, forKey: .lastLoginDate)
        } catch {
            print("Parsing Error: UserData :: lastLoginDate property is missing")
        }
        do {
            self.createdDate = try values.decode(String?.self, forKey: .createdDate)
        } catch {
            print("Parsing Error: UserData :: createdDate property is missing")
        }
        do {
            self.lastModifiedDate = try values.decode(String?.self, forKey: .lastModifiedDate)
        } catch {
            print("Parsing Error: UserData :: lastModifiedDate property is missing")
        }
        do {
            self.confirmed = try values.decode(Bool.self, forKey: .confirmed)
        } catch {
            print("Parsing Error: UserData :: confirmed property is missing")
        }
        do {
            self.password = try values.decode(String?.self, forKey: .password)
        } catch {
            print("Parsing Error: UserData :: password property is missing")
        }
        
        self.avatar = try? values.decode(AvatarData.self, forKey: .avatar)
        
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: UserKeys.self)
        try! container.encode(self.id, forKey: .id)
        try! container.encode(self.email, forKey: .email)
        try! container.encode(self.firstName, forKey: .firstName)
        try! container.encode(self.lastName, forKey: .lastName)
        try! container.encode(self.gender, forKey: .gender)
        try! container.encode(self.birthDay, forKey: .birthDay)
        try! container.encode(self.postalCode, forKey: .postalCode)
        try! container.encode(self.country, forKey: .country)
        try! container.encode(self.city, forKey: .city)
        try! container.encode(self.consent, forKey: .consent)
        try! container.encode(self.lastLoginDate, forKey: .lastLoginDate)
        try! container.encode(self.createdDate, forKey: .createdDate)
        try! container.encode(self.lastModifiedDate, forKey: .lastModifiedDate)
        try! container.encode(self.confirmed, forKey: .confirmed)
        try! container.encode(self.password, forKey: .password)
        try! container.encode(self.avatar, forKey: .avatar)
    }
    
    fileprivate enum UserKeys: String, CodingKey {
        case id
        case firstName = "firstname"
        case lastName = "lastname"
        case gender
        case email
        case birthDay = "birthday"
        case postalCode
        case country
        case city
        case consent
        case lastLoginDate
        case createdDate
        case lastModifiedDate
        case confirmed
        case password
        case avatar
    }
}

extension UserData {
    
    func toUpdateUserRequestData() -> UpdateUserRequestData {
        
        return UpdateUserRequestData(
            firstName: firstName,
            lastName: lastName,
            gender: gender,
            birthDay: birthDay,
            postalCode: postalCode,
            country: country,
            city: city,
            password: password,
            consent: consent,
            avatarBase64: avatar_64
        )
    }
    
}

public enum GenderType: String, Codable {
    case male = "male"
    case female = "female"
    case unspecified = "unspecified"
}
