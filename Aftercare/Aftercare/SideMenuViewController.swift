//
//  SideMenuViewController.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 9/6/17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

//mazzurski@gmail.com

import Foundation
import UIKit

class SideMenuViewController: UIViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var closeMenuButton: UIButton!
    @IBOutlet weak var menuOptionsTable: UITableView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var verifiedIconImage: UIImageView!
    
    @IBOutlet weak var headerContentTopPadding: NSLayoutConstraint!
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var contentView: UIView!
    
    //MARK: - delegate
    
    weak var delegate : SideMenuDelegate?
    
    //MARK: - fileprivates
    
    fileprivate var calculatedConstraints = false
    fileprivate var spotlights: [AwesomeSpotlight] = []
    fileprivate var spotlightViews: [UIView] = []
    fileprivate var spotlighsCreated = false
    
    fileprivate var menuData: [Dictionary<CellDataKeys , String>] = {
        let data = [
            [
                CellDataKeys.type : CellTypes.content.rawValue,
                CellDataKeys.title : "drawer_nav_home",
                CellDataKeys.icon : "homeIcon",
                CellDataKeys.value : String(describing: ActionScreenViewController.self)
            ],
//            [
//                CellDataKeys.type : CellTypes.content.rawValue,
//                CellDataKeys.title : "drawer_nav_dentacoin",
//                CellDataKeys.icon : "collectIcon",
//                CellDataKeys.value : String(describing: CollectScreenViewController.self)
//            ],
            [
                CellDataKeys.type : CellTypes.content.rawValue,
                CellDataKeys.title : "drawer_nav_dp",
                CellDataKeys.icon : "collectIcon",
                CellDataKeys.value : String(describing: CollectRewardPointsController.self)
            ],
//              [
//                CellDataKeys.type : CellTypes.content.rawValue,
//                CellDataKeys.title : "drawer_nav_withdraws",
//                CellDataKeys.icon : "withdrawsIcon",
//                CellDataKeys.value : String(describing: WithdrawsScreenViewController.self)
//            ],
              [
                CellDataKeys.type : CellTypes.content.rawValue,
                CellDataKeys.title : "drawer_nav_goals",
                CellDataKeys.icon : "goalsIcon",
                CellDataKeys.value : String(describing: GoalsScreenViewController.self)
            ],[
                CellDataKeys.type : CellTypes.content.rawValue,
                CellDataKeys.title : "drawer_nav_statistics",
                CellDataKeys.icon : "statisticIcon",
                CellDataKeys.value : String(describing: StatisticScreenViewController.self)
            ],[
                CellDataKeys.type : CellTypes.content.rawValue,
                CellDataKeys.title : "drawer_nav_oral_health",
                CellDataKeys.icon : "oralHealthIcon",
                CellDataKeys.value : String(describing: OralHealthScreenViewController.self)
            ],[
                CellDataKeys.type : CellTypes.content.rawValue,
                CellDataKeys.title : "drawer_nav_emergency",
                CellDataKeys.icon : "emergencyIcon",
                CellDataKeys.value : String(describing: EmergencyScreenViewController.self)
            ],[
                CellDataKeys.type : CellTypes.content.rawValue,
                CellDataKeys.title : "drawer_nav_about",
                CellDataKeys.icon : "aboutIcon",
                CellDataKeys.value : String(describing: AboutScreenViewController.self)
            ],[
                CellDataKeys.type : CellTypes.separator.rawValue
            ],[
                CellDataKeys.type : CellTypes.content.rawValue,
                CellDataKeys.title: "drawer_nav_settings",
                CellDataKeys.icon : "navsettings",
                CellDataKeys.value : String(describing: SettingsScreenViewController.self)
            ],[
                CellDataKeys.type : CellTypes.action.rawValue,
                CellDataKeys.title : "drawer_nav_signout",
                CellDataKeys.icon : "logoutIcon",
                CellDataKeys.value : ActionIDs.logout.rawValue
            ]
        ]
        return data
    }()
    
    fileprivate let contentCellIdentifier = "MainMenuCell"
    fileprivate let separatorCellIdentifier = "MainMenuSeparatorCell"
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateUserData()
        
        if UserDataContainer.shared.toggleSpotlightsForSideMenu {
            setupAndStartSpotlightTutorials()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //Calculate header constraints for iPhoneX
        if #available(iOS 11.0, *) {
            if !calculatedConstraints {
                calculatedConstraints = true
                let topPadding = self.view.safeAreaInsets.top
                headerHeightConstraint.constant += topPadding
                headerContentTopPadding.constant += topPadding
            }
        }
    }
    
    //MARK: - Theme and appearance
    
    fileprivate func setup() {
        
        onUserEmailConfirmationUpdated()
        
        menuOptionsTable.backgroundColor = .clear
        menuOptionsTable.separatorStyle = .none
        menuOptionsTable.register(
            UINib(
                nibName: contentCellIdentifier,
                bundle: nil
            ),
            forCellReuseIdentifier: contentCellIdentifier
        )
        menuOptionsTable.register(
            UINib(
                nibName: separatorCellIdentifier,
                bundle: nil
            ),
            forCellReuseIdentifier: separatorCellIdentifier
        )
        menuOptionsTable.rowHeight = 55
        
        //add drop shadow to the view controller
        
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset =  CGSize(width: 0.0, height: 1.0)
        view.layer.shadowOpacity = 0.5
        
        NotificationCenter.default.addObserver(
            self,
            selector: Selector.resetTooltipsSelector,
            name: NSNotification.Name(rawValue: "resetSpotlights"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: Selector.userEmailConfirmationUpdated,
            name: NSNotification.Name(rawValue: "userEmailConfirmationUpdated"),
            object: nil
        )
        
        //setup components
        
        setupAndUpdateMenuData()
    }
    
    fileprivate func updateUserData() {
        guard let data = UserDataContainer.shared.userInfo else { return }
        
        fullNameLabel.textColor = .white
        fullNameLabel.font = UIFont.dntLatoLightFont(size: UIFont.dntButtonFontSize)
        if let first = data.firstName, let last = data.lastName {
            fullNameLabel.text = first + " " + last
        }
        
        emailLabel.textColor = .white
        emailLabel.font = UIFont.dntLatoLightFont(size: UIFont.dntMainMenuLabelFontSize)
        emailLabel.text = data.email
        if let image = UserDataContainer.shared.userAvatar {
            avatarImage.image = image
        }
        avatarImage.layer.cornerRadius = avatarImage.frame.size.width / 2
        avatarImage.layer.masksToBounds = true
        
        APIProvider.retreiveUserInfo() { [weak self] userData, error in
            if let error = error {
                print("SideMenuViewController :: updateUserData :: Unable to retreive userData \(error.errors)")
                return
            }
            if let data = userData {
                UserDataContainer.shared.userInfo = data
                self?.onUserEmailConfirmationUpdated()
            }
        }
    }
    
    fileprivate func setupAndUpdateMenuData() {
        menuOptionsTable.delegate = self
        menuOptionsTable.dataSource = self
        menuOptionsTable.reloadData()
    }
    
    fileprivate func setupAndStartSpotlightTutorials() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: { [weak self] in
            if self?.spotlights.count == 0 {
                //create spotlights
                
                let spotlightModels = SpotlightModels.sideMenu
                for model in spotlightModels {
                    if let viewUnderSpot = self?.getSpotlightView(forID: model.id) {
                        guard let newFrame = viewUnderSpot.superview?.convert(viewUnderSpot.frame, to: nil) else {
                            return
                        }
                        let smallestSide = newFrame.width > newFrame.height ? newFrame.height : newFrame.width
                        let scaleFactor: CGFloat = 1.7
                        let squareSide = smallestSide * scaleFactor
                        let widthOffset = (newFrame.width - squareSide) / 2
                        let heightOffset = (newFrame.height - squareSide) / 2
                        let square = CGRect(
                            x: newFrame.origin.x + widthOffset,
                            y: newFrame.origin.y + heightOffset,
                            width: squareSide,
                            height: squareSide
                        )
                        self?.spotlights.append(
                            AwesomeSpotlight(
                                withRect: square,
                                shape: model.shape,
                                text: model.label
                            )
                        )
                    }
                }
                
            }
            
            let spotlightView = AwesomeSpotlightView(frame: (self?.view.frame)!, spotlight: (self?.spotlights)!)
            spotlightView.cutoutRadius = 8
            spotlightView.delegate = self
            self?.view.addSubview(spotlightView)
            spotlightView.start()
        })
        
    }
    
    fileprivate func getSpotlightView(forID id: SpotlightID) -> UIView? {
        switch id {
            case .editProfile:
                return avatarImage
            case .sendDCN:
                guard let cell = menuOptionsTable.cellForRow(at: IndexPath(row: 1, section: 0)) as? MainMenuCell else {
                    return nil
                }
                return cell.icon
            case .achieveGoalsAndEarn:
                guard let cell = menuOptionsTable.cellForRow(at: IndexPath(row: 3, section: 0)) as? MainMenuCell else {
                    return nil
                }
                return cell.icon
            case .sendEmergency:
                guard let cell = menuOptionsTable.cellForRow(at: IndexPath(row: 6, section: 0)) as? MainMenuCell else {
                    return nil
                }
                return cell.icon
            default:
                return nil
        }
    }
    
    func closeMenu() {
        delegate?.onCloseMenu()
    }
    
    @objc func onResetSpotlights() {
        UserDataContainer.shared.toggleSpotlightsForSideMenu = true
    }
    
    @objc func onUserEmailConfirmationUpdated() {
        verifiedIconImage.isHidden = !UserDataContainer.shared.getUserEmailConfirmed()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

// MARK: - AwesomeSpotlightViewDelegate

extension SideMenuViewController: AwesomeSpotlightViewDelegate {
    func spotlightViewWillCleanup(_ spotlightView: AwesomeSpotlightView, atIndex index: Int) {
        if index == spotlights.count - 1 {
            UserDataContainer.shared.toggleSpotlightsForSideMenu = false
        }
    }
}

//MARK: - IBOActions

extension SideMenuViewController {
    
    @IBAction func closeMenuButtonIsPressed(_ sender: UIButton) {
        closeMenu()
    }
    
    @IBAction func openUserProfileIsPressed(_ sender: UIButton) {
        closeMenu()
        delegate?.menuItemSelected(String(describing: UserProfileScreenViewController.self), nil)
    }
    
}

//MARK: - UITableViewDelegate

extension SideMenuViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = menuData[indexPath.row]
        
        if CellTypes.content.rawValue == data[CellDataKeys.type] || CellTypes.action.rawValue == data[CellDataKeys.type] {
            let cell: MainMenuCell = tableView.dequeueReusableCell(withIdentifier: contentCellIdentifier) as! MainMenuCell
            if let imageID = data[CellDataKeys.icon] {
                cell.icon.image = UIImage(named: imageID)
            }
            if let title = data[CellDataKeys.title] {
                cell.label.text = title.localized()
            }
            
            cell.backgroundColor = .clear
            
            return cell
        } else if CellTypes.separator.rawValue == data[CellDataKeys.type] {
            let cell = tableView.dequeueReusableCell(withIdentifier: separatorCellIdentifier) as! MainMenuSeparatorCell
            cell.backgroundColor = .clear
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let data = menuData[indexPath.row]
        
        if CellTypes.content.rawValue == data[CellDataKeys.type] {
            if let value = data[CellDataKeys.value] {
                delegate?.menuItemSelected(value, nil)
            }
            closeMenu()
        }
        
        if CellTypes.action.rawValue == data[CellDataKeys.type] {
            delegate?.logout()
            closeMenu()
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
}

//MARK: - UITableViewDataSource

extension SideMenuViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuData.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
}

//MARK: - Helpers

fileprivate enum CellTypes: String {
    case content = "content"
    case action = "action"
    case separator = "separator"
    case empty = "empty"
}

fileprivate enum CellDataKeys {
    case type
    case title
    case icon
    case value
}

fileprivate enum ActionIDs: String {
    case logout = "com.dentacoin.dentacare-app.user.actions.logout"
    case openUserProfile = "com.dentacoin.dentacare-app.user.actions.open-user-profile"
}

//MARK: - Selectors

fileprivate extension Selector {
    static let resetTooltipsSelector = #selector(SideMenuViewController.onResetSpotlights)
    static let userEmailConfirmationUpdated = #selector(SideMenuViewController.onUserEmailConfirmationUpdated)
}

