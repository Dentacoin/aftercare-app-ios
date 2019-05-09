//
// Aftercare
// Created by Dimitar Grudev on 29.05.18.
// Copyright © 2018 Stichting Administratiekantoor Dentacoin.
//

import Foundation
import UIKit

class CollectRewardPointsController: UIViewController, ContentConformer {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var headerView: UIView?
    @IBOutlet weak var claimablePointsLabel: UILabel!
    @IBOutlet weak var claimableValueLabel: UILabel!
    @IBOutlet weak var visitWebsiteLabel: UILabel!
    @IBOutlet weak var visitWebsiteButton: UIButton!
    @IBOutlet weak var leftSeparatorLine: UIView!
    @IBOutlet weak var rightSeparatorLine: UIView!
    
    //MARK: - Delegates
    
    var contentDelegate: ContentDelegate?
    
    //MARK: - Public
    
    var header: InitialPageHeaderView! {
        return headerView as? InitialPageHeaderView
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        header.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setup()
    }
    
    // MARK: - Setup
    
    fileprivate func setup() {
        
        header.updateTitle("drawer_nav_dp".localized())
        
        claimablePointsLabel.textColor = UIColor.dntCharcoalGrey
        claimablePointsLabel.font = UIFont.dntLatoLightFont(size: UIFont.dntLargeTitleFontSize)
        claimablePointsLabel.text = "collect_dp_claimable_points".localized()
        
        let earned = UserDataContainer.shared.actionScreenData?.earnedDCN ?? 0
        
        claimableValueLabel.textColor = UIColor.dntCharcoalGrey
        claimableValueLabel.font = UIFont.dntLatoLightFont(size: UIFont.dntLargeTitleFontSize)
        claimableValueLabel.text = "txt_dp".localized(String(earned))
        
        visitWebsiteLabel.textColor = UIColor.dntCharcoalGrey
        visitWebsiteLabel.font = UIFont.dntLatoLightFont(size: UIFont.dntLargeTextSize)
        visitWebsiteLabel.text = "collect_dp_visit_website".localized()
        
        leftSeparatorLine.backgroundColor = UIColor.lightGray
        rightSeparatorLine.backgroundColor = UIColor.lightGray
        
        let themeManager = ThemeManager.shared
        visitWebsiteButton.setTitle("collect_dp_visit_website_btn".localized(), for: .normal)
        themeManager.setDCBlueTheme(to: visitWebsiteButton, ofType: .ButtonDefaultBlueGradient)
        //visitWebsiteButton.isEnabled = earned > 0
    }
}

// MARK: - IBActions

extension CollectRewardPointsController {
    
    @IBAction func onVisitTheWebsiteButtonPressed(_ sender: UIButton) {
        guard let url = URL(string: "https://dentacare.dentacoin.com") else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
}

// MARK: - InitialPageHeaderViewDelegate

extension CollectRewardPointsController: InitialPageHeaderViewDelegate {
    
    func mainMenuButtonIsPressed() {
        contentDelegate?.openMainMenu()
    }
    
}
