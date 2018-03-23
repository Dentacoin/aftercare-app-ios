//
// Aftercare
// Created by Dimitar Grudev on 28.11.17.
// Copyright © 2017 Stichting Administratiekantoor Dentacoin.
//

import Foundation
import Disk

class ActionRecord {
    
    // TODO: - Move all persistent methods in a protocol
    
    fileprivate static let localFileName = "actionRecords.json"
    
    static func save(_ record: ActionRecordData) {
        guard var records = getAllSaved() else {
            internalSave([record])
            return
        }
        records.append(record)
        internalSave(records)
    }
    
    static func getAllSaved() -> [ActionRecordData]? {
        //try to load from local persistent storage
        do {
            let records = try Disk.retrieve(localFileName, from: .caches, as: [ActionRecordData].self)
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
    
    fileprivate static func internalSave(_ records: [ActionRecordData]) {
        do {
            try Disk.save(records, to: .caches, as: localFileName)
        } catch {
            print("Error: Disk faild to save to \(localFileName) in local caches :: \(error)")
        }
    }
    
}
