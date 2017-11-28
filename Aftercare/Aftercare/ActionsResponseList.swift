//
//  ActionsResponseList.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 11.10.17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import Foundation

struct ActionsResponseList: Decodable {
    
    var success: [ActionRecordData]
    var failed: [FailedActionRecordData]
    
}

struct FailedActionRecordData: Decodable {
    
    var record: ActionRecordData
    var error: ErrorData
    
}
