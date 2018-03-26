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
//        let now = Date()
//        let calendar = Calendar.current
//        let components = calendar.dateComponents([.hour], from: now)
//        if let hour = components.hour {
//
//            if hour >= 2, hour <= 11 {
                return Routine(startHour: 2, toEndHour: 11, withActions: [.brush, .rinsed], .morning)
//            } else if hour >= 17, hour <= 24 {
//                return Routine(startHour: 17, toEndHour: 24, withActions: [.flossed, .brush, .rinsed], .evening)
//            }
//        }
//        return nil
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
            return NSLocalizedString("Routine Completed", comment: "")
        }
    }
    
    var startDescription: String {
        switch self.type {
            case .evening:
                return NSLocalizedString("Good evening, darling. Did you have a good day? Are you on the way to becoming a legend?", comment: "")
            case .morning:
                return NSLocalizedString("Good morning sunshine. It is a beautiful day. Let’s get you started properly.", comment: "")
        }
    }
    
    var endDescription: String {
        switch self.type {
            case .evening:
                return NSLocalizedString("You have completed your last brush for the day. Amazing job! Have a nice rest and come back in the morning. Sweet dreams.", comment: "")
            case .morning:
                return NSLocalizedString("Congratulations!\nNow you are ready to Amaze the world with your beautiful smile.\n\nMake big things today and come back in the evening before going to bed.\n\nHave a nice day ahead.", comment: "")
        }
    }
    
    var startButtonTitle: String {
        get {
            switch self.type {
                case .evening:
                    return NSLocalizedString("Start Evening Routine", comment: "")
                case .morning:
                    return NSLocalizedString("Start Morning Routine", comment: "")
            }
        }
    }
    
}

