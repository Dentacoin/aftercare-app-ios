//
//  HabitRecordData.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 9.10.17.
//  Copyright © 2017 Dimitar Grudev. All rights reserved.
//

import Foundation

struct HabitRecordData: Decodable {
    
    var type: HabitType
    var date: Date?
    
    enum HabitType: String, Codable {
        case wakeup
        case gotobed
        case brush
        case rinse
    }
}
