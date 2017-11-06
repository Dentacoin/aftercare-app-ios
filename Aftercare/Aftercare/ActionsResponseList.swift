//
//  ActionsResponseList.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 11.10.17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import Foundation

struct ActionsResponseList: Decodable {
    
    var successRecords: [ActionData]
    var failedRecords: [FailedActionRecordData]
    
}

struct FailedActionRecordData: Decodable {
    
    var record: ActionData
    var error: ErrorData
    
}
