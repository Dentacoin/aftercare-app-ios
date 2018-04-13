//
//  DashboardActionData.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 9.10.17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import Foundation

struct ActionScreenData: Codable {

    public var earnedDCN: Int
    public var pendingDCN: Int
    public var flossed: ActionDashboardData
    public var brush: ActionDashboardData
    public var rinsed: ActionDashboardData
    
    init(earnedDCN: Int, pendingDCN: Int, flossed: ActionDashboardData, brush: ActionDashboardData, rinsed: ActionDashboardData) {
        self.earnedDCN = earnedDCN
        self.pendingDCN = pendingDCN
        self.flossed = flossed
        self.brush = brush
        self.rinsed = rinsed
    }
    
}

//MARK: - Sub structs that ActionScreenData holds

struct ActionDashboardData: Codable {
    
    public var left: Int = 0
    public var earned: Int = 0
    public var daily: ScheduleData
    public var weekly: ScheduleData
    public var monthly: ScheduleData
    public var lastTime: Int = 0
    
    init(left: Int, earned: Int, daily: ScheduleData, weekly: ScheduleData, monthly: ScheduleData) {
        self.init(left: left, earned: earned, daily: daily, weekly: weekly, monthly: monthly, lastTime: 0)
    }
    
    init(left: Int, earned: Int, daily: ScheduleData, weekly: ScheduleData, monthly: ScheduleData, lastTime: Int?) {
        self.left = left
        self.earned = earned
        self.daily = daily
        self.weekly = weekly
        self.monthly = monthly
        if let last = lastTime {
            self.lastTime = last
        }
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: ActionDashboardKeys.self)
        
        do {
            self.left = try values.decode(Int.self, forKey: .left)
        } catch {
            print("Parsing Error: ActionDashboardData :: left property is missing!")
        }
        
        do {
            self.earned = try values.decode(Int.self, forKey: .earned)
        } catch {
            print("Parsing Error: ActionDashboardData :: earned property is missing!")
        }
        
        self.daily = try values.decode(ScheduleData.self, forKey: .daily)
        self.weekly = try values.decode(ScheduleData.self, forKey: .weekly)
        self.monthly = try values.decode(ScheduleData.self, forKey: .monthly)
        
        do {
            self.lastTime = try values.decode(Int.self, forKey: .lastTime)
        } catch {
            print("Parsing Error: ActionDashboardData :: lastTime property is missing!")
        }
        
    }
    
    enum ActionDashboardKeys: String, CodingKey {
        case left
        case earned
        case daily
        case weekly
        case monthly
        case lastTime
    }
    
}

struct ScheduleData: Codable {
    
    public var times: Int
    public var left: Int
    public var average: Int
    
    init(times: Int, left: Int, average: Int) {
        self.times = times
        self.left = left
        self.average = average
    }
    
}

