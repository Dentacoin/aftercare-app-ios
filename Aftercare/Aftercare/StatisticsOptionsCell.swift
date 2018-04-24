//
//  StatisticsOptionsCell.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 9/16/17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import Foundation
import UIKit

class StatisticsOptionsCell: UITableViewCell {
    
    @IBOutlet weak var dailyOptionButton: UIButton!
    @IBOutlet weak var weeklyOptionButton: UIButton!
    @IBOutlet weak var monthlyOptionButton: UIButton!
    
    weak var delegate: StatisticsOptionsCellDelegate?
    
    //MARK: - Public api
    
    func updateOptionButtons(_ option: ScheduleOptionTypes) {
        
        switch option {
        case .dailyData:
            toggleOptionsButton(dailyOptionButton)
        case .weeklyData:
            toggleOptionsButton(weeklyOptionButton)
        case .monthlyData:
            toggleOptionsButton(monthlyOptionButton)
        }
        
    }
    
    //MARK: - Internal logic
    
    fileprivate var selectedOptionsButton: UIButton?
    
    fileprivate func toggleOptionsButton(_ selected: UIButton) {
        let themeManager = ThemeManager.shared
        
        //unselect last button if any
        if let button = selectedOptionsButton {
            themeManager.setDCBlueTheme(
                to: button,
                ofType: .ButtonOptionStyle(
                    label: (button.titleLabel?.text)!,
                    selected: false
                )
            )
        }
        
        themeManager.setDCBlueTheme(
            to: selected,
            ofType: .ButtonOptionStyle(
                label: (selected.titleLabel?.text)!,
                selected: true
            )
        )
        
        self.selectedOptionsButton = selected
        
    }
    
    @objc fileprivate func optionsButtonPressed(_ sender: UIButton) {
        
        var option: ScheduleOptionTypes = .dailyData
        
        switch sender {
            case self.dailyOptionButton:
                option = .dailyData
            case self.weeklyOptionButton:
                option = .weeklyData
            case self.monthlyOptionButton:
                option = .monthlyData
            default:
                option = .dailyData
        }
        
        self.delegate?.optionChanged(option)
        
    }
}

extension StatisticsOptionsCell: StatisticsTableViewCellProtocol {
    
    func setupAppearance() {
        
        let themeManager = ThemeManager.shared
        dailyOptionButton.titleLabel?.text = "dashboard_btn_daily".localized()
        toggleOptionsButton(dailyOptionButton)
        dailyOptionButton.addTarget(self, action: Selector.optionsButtonPressed, for: .touchUpInside)
        
        themeManager.setDCBlueTheme(
            to: weeklyOptionButton,
            ofType: .ButtonOptionStyle(
                label: "dashboard_btn_weekly".localized(),
                selected: false
            )
        )
        weeklyOptionButton.addTarget(self, action: Selector.optionsButtonPressed, for: .touchUpInside)
        
        themeManager.setDCBlueTheme(
            to: monthlyOptionButton,
            ofType: .ButtonOptionStyle(
                label: "dashboard_btn_monthly".localized(),
                selected: false
            )
        )
        monthlyOptionButton.addTarget(self, action: Selector.optionsButtonPressed, for: .touchUpInside)
        
    }
    
}

//MARK: - selectors

fileprivate extension Selector {
    static let optionsButtonPressed = #selector(StatisticsOptionsCell.optionsButtonPressed(_ :))
}
