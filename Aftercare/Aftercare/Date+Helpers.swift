//
// Aftercare
// Created by Dimitar Grudev on 28.02.18.
// Copyright © 2018 Stichting Administratiekantoor Dentacoin.
//

import Foundation

extension Date {
    
    // MARK: - If given minutes are passed since given date
    
    static func passedMinutes(_ minutes: Int, fromDate date: Date) -> Bool {
        let calendar = Calendar.current
        guard let laterDate = calendar.date(byAdding: .minute, value: minutes, to: date) else {
            return false
        }
        let now = Date()
        if now > laterDate {
            return true
        }
        return false
    }
    
    // MARK: - How many days are passed since given date
    // If the date is in the future, then negative number is returned
    
    static func passedDaysSince(_ date: Date) -> Int {
        let calendar = Calendar.current
        let componentsSet = Set<Calendar.Component>([.day])
        let now = Date()
        let result = calendar.dateComponents(componentsSet, from: date, to: now)
        guard let days = result.day else {
            return -1
        }
        return days
    }
    
}
