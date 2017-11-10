//
// Aftercare
// Created by Dimitar Grudev on 7.11.17.
// Copyright © 2017 Stichting Administratiekantoor Dentacoin.
//

import Foundation

struct Routine {
    
    static func getRoutineForNow() -> RoutineType? {
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour], from: now)
        if let hour = components.hour {
            
            //if hour >= 2, hour <= 11 {
                return RoutineType(startHour: 2, toEndHour: 11, withActions: [ActionRecordType.brush, ActionRecordType.rinsed])
//            } else if hour >= 17, hour <= 24 {
//                return RoutineType(startHour: 17, toEndHour: 24, withActions: [ActionRecordType.flossed, ActionRecordType.brush, ActionRecordType.rinsed])
//            }
        }
        return nil
    }
    
}

struct RoutineType {
    
    var startHour: Int = 0
    var endHour: Int = 0
    var actions: [ActionRecordType] = []
    
    init(startHour start: Int, toEndHour end: Int, withActions actions: [ActionRecordType]) {
        self.startHour = start
        self.endHour = end
        self.actions = actions
    }
}
