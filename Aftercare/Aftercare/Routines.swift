//
// Aftercare
// Created by Dimitar Grudev on 7.11.17.
// Copyright © 2017 Stichting Administratiekantoor Dentacoin.
//

import Foundation
import Disk

struct Routines {
    
    fileprivate static let localFileName = "routineRecords.json"
    
    static func getRoutineForNow() -> Routine? {
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour], from: now)
        if let hour = components.hour {

            if hour >= 2, hour <= 11 {
                return Routine(startHour: 2, toEndHour: 11, withActions: [.brush, .rinsed], .morning)
            } else if hour >= 17, hour <= 24 {
                return Routine(startHour: 17, toEndHour: 24, withActions: [.flossed, .brush, .rinsed], .evening)
            }
        }
        return nil
    }
    
    // MARK: - Local Persist methods
    
    // TODO: - Move all persistent methods in a protocol
    
    static func save(_ record: RoutineData) {
        guard var records = getAllSaved() else {
            internalSave([record])
            return
        }
        records.append(record)
        internalSave(records)
    }
    
    static func getAllSaved() -> [RoutineData]? {
        //try to load from local persistent storage
        do {
            let records = try Disk.retrieve(localFileName, from: .caches, as: [RoutineData].self)
            return records
        } catch {
            print("Error: Disk faild to load \(localFileName) from local caches :: \(error)")
        }
        return nil
    }
    
    static func deleteAllSaved() {
        do {
            try Disk.remove(localFileName, from: .caches)
        } catch {
            print("Error: Disk faild to remove \(localFileName) from local caches :: \(error)")
        }
    }
    
    //MARK: - Internal API
    
    fileprivate static func internalSave(_ records: [RoutineData]) {
        do {
            try Disk.save(records, to: .caches, as: localFileName)
        } catch {
            print("Error: Disk faild to save to \(localFileName) in local caches :: \(error)")
        }
    }
    
}

struct Routine {
    
    var startHour: Int = 0
    var endHour: Int = 0
    var type: RoutineType = .morning
    var actions: [ActionRecordType] = []
    
    init(startHour start: Int, toEndHour end: Int, withActions actions: [ActionRecordType], _ type: RoutineType) {
        self.startHour = start
        self.endHour = end
        self.actions = actions
        self.type = type
    }
    
    var endTitle: String {
        get {
            return "message_hdl_routine_completed".localized()
        }
    }
    
    var startDescription: String {
        switch self.type {
            case .evening:
                return "message_evening_routine_start".localized()
            case .morning:
                return "message_morning_routine_start".localized()
        }
    }
    
    var endDescription: String {
        switch self.type {
            case .evening:
                return "message_evening_routine_end".localized()
            case .morning:
                return "message_morning_routine_end".localized()
        }
    }
    
    var startButtonTitle: String {
        get {
            switch self.type {
                case .evening:
                    return "btn_evening".localized()
                case .morning:
                    return "btn_morning".localized()
            }
        }
    }
    
}

