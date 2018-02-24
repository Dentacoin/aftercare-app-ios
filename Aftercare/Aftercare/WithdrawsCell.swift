//
// Aftercare
// Created by Dimitar Grudev on 24.02.18.
// Copyright © 2018 Stichting Administratiekantoor Dentacoin.
//

import Foundation
import UIKit

class WithdrawsCell: UITableViewCell {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    // MARK: - Configuration
    
    func config(_ data: TransactionData) {
        
        // config value label
        
        valueLabel.font = UIFont.dntLatoLightFont(size: UIFont.dntLargeTextSize)
        valueLabel.textColor = UIColor.dntCeruleanBlue
        valueLabel.text = "DCN \(data.amount)"
        
        statusLabel.font = UIFont.dntLatoLightFont(size: UIFont.dntLargeTextSize)
        
        // config status label
        if let status = data.status {
            switch status {
                case .approved:
                    statusLabel.textColor = .dntDarkGreen
                    statusLabel.text = NSLocalizedString("Approved", comment: "")
                case .declined:
                    statusLabel.textColor = .red
                    statusLabel.text = NSLocalizedString("Declined", comment: "")
                case .pending:
                    statusLabel.textColor = .red
                    statusLabel.text = NSLocalizedString("Pending", comment: "")
            }
        }
        // config description
        
        descriptionLabel.font = UIFont.dntLatoLightFont(size: UIFont.dntLabelFontSize)
        
        if let date = data.date {
            let readableDate = DateFormatter.humanReadableFormat.string(from: date)
            descriptionLabel.text = "to: \n\(data.wallet) \n\(readableDate)"
        } else {
            descriptionLabel.text = "to: \n\(data.wallet) \n"
        }
        
    }
    
}
