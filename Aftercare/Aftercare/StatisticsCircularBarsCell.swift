//
//  StatisticsCircularBarsCell.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 9/16/17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import Foundation
import UIKit

class StatisticsCircularBarsCell: UITableViewCell {
    
    @IBOutlet weak var actionsTakenBar: SmallCircularBar!
    @IBOutlet weak var timeLeftBar: SmallCircularBar!
    @IBOutlet weak var averageTimeBar: SmallCircularBar!
    
}

extension StatisticsCircularBarsCell: StatisticsTableViewCellProtocol {
    
    func setupAppearance() {
        
        actionsTakenBar.changeStyle(.light)
        timeLeftBar.changeStyle(.light)
        averageTimeBar.changeStyle(.light)
        
    }
    
}
