//
//  ViewControllerProtocols.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 9/9/17.
//  Copyright © 2017 Dimitar Grudev. All rights reserved.
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
    func statisticsScreenOpened(_ sender: ActionView)
    func statisticsScreenClosed(_ sender: ActionView)
    func requestToOpenCollectScreen()
    func timerStarted()
    func timerStopped()
    func actionComplete()
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

