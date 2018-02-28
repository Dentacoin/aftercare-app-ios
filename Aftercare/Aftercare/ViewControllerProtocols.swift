//
//  ViewControllerProtocols.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 9/9/17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import UIKit

protocol ContentDelegate: class {
    func openMainMenu()
    func requestLoadViewController(_ id: String, _ parameters: [String: Any]?)
    func backButtonIsPressed()
}

protocol ContentConformer: class {
    var headerView: UIView? { get set }
    var contentDelegate: ContentDelegate? { get set }
    func config(_ data: [String: Any])
}

protocol StatisticsTableViewCellProtocol: class {
    func setupAppearance()
}

//MARK: - Delegates

protocol InitialPageHeaderViewDelegate: class {
    func mainMenuButtonIsPressed()
}

protocol InsidePageHeaderViewDelegate: class {
    func backButtonIsPressed()
}

protocol ActionHeaderViewDelegate: InitialPageHeaderViewDelegate {
    func tabBarButtonPressed(_ index: Int)
}

protocol SideMenuDelegate: class {
    func menuItemSelected(_ id: String, _ parameters: [String: Any]?)
    func logout()
}

protocol HeaderDelegate: class {
    func updateTitle(_ title: String)
}

protocol ActionViewDelegate: class {
    func requestToOpenCollectScreen()
    func timerStarted()
    func timerStopped()
    func timerUpdated(_ milliseconds: Double)
    func stateChanged(_ newState: ActionState)
    func actionComplete(_ newRecord: ActionRecordData?)
}

//MARK: - embedView Proxy ActionViewDelegate
protocol ActionViewProxyDelegateProtocol: ActionViewDelegate {
    var delegate: ActionViewDelegate? { get set }
    var embedView: ActionView? { get }
    func changeStateTo(_ newState: ActionState)
    func actionComplete(_ newRecord: ActionRecordData?)
}

protocol StatisticsDelegate: class {
    func closeStatisticsPressed()
}

protocol StatisticsOptionsCellDelegate: class {
    func optionChanged(_ option: ScheduleOptionTypes)
}

protocol DataSourceDelegate: class {
    func actionScreenDataUpdated(_ data: ActionScreenData)
    func goalsDataUpdated(_ data: [GoalData])
}

//MARK: - Default implementations

extension ContentConformer {
    func config(_ data: [String: Any]) { }
}

extension DataSourceDelegate {
    func actionScreenDataUpdated(_ data: ActionScreenData) { }
}

extension ActionViewDelegate {
    func timerUpdated(_ milliseconds: Double) {}
    func stateChanged(_ newState: ActionState) {}
}

extension ActionViewProxyDelegateProtocol {
    
    var actionViewRecordType: ActionRecordType {
        get {
            return (embedView?.actionViewRecordType)!
        }
    }
    
    func showTooltip() {
        embedView?.showTooltips()
    }
    
    //delegate to sender methods
    
    func changeStateTo(_ newState: ActionState) {
        embedView?.changeStateTo(newState)
    }
    
    func updateData(_ data: ActionScreenData) {
        embedView?.updateData(data)
    }
    
    //sender to delegate methods
    
    func requestToOpenCollectScreen() {
        delegate?.requestToOpenCollectScreen()
    }
    
    func timerStarted() {
        delegate?.timerStarted()
    }
    
    func timerStopped() {
        delegate?.timerStopped()
    }
    
    func actionComplete(_ newRecord: ActionRecordData?) {
        delegate?.actionComplete(newRecord)
    }
}

