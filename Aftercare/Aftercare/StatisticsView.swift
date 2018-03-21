//
//  StatisticsView.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 9/14/17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import Foundation
import UIKit

class StatisticsView: UIView {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var statisticsTitleLabel: UILabel!
    @IBOutlet weak var dailyOptionButton: UIButton!
    @IBOutlet weak var weeklyOptionButton: UIButton!
    @IBOutlet weak var monthlyOptionButton: UIButton!
    
    @IBOutlet weak var actionsTakenBar: SmallCircularBar!
    @IBOutlet weak var timeLeftBar: SmallCircularBar!
    @IBOutlet weak var averageBar: SmallCircularBar!
    
    //MARK: - Delegate
    
    weak var delegate: StatisticsDelegate?
    
    //MARK: - fileprivate
    
    fileprivate var selectedOptionsButton: UIButton?
    fileprivate var data: ActionDashboardData?
    fileprivate var type: ActionRecordType?
    
    //MARK: - Lifecycle
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        setup()
    }
    
    //MARK: - Public api
    
    func config(type: ActionRecordType) {
        self.type = type
        //UserDataContainer.shared.delegate = self
    }
    
    //MARK: - internal logic
    
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
    
    /*fileprivate*/ func updateData(_ data: ActionScreenData) {
        
        var actionData: ActionDashboardData?
        var scheduleData: ScheduleData?
        var statisticsLabel: String?
        var actionBarLabel: String?
        let timeLeftLabel = NSLocalizedString("AVERAGE TIME", comment: "")//The same no matter the type of the container
        let averageLabel = NSLocalizedString("TIME LEFT", comment: "")//The same no matter the type of the container
        
        guard let type = self.type else { return }
        
        switch type {
            case ActionRecordType.brush:
                statisticsLabel = NSLocalizedString("Brush Statistics", comment: "")
                actionBarLabel = NSLocalizedString("TIMES BRUSHED", comment: "")
                actionData = data.brush
            case ActionRecordType.flossed:
                statisticsLabel = NSLocalizedString("Flossed Statistics", comment: "")
                actionBarLabel = NSLocalizedString("TIMES FLOSSED", comment: "")
                actionData = data.flossed
            case ActionRecordType.rinsed:
                statisticsLabel = NSLocalizedString("Rinsed Statistics", comment: "")
                actionBarLabel = NSLocalizedString("TIMES RINSED", comment: "")
                actionData = data.rinsed
        }
        
        if let selected = self.selectedOptionsButton {
            switch selected {
                case dailyOptionButton:
                    scheduleData = actionData?.daily
                case weeklyOptionButton:
                    scheduleData = actionData?.weekly
                case monthlyOptionButton:
                    scheduleData = actionData?.monthly
                default:
                    return
            }
        } else {
            print("Error: Unknown button option selected, unable to update!")
            return
        }
        
        self.statisticsTitleLabel.text = statisticsLabel
        
        //update actions taken bar
        actionsTakenBar.setTitle(actionBarLabel ?? "")
        actionsTakenBar.setValue(String(scheduleData?.times ?? 0))
        
        //update times left bar
        timeLeftBar.setTitle(timeLeftLabel)
        timeLeftBar.setValue(SystemMethods.Utils.secondsToISO8601Format(scheduleData?.left ?? 0))
        
        //update average time bar
        averageBar.setTitle(averageLabel)
        averageBar.setValue(SystemMethods.Utils.secondsToISO8601Format(scheduleData?.average ?? 0))
        
    }
    
}

//MARK: - Apply theme and appearance

extension StatisticsView {
    
    fileprivate func setup() {
        
        let themeManager = ThemeManager.shared
        
        dailyOptionButton.titleLabel?.text = NSLocalizedString("Daily", comment: "")
        toggleOptionsButton(dailyOptionButton)
        
        //default selected button
        selectedOptionsButton = dailyOptionButton
        
        themeManager.setDCBlueTheme(
            to: weeklyOptionButton,
            ofType: .ButtonOptionStyle(
                label: NSLocalizedString("Weekly", comment: ""),
                selected: false
            )
        )
        themeManager.setDCBlueTheme(
            to: monthlyOptionButton,
            ofType: .ButtonOptionStyle(
                label: NSLocalizedString("Monthly", comment: ""),
                selected: false
            )
        )
        
        statisticsTitleLabel.textColor = .white
        statisticsTitleLabel.font = UIFont.dntLatoLightFont(size: UIFont.dntButtonFontSize)
        
        actionsTakenBar.changeStyle(.light)
        timeLeftBar.changeStyle(.light)
        averageBar.changeStyle(.light)
        
        if let data = UserDataContainer.shared.actionScreenData {
            self.updateData(data)
        }
    }
    
}

//MARK: - DataSourceDelegate

//extension StatisticsView: DataSourceDelegate {
//    func actionScreenDataUpdated(_ data: ActionScreenData) {
//        self.updateData(data)
//    }
//}

//MARK: - IBActions

extension StatisticsView {
    
    @IBAction func closeStatsticsButtonPressed(_ sender: UIButton) {
        delegate?.closeStatisticsPressed()
    }
    
    @IBAction func scheduleOptionButtonPressed(_ sender: UIButton) {
        toggleOptionsButton(sender)
        if let data = UserDataContainer.shared.actionScreenData {
            self.updateData(data)
        }
    }
    
}
