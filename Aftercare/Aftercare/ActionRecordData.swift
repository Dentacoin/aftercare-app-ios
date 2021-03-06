//
//  ActionRecordData.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 9.10.17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import Foundation

struct ActionRecordData: Codable {
    
    var startTime: String
    var endTime: String
    var type: ActionRecordType
    
    init(startTime: String, endTime: String, type: ActionRecordType) {
        self.startTime = startTime
        self.endTime = endTime
        self.type = type
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: ActionRecordKey.self)
        self.startTime = try values.decode(String.self, forKey: .startTime)
        self.endTime = try values.decode(String.self, forKey: .endTime)
        self.type = try values.decode(ActionRecordType.self, forKey: .type)
        
    }
    
    func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: ActionRecordKey.self)
        try! container.encode(self.startTime, forKey: .startTime)
        try! container.encode(self.endTime, forKey: .endTime)
        try! container.encode(self.type, forKey: .type)
    }
    
    enum ActionRecordKey: CodingKey {
        case startTime
        case endTime
        case type
    }
}

public enum ActionRecordType: String, Codable {
    case flossed
    case rinsed
    case brush
}
