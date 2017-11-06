//
//  ActionData.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 10.10.17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import Foundation

struct ActionData: Decodable {
    
    var startTime: String
    var endTime: String
    var type: ActionRecordType
    var earnedDCN: Int
    
}
