//
// Aftercare
// Created by Dimitar Grudev on 27.02.18.
// Copyright © 2018 Stichting Administratiekantoor Dentacoin.
//

import Foundation

struct RoutineData: Codable {
    
    var startTime: String
    var endTime: String
    var earnedDCN: Int
    var type: RoutineType
    var records: [ActionRecordData]?
    
}

// MARK: - Routine Type

enum RoutineType: String, Codable {
    case morning
    case evening
}
