//
//  GoalData.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 9.10.17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import Foundation

struct GoalData: Codable {
    
    var id: String
    var title: String
    var description: String
    var reward: Int
    var completed: Bool
    
}
