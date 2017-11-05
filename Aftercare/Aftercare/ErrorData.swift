//
//  ErrorData.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 11.10.17.
//  Copyright © 2017 Dimitar Grudev. All rights reserved.
//

import Foundation

struct ErrorData: Codable {
    
    var code: Int
    var errors: [String]
    
    func toNSError() -> NSError {
        return NSError(code: code, errorKey: errors.first ?? "")
    }
    
}
