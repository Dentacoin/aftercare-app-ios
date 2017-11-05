//
//  UserSessionData.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 11.10.17.
//  Copyright © 2017 Dimitar Grudev. All rights reserved.
//

import Foundation

struct UserSessionData: Decodable {
    
    var token: String
    var validTo: String
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: UserSessionKeys.self)
        self.token = try values.decode(String.self, forKey: .token)
        self.validTo = try values.decode(String.self, forKey: .validTo)
    }
    
    enum UserSessionKeys: String, CodingKey {
        case token
        case validTo = "token_valid_to"
    }
    
}
