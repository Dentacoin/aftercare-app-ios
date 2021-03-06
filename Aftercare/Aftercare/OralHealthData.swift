//
//  OralHealthData.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 5.10.17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import Foundation

struct OralHealthData: Decodable {
    
    var title: String
    var description: String?
    var imageURL: String?
    var contentURL: String?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: OralHealthKeys.self)
        
        self.title = try values.decode(String.self, forKey: .title)
        
        do {
            self.description = try values.decode(String?.self, forKey: .description)
        } catch {
            print("Parsing Error: OralHealthData ::  trying to parse description")
        }
        
        do {
            self.imageURL = try values.decode(String?.self, forKey: .imageURL)
        } catch {
            print("Parsing Error: OralHealthData ::  trying to parse imageURL")
        }
        
        do {
            self.contentURL = try values.decode(String?.self, forKey: .contentURL)
        } catch {
            print("Parsing Error: OralHealthData ::  trying to parse contentURL")
        }
    }
    
    fileprivate enum OralHealthKeys: String, CodingKey {
        case title
        case description
        case imageURL
        case contentURL = "url"
    }
}


