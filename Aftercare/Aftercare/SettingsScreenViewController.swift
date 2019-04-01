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
        return headerView as? InitialPageHeaderView
    }
    
    //MARK: - fileprivates
    
    fileprivate var calculatedConstraints = false
    
    fileprivate typealias SettingsMenuItem = (label: String, cellType: String, id: String, state: Bool)
    fileprivate typealias SettingsSection = (title: String, items: [SettingsMenuItem])
    
    fileprivate var menuData: [SettingsSection] = {
        let data = [
            (
                title: "settings_category_title_help",
                items: [
                    (
                        label: "settings_category_help_1",
                        cellType: String(describing: SettingsClearButtonTableCell.self),
                        id: "",
                        state: true
                    )
                ]
            ),
            (
                title: "settings_hdl_music_and_sounds",
                items: [
                    (
                        label: "settings_lbl_sounds",
                        cellType: String(describing: SettingsSwitchTableCell.self),
                        id: "",
                        state: true
                    ),
                    (
                        label: "settings_lbl_music",
                        cellType: String(describing: SettingsSwitchTableCell.self),
                        id: "",
                        state: true
                    ),
                    (
                        label: "settings_lbl_voice_male",
                        cellType: String(describing: SettingsSwitchTableCell.self),
                        id: "",
                        state: true
                    )
                ]
            ),(
                title: "settings_lbl_notifications",
                items: [
                    (
                        label : "settings_lbl_daily_brushing",
                        cellType: String(describing: SettingsSwitchTableCell.self),
                        id  : NotificationIdentifiers.dailyBrushing.rawValue,
                        state : NotificationsManager.shared.localNotificationIsEnabled(withID: NotificationIdentifiers.dailyBrushing)
                    ),
                    (
                        label : "settings_lbl_change_brush",
                        cellType: String(describing: SettingsSwitchTableCell.self),
                        id  : NotificationIdentifiers.changeBrush.rawValue,
                        state : NotificationsManager.shared.localNotificationIsEnabled(withID: NotificationIdentifiers.changeBrush)
                    ),
                    (
                        label : "settings_lbl_visit_dentist",
                        cellType: String(describing: SettingsSwitchTableCell.self),
                        id  : NotificationIdentifiers.visitDentist.rawValue,
                        state : NotificationsManager.shared.localNotificationIsEnabled(withID: NotificationIdentifiers.visitDentist)
                    ),
                    (
                        label : "settings_lbl_collect_dentacoins",
                        cellType: String(describing: SettingsSwitchTableCell.self),
                        id  : NotificationIdentifiers.collectDentacoin.rawValue,
                        state : NotificationsManager.shared.localNotificationIsEnabled(withID: NotificationIdentifiers.collectDentacoin)
                    ),
                    (
                        label : "settings_lbl_reminder_visit",
                        cellType: String(describing: SettingsSwitchTableCell.self),
                        id  : NotificationIdentifiers.remindToVisitTheApp.rawValue,
                        state : NotificationsManager.shared.localNotificationIsEnabled(withID: NotificationIdentifiers.remindToVisitTheApp)
                    ),
                    (
                        label : "settings_lbl_healthy_habits",
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
        header.updateTitle("settings_hdl_settings".localized())
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
            header.textLabel?.text = menuData[section].title.localized()
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
        let label = data.label.localized()
        
        if let cell = cell as? SettingsSwitchTableCell {
            
            //add value to the cell title label
            cell.cellLabel.text = label
            cell.config(indexPath)
            cell.delegate = self
            
            //apply switch state
            cell.cellSwitch.setOn(data.state, animated: false)
            cell.layoutSubviews()
            
            if indexPath.section == 1 {
                if indexPath.row == 0 {
                    cell.cellSwitch.isOn = SoundManager.shared.soundOn
                } else if indexPath.row == 1 {
                    cell.cellSwitch.isOn = SoundManager.shared.musicOn
                } else if indexPath.row == 2 {
                    let type = SoundManager.shared.soundType
                    cell.cellSwitch.isOn = type == VoicePath.male
                }
            }
            
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
    
    //TODO: fix the name of the selector. Should be Reset
    func onClearButtonPressed(_ indexPath: IndexPath) {
        let section = indexPath.section
        if section == 0 {
            UserDataContainer.shared.toggleSpotlightsForActionScreen = true
            UserDataContainer.shared.toggleSpotlightsForSideMenu = true
            UserDataContainer.shared.setTutorialsToggle(true)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "resetTooltips"), object: nil)
            return
        }
    }
    
}

//MARK: - SettingsSwitchTableCellDelegate

extension SettingsScreenViewController: SettingsSwitchTableCellDelegate {
    
    func onCellToggleSwitch(_ indexPath: IndexPath, _ value: Bool) {
        
        let section = indexPath.section
        
        switch section {
            case 1:
                
                switch indexPath.row {
                    case 0:
                        SoundManager.shared.soundOn = !SoundManager.shared.soundOn
                    case 1:
                        SoundManager.shared.musicOn = !SoundManager.shared.musicOn
                    case 2:
                        let type = SoundManager.shared.soundType
                        if type == VoicePath.male {
                            SoundManager.shared.soundType = VoicePath.female
                        } else {
                            SoundManager.shared.soundType = VoicePath.male
                        }
                    default:
                        return
                }
        
            case 2:
                
                let index = indexPath.row
                let data = menuData[indexPath.section].items[index]
                guard let id = NotificationIdentifiers(rawValue: data.id) else { return }
                NotificationsManager.shared.toggleLocalNotification(withID: id, value)
            
            default:
                return
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
