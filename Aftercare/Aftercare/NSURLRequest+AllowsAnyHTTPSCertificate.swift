//
//  NSURLRequest+AllowsAnyHTTPSCertificate.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 2.11.17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import Foundation

extension NSURLRequest {
    static func allowsAnyHTTPSCertificate(forHost host: String) -> Bool {
        //you can restrict or allow only sertain domains only from here
        //print("HOST: \(host)")
        return true
    }
}

