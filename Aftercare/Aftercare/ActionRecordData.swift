//
//  ActionRecordData.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 9.10.17.
//  Copyright © 2017 Dimitar Grudev. All rights reserved.
//

import Foundation

struct ActionRecordData: Encodable {
    
    var startTime: String
    var endTime: String
    var type: ActionRecordType
    
}

public enum ActionRecordType: String, Codable {
    case flossed
    case rinsed
    case brush
}
