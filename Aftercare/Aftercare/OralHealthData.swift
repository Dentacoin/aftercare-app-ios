//
//  OralHealthData.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 5.10.17.
//  Copyright © 2017 Dimitar Grudev. All rights reserved.
//

import Foundation

struct OralHealthData: Decodable {
    
    var title: String?
    var description: String?
    var imageURL: URL?
    var contentURL: URL?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: OralHealthKeys.self)
        self.title = try values.decode(String?.self, forKey: .title)
        self.description = try values.decode(String?.self, forKey: .description)
        self.imageURL = try values.decode(URL?.self, forKey: .imageURL)
        self.contentURL = try values.decode(URL?.self, forKey: .contentURL)
    }
    
    fileprivate enum OralHealthKeys: String, CodingKey {
        case title
        case description
        case imageURL
        case contentURL = "url"
    }
}


