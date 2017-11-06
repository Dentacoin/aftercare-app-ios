//
//  Dictionary+Helpers.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 9/4/17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import Foundation

class DictionaryUtil {
    
    static func convertToDictionary<T>(_ text: String) -> [String: T]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as?  [String: T]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
}
