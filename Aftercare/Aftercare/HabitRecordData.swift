//
//  HabitRecordData.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 9.10.17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import Foundation

struct HabitRecordData: Decodable {
    
    var type: HabitType
    var date: Date?//TODO: make sure this Date object should be Date or a String
    
    enum HabitType: String, Codable {
        case wakeup
        case gotobed
        case brush
        case rinse
    }
}
