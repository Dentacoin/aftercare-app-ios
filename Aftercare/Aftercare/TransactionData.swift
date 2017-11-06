//
//  TransactionData.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 9.10.17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import Foundation

struct TransactionData: Codable {
    
    var amount: Int
    var wallet: String
    var status: TransactionStatusType?
    var date: Date?
    
    init(amount: Int, wallet: String) {
        self.amount = amount
        self.wallet = wallet
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: TransactionKeys.self)
        self.amount = try values.decode(Int.self, forKey: .amount)
        self.wallet = try values.decode(String.self, forKey: .wallet)
        self.status = try values.decode(TransactionStatusType?.self, forKey: .status)
        self.date = try values.decode(Date?.self, forKey: .date)
    }

    func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: TransactionKeys.self)
        try! container.encode(self.amount, forKey: .amount)
        try! container.encode(self.wallet, forKey: .wallet)
        
        if let status = self.status {
            try! container.encode(status, forKey: .status)
        }
        
        if let date = self.date {
            try! container.encode(date, forKey: .date)
        }
    }
    
    fileprivate enum TransactionKeys: String, CodingKey {
        case amount
        case wallet
        case status
        case date
    }
    
    enum TransactionStatusType: String, Codable {
        case pending = "pending approval"
        case approved
        case declined
    }
}
