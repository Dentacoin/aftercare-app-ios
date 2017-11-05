//
//  StatisticsLabelCell.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 9/16/17.
//  Copyright © 2017 Dimitar Grudev. All rights reserved.
//

import Foundation
import UIKit

class StatisticsLabelCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var lineView: UIView!
    
    //MARK: - Public api
    
}

extension StatisticsLabelCell: StatisticsTableViewCellProtocol {
    
    func setupAppearance() {
        
        lineView.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        
        titleLabel.textColor = .white
        titleLabel.font = UIFont.dntLatoRegularFontWith(size: UIFont.dntLargeTextSize)
        
    }
    
}
