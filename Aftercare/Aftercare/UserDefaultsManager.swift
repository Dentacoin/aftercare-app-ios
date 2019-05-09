//
// Aftercare
// Created by Dimitar Grudev on 26.02.18.
// Copyright © 2018 Stichting Administratiekantoor Dentacoin.
//

import Foundation
import UIKit

class UserDefaultsManager {
    
    // MARK: - singleton
    
    static var shared =  UserDefaultsManager()
    
    fileprivate init() { }
    
    // MARK: - Fileprivates
    
    fileprivate let defaults = UserDefaults.standard
    
    fileprivate var userStorage: Dictionary<String, Any>?
    
    // MARK: - User data
    
    var userKey: String? {
        didSet {
            guard let key = userKey else {
                return
            }
            if defaults.value(forKey: key) == nil {
                defaults.setValue(Dictionary<String, Any>(), forKey: key)
            }
        }
    }
    
    // MARK: - clear key value
    
    func clearValue(forKey key: String) {
        guard var storage = userStorage else {
            return
        }
        guard let key = userKey else {
            return
        }
        storage[key] = nil
        defaults.setValue(storage, forKey: key)
        defaults.synchronize()
    }
    
    func clearGlobalValue(forKey key: String) {
        defaults.setValue(nil, forKey: key)
        defaults.synchronize()
    }
    
    // MARK: - getter and setter
    
    func setValue<T>(_ value: T, forKey key: String) {
        guard let userKey = userKey else {
            return
        }
        guard var storage = defaults.value(forKey: userKey) as? Dictionary<String, Any> else {
            return
        }
        storage[key] = value
        defaults.setValue(storage, forKey: userKey)
        defaults.synchronize()
    }
    
    func getValue<T>(forKey key: String) -> T? {
        guard let userKey = userKey else {
            return nil
        }
        guard var storage = defaults.value(forKey: userKey) as? Dictionary<String, Any> else {
            return nil
        }
        guard let value = storage[key] as? T else {
            return nil
        }
        return value
    }
    
    func getAllForUserKey(_ key: String) -> Dictionary<String, Any>? {
        return defaults.value(forKey: key) as? Dictionary<String, Any>
    }
    
    // MARK: - global variable
    
    func setGlobalValue<T>(_ value: T, forKey key: String) {
        defaults.setValue(value, forKey: key)
        defaults.synchronize()
    }
    
    func getGlobalValue<T>(forKey key: String) -> T? {
        return defaults.value(forKey: key) as? T
    }
    
}
