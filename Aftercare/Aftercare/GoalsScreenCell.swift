//
//  GoalsScreenCell.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 9/17/17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import Foundation
import UIKit

class GoalsScreenCell: UICollectionViewCell {
    
    @IBOutlet weak var ovalImage: UIImageView!
    @IBOutlet weak var toothImage: UIImageView!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var starImage: UIImageView!
    
    @IBOutlet weak var title: UILabel!
    
    fileprivate var data: GoalData?
}

//MARK: - Theme & appearance

extension GoalsScreenCell {
    
    func config(_ data: GoalData) {
        
        self.data = data
        
        self.title.textColor = .dntCharcoalGrey
        self.title.font = UIFont.dntLatoLightFont(size: UIFont.dntMainMenuLabelFontSize)
        
        numberLabel.textColor = .white
        numberLabel.font = UIFont.dntLatoBlackFont(size: 60)
        numberLabel.adjustsFontSizeToFitWidth = true
        
        title.text = data.title
        
        let completed = self.data?.completed ?? false
        
        if completed {
            achievedIconStyle()
        } else {
            unachievedIconStyle()
        }
    }
    
    fileprivate func achievedIconStyle() {
        
        guard let id = self.data?.id else { return }
        let colorStyle: GoalColors = self.getColorStyle(byID: id)
        
        if colorStyle == GoalColors.purple {
            toothImage.image = UIImage(named: "tooth-" + colorStyle.rawValue)
            numberLabel.text = ""
        } else {
            toothImage.image = nil
            numberLabel.text = id.getGoalLabel()
        }
        
        title.textColor = UIColor.dntCeruleanBlue
        
        starImage.image = UIImage(named: "star-" + colorStyle.rawValue)
        ovalImage.image = UIImage(named: "oval-" + colorStyle.rawValue)
                
    }
    
    fileprivate func unachievedIconStyle() {
        
        guard let id = self.data?.id else { return }
        
        let firstGoal = id.contains(GoalStyles.first.rawValue)
        if firstGoal {
            toothImage.image = UIImage(named: "tooth-" + GoalColors.gray.rawValue)
            numberLabel.text = ""
        } else {
            toothImage.image = nil
            numberLabel.text = id.getGoalLabel()
        }
        
        title.textColor = UIColor.black
        
        starImage.image = nil
        ovalImage.image = UIImage(named: "oval-" + GoalColors.gray.rawValue)
        
    }
    
    fileprivate func getColorStyle(byID id: String) -> GoalColors {
        if id.contains(GoalStyles.first.rawValue) { return GoalColors.purple }
        if id.contains(GoalStyles.week.rawValue) { return GoalColors.green }
        if id.contains(GoalStyles.month.rawValue) { return GoalColors.blue }
        if id.contains(GoalStyles.year.rawValue) { return GoalColors.yellow }
        return GoalColors.gray
    }
    
}

//MARK: - String Helpers

fileprivate extension String {
    
    func contains(_ value: String) -> Bool {
        if self.range(of: value) != nil {
            return true
        }
        return false
    }
    
    func getGoalLabel() -> String {
        let components = self.components(separatedBy: "_")
        return components.last ?? "0"
    }
    
}
