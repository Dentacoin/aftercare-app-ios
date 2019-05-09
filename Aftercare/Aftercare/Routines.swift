//
// Aftercare
// Created by Dimitar Grudev on 7.11.17.
// Copyright © 2017 Stichting Administratiekantoor Dentacoin.
//

import Foundation
import Disk

struct Routines {
    
    fileprivate static let localFileName = "routineRecords.json"
    
    static let morningInterval = 5...11
    static let dayInterval = 12...16
    static let eveningInterval = 17...23//this includes 23:59 but not 24:00 as it should be
    
    static func getRoutineForNow() -> Routine? {
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour], from: now)
        if let hour = components.hour {
            if morningInterval.contains(hour) {
                return Routine(hour, withActions: [.brush, .rinsed], .morning)
            } else if eveningInterval.contains(hour) {
                return Routine(hour, withActions: [.flossed, .brush, .rinsed], .evening)
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
    
    var currentHour: Int = 0
    var type: RoutineType = .morning
    var actions: [ActionRecordType] = []
    
    init(_ currentHour: Int, withActions actions: [ActionRecordType], _ type: RoutineType) {
        self.currentHour = currentHour
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
            if currentHour < 12 {
                return "message_morning_routine_start".localized()
            } else {
                return "message_day_routine_start".localized()
            }
            default:
                return ""
        }
    }
    
    var endDescription: String {
        switch self.type {
            case .evening:
            return "message_evening_routine_end".localized()
            case .morning:
            return "message_morning_routine_end".localized()
            default:
                return ""
        }
    }
    
    var startButtonTitle: String {
        get {
            switch self.type {
                case .evening:
                return "btn_evening".localized()
                case .morning:
                if currentHour < 12 {
                    return "btn_morning".localized()
                } else {
                    return "btn_routine".localized()
                }
                default:
                    return ""
            }
        }
    }
    
}

