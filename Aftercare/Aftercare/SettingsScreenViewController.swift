//
//  NotificationsScreenViewController.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 9/9/17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import Foundation
import UIKit

class SettingsScreenViewController: UIViewController, ContentConformer {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var headerView: UIView?
    @IBOutlet weak var settingsTableView: UITableView!
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    
    //MARK: - delegates
    
    var contentDelegate: ContentDelegate?
    
    //MARK: - Public
    
    var header: InitialPageHeaderView! {
        return headerView as! InitialPageHeaderView
    }
    
    //MARK: - fileprivates
    
    fileprivate var calculatedConstraints = false
    
    fileprivate typealias SettingsMenuItem = (label: String, cellType: String, id: String, state: Bool)
    fileprivate typealias SettingsSection = (title: String, items: [SettingsMenuItem])
    
    fileprivate var menuData: [SettingsSection] = {
        let data = [
            (
                title: NSLocalizedString("Tutorials", comment: ""),
                items: [
                    (
                        label: NSLocalizedString("Show Tutorials", comment: ""),
                        cellType: String(describing: SettingsClearButtonTableCell.self),
                        id: "",
                        state: true
                    )
                ]
            ),
            (
                title: NSLocalizedString("Music And Sounds", comment: ""),
                items: [
                    (
                        label: NSLocalizedString("Sounds", comment: ""),
                        cellType: String(describing: SettingsSwitchTableCell.self),
                        id: "",
                        state: true
                    ),
                    (
                        label: NSLocalizedString("Music", comment: ""),
                        cellType: String(describing: SettingsSwitchTableCell.self),
                        id: "",
                        state: true
                    ),
                    (
                        label: NSLocalizedString("Voice: male", comment: ""),
                        cellType: String(describing: SettingsSwitchTableCell.self),
                        id: "",
                        state: true
                    )
                ]
            ),(
                title: NSLocalizedString("Notifications Settings", comment: ""),
                items: [
                    (
                        label : NSLocalizedString("Daily brushing", comment: ""),
                        cellType: String(describing: SettingsSwitchTableCell.self),
                        id  : NotificationIdentifiers.dailyBrushing.rawValue,
                        state : NotificationsManager.shared.localNotificationIsEnabled(withID: NotificationIdentifiers.dailyBrushing)
                    ),
                    (
                        label : NSLocalizedString("Change brush", comment: ""),
                        cellType: String(describing: SettingsSwitchTableCell.self),
                        id  : NotificationIdentifiers.changeBrush.rawValue,
                        state : NotificationsManager.shared.localNotificationIsEnabled(withID: NotificationIdentifiers.changeBrush)
                    ),
                    (
                        label : NSLocalizedString("Visit dentist", comment: ""),
                        cellType: String(describing: SettingsSwitchTableCell.self),
                        id  : NotificationIdentifiers.visitDentist.rawValue,
                        state : NotificationsManager.shared.localNotificationIsEnabled(withID: NotificationIdentifiers.visitDentist)
                    ),
                    (
                        label : NSLocalizedString("Collect dentacoins", comment: ""),
                        cellType: String(describing: SettingsSwitchTableCell.self),
                        id  : NotificationIdentifiers.collectDentacoin.rawValue,
                        state : NotificationsManager.shared.localNotificationIsEnabled(withID: NotificationIdentifiers.collectDentacoin)
                    ),
                    (
                        label : NSLocalizedString("Reminder to visit", comment: ""),
                        cellType: String(describing: SettingsSwitchTableCell.self),
                        id  : NotificationIdentifiers.remindToVisitTheApp.rawValue,
                        state : NotificationsManager.shared.localNotificationIsEnabled(withID: NotificationIdentifiers.remindToVisitTheApp)
                    ),
                    (
                        label : NSLocalizedString("Healty habits", comment: ""),
                        cellType: String(describing: SettingsSwitchTableCell.self),
                        id  : NotificationIdentifiers.healthyHabits.rawValue,
                        state : NotificationsManager.shared.localNotificationIsEnabled(withID: NotificationIdentifiers.healthyHabits)
                    )
                ]
            )
        ]
        return data
    }()
    
    fileprivate let contentSwitchCellIdentifier = String(describing: SettingsSwitchTableCell.self)
    fileprivate let contentHeaderCellIdentifier = String(describing: UITableViewHeaderFooterView.self)
    fileprivate let contentClearButtonIdentifier = String(describing: SettingsClearButtonTableCell.self)
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        header.delegate = self
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        header.updateTitle(NSLocalizedString("Settings", comment: ""))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if #available(iOS 11.0, *) {
            if !calculatedConstraints {
                calculatedConstraints = true
                let topPadding = self.view.safeAreaInsets.top
                headerHeightConstraint.constant += topPadding
            }
        }
    }
    
}

//MARK: - Theme and appearance setup

extension SettingsScreenViewController {
    
    func setup() {
        settingsTableView.backgroundColor = .clear
        settingsTableView.separatorStyle = .singleLine
        settingsTableView.register(
            UINib(
                nibName: contentSwitchCellIdentifier,
                bundle: nil
            ),
            forCellReuseIdentifier: contentSwitchCellIdentifier
        )
        
        settingsTableView.register(
            UINib(
                nibName: contentClearButtonIdentifier,
                bundle: nil
            ),
            forCellReuseIdentifier: contentClearButtonIdentifier
        )
        
        settingsTableView.register(
            UITableViewHeaderFooterView.self,
            forHeaderFooterViewReuseIdentifier: contentHeaderCellIdentifier
        )
        
        settingsTableView.sectionHeaderHeight = 50
        settingsTableView.rowHeight = 55
        
        settingsTableView.delegate = self
        settingsTableView.dataSource = self
        
        settingsTableView.reloadData()
    }
    
}

//MARK: - UITableViewDelegate

extension SettingsScreenViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: contentHeaderCellIdentifier) {
            header.textLabel?.font = UIFont.dntLatoLightFont(size: UIFont.dntButtonFontSize)
            header.textLabel?.text = menuData[section].title
            header.textLabel?.textColor = .white
            header.backgroundView = UIView(frame: header.bounds)
            header.backgroundView?.backgroundColor = UIColor.dntCeruleanBlue
            return header
        }
        return UITableViewHeaderFooterView()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = menuData[indexPath.section].items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: data.cellType)
        let label = data.label
        
        if let cell = cell as? SettingsSwitchTableCell {
            
            //add value to the cell title label
            cell.cellLabel.text = label
            cell.config(indexPath)
            cell.delegate = self
            
            //apply switch state
            cell.cellSwitch.setOn(data.state, animated: false)
            cell.layoutSubviews()
            
            return cell
        }
        
        if let cell = cell as? SettingsClearButtonTableCell {
            
            cell.cellLabel.text = label
            cell.config(indexPath)
            cell.delegate = self
            cell.layoutSubviews()
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

//MARK: - SettingsClearButtonTableCellDelegate

extension SettingsScreenViewController: SettingsClearButtonTableCellDelegate {
    
    func onClearButtonPressed(_ indexPath: IndexPath) {
        let section = indexPath.section
        if section == 0 {
            UserDataContainer.shared.resetTutorialToggle(true)
            //TODO: fix the name of the selector
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "resetTutorials"), object: nil)
            return
        }
    }
    
}

//MARK: - SettingsSwitchTableCellDelegate

extension SettingsScreenViewController: SettingsSwitchTableCellDelegate {
    
    func onCellToggleSwitch(_ indexPath: IndexPath, _ value: Bool) {
        
        let section = indexPath.section
        
        if section == 1 {
            
            return
        }
        
        if section == 2 {
            let index = indexPath.row
            let data = menuData[indexPath.section].items[index]
            guard let id = NotificationIdentifiers(rawValue: data.id) else { return }
            NotificationsManager.shared.toggleLocalNotification(withID: id, value)
        }
        
    }
    
}

//MARK: - UITableViewDataSource

extension SettingsScreenViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuData[section].items.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.menuData.count;
    }
    
}

//MARK: - InitialPageHeaderViewDelegate

extension SettingsScreenViewController: InitialPageHeaderViewDelegate {
    
    func mainMenuButtonIsPressed() {
        contentDelegate?.openMainMenu()
    }
    
}
