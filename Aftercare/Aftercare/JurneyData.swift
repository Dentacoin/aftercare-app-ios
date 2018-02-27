//
// Aftercare
// Created by Dimitar Grudev on 27.02.18.
// Copyright © 2018 Stichting Administratiekantoor Dentacoin.
//

import Foundation

struct JurneyData: Codable {
    
    var startDate: String
    var targetDays: Int
    var tolerance: Int
    var completed: Bool
    var day: Int
    var skipped: Int
    var lastRoutine: [RoutineData]?
    
}
