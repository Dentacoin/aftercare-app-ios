//
// Aftercare
// Created by Dimitar Grudev on 27.02.18.
// Copyright © 2018 Stichting Administratiekantoor Dentacoin.
//

import Foundation

struct RoutineData: Codable {
    
    var startTime: String
    var type: RoutineType
    
    var endTime: String?
    var earnedDCN: Int?
    var records: [ActionRecordData]?
    
    // MARK: - Constructors
    
    init(startTime: Date, type: RoutineType) {
        self.startTime = startTime.description(with: Locale.autoupdatingCurrent)
        self.type = type
    }
    
    // MARK: - Codable
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: RoutineDataKeys.self)
        
        self.startTime = try values.decode(String.self, forKey: .startTime)
        self.type = try values.decode(RoutineType.self, forKey: .type)
        
        if let endTime = try values.decode(String?.self, forKey: .endTime) {
            self.endTime = endTime
        }
        
        if let earnedDCN = try values.decode(Int?.self, forKey: .earnedDCN) {
            self.earnedDCN = earnedDCN
        }
        
        if let records = try values.decode([ActionRecordData]?.self, forKey: .records) {
            self.records = records
        }
    }
    
    func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: RoutineDataKeys.self)
        try! container.encode(self.startTime, forKey: .startTime)
        try! container.encode(self.type, forKey: .type)
        try! container.encode(self.endTime, forKey: .endTime)
        try! container.encode(self.earnedDCN, forKey: .earnedDCN)
        try! container.encode(self.records, forKey: .records)
        
    }
    
    // MARK: - Codable keys
    
    fileprivate enum RoutineDataKeys: String, CodingKey {
        case startTime
        case type
        case endTime
        case earnedDCN
        case records
    }
}
