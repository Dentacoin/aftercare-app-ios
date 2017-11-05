//
//  GoalPopupScreen.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 9/18/17.
//  Copyright © 2017 Dimitar Grudev. All rights reserved.
//

import Foundation
import UIKit

class GoalPopupScreen: UIView {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var popupPanel: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var counturImage: UIImageView!
    @IBOutlet weak var ovalImage: UIImageView!
    @IBOutlet weak var toothImage: UIImageView!
    @IBOutlet weak var starImage: UIImageView!
    @IBOutlet weak var ribbonImage: UIImageView!
    @IBOutlet weak var numberLabel: UILabel!
    //MARK: - fileprivates
    
    fileprivate var data: GoalData?
    
    //MARK: - Lifecycle
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.removeFromSuperview()
    }
}

//MARK: - Theme & appearance

extension GoalPopupScreen {
    
    func config(_ data: GoalData) {
        self.data = data
        setup()
    }
    
    fileprivate func setup() {
        self.titleLabel.text = self.data?.title
        self.descriptionLabel.text = self.data?.description
        
        let completed = self.data?.completed ?? false
        
        titleLabel.font = UIFont.dntLatoRegularFontWith(size: UIFont.dntLargeTextSize)
        titleLabel.text = data?.title
        
        descriptionLabel.textColor = UIColor.dntCharcoalGrey
        descriptionLabel.font = UIFont.dntLatoLightFont(size: UIFont.dntMainMenuLabelFontSize)
        
        numberLabel.textColor = .white
        numberLabel.font = UIFont.dntLatoBlackFont(size: 90)
        
        //add drop shadow to the view
        
        containerView.layer.masksToBounds = false
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset =  CGSize(width: 1.0, height: 2.0)
        containerView.layer.shadowOpacity = 1
        
        if completed {
            self.achievedStyle()
        } else {
            self.unachievedStyle()
        }
    }
    
    fileprivate func achievedStyle() {
        
        guard let id = self.data?.id else { return }
        let colorStyle: GoalColors = self.getColorStyle(byID: id)
        
        if colorStyle == GoalColors.purple {
            toothImage.image = UIImage(named: "tooth-" + colorStyle.rawValue)
            numberLabel.text = ""
        } else {
            toothImage.image = nil
            numberLabel.text = id.getGoalLabel()
        }
        
        titleLabel.textColor = UIColor.dntCeruleanBlue
        
        starImage.image = UIImage(named: "star-" + colorStyle.rawValue)
        counturImage.image = UIImage(named: "countur-" + colorStyle.rawValue)
        ovalImage.image = UIImage(named: "oval-" + colorStyle.rawValue)
        ribbonImage.image = UIImage(named: "ribbon-" + colorStyle.rawValue)
        
        popupPanel.image = UIImage(named: ImageIDs.goalBackground)
        popupPanel.layer.cornerRadius = 10
        popupPanel.clipsToBounds = true
        
        self.backgroundColor = UIColor.dntCeruleanBlue.withAlphaComponent(0.6)
    }
    
    fileprivate func unachievedStyle() {
        
        guard let id = self.data?.id else { return }
        
        let firstGoal = id.contains(GoalStyles.first.rawValue)
        if firstGoal {
            toothImage.image = UIImage(named: "tooth-" + GoalColors.gray.rawValue)
            numberLabel.text = ""
        } else {
            toothImage.image = nil
            numberLabel.text = id.getGoalLabel()
        }
        
        titleLabel.textColor = UIColor.black
        
        starImage.image = nil
        counturImage.image = UIImage(named: "countur-" + GoalColors.gray.rawValue)
        ovalImage.image = UIImage(named: "oval-" + GoalColors.gray.rawValue)
        ribbonImage.image = UIImage(named: "ribbon-" + GoalColors.gray.rawValue)
        
        popupPanel.image = UIImage(named: ImageIDs.goalBackground)
        popupPanel.layer.cornerRadius = 10
        popupPanel.clipsToBounds = true
        
        self.backgroundColor = UIColor.dntCharcoalGrey.withAlphaComponent(0.6)
    }
    
    fileprivate func getColorStyle(byID id: String) -> GoalColors {
        if id.contains(GoalStyles.first.rawValue) { return GoalColors.purple }
        if id.contains(GoalStyles.week.rawValue) { return GoalColors.green }
        if id.contains(GoalStyles.month.rawValue) { return GoalColors.blue }
        if id.contains(GoalStyles.year.rawValue) { return GoalColors.yellow }
        return GoalColors.gray
    }
    
}

//MARK: - Goal Types

enum GoalStyles: String {
    case first = "first"
    case week = "week"
    case month = "month"
    case year = "year"
    case unachieved = "unachieved"
}

enum GoalColors: String {
    case purple = "purple"
    case green = "green"
    case blue = "blue"
    case yellow = "yellow"
    case gray = "gray"
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


