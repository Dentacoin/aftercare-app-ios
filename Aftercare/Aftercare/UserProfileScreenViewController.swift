//
//  UserProfileScreenViewController.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 9/9/17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import Foundation
import UIKit

class UserProfileScreenViewController: UIViewController, ContentConformer {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var headerView: UIView?
    @IBOutlet weak var userAvatarImage: UIImageView!
    @IBOutlet weak var verifiedIconImage: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var editProfileButton: UIButton!
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomContentPadding: NSLayoutConstraint!
    
    @IBOutlet weak var emailNotVerifiedLabel: UILabel!
    @IBOutlet weak var resendEmailVerificationButton: UIButton!
    @IBOutlet weak var emailVerificationViewHeightConstraint: NSLayoutConstraint!
    
    //MARK: - Delegate
    
    var contentDelegate: ContentDelegate?
    
    //MARK: - Public
    
    var header: InitialPageHeaderView! {
        return headerView as? InitialPageHeaderView
    }
    
    //MARK: - fileprivates
    
    fileprivate var calculatedConstraints = false
    fileprivate var emailConfirmationRequested = false
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        header.delegate = self
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateContent()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if #available(iOS 11.0, *) {
            if !calculatedConstraints {
                calculatedConstraints = true
                let topPadding = self.view.safeAreaInsets.top
                headerHeightConstraint.constant += topPadding
                let bottomPadding = self.view.safeAreaInsets.bottom
                bottomContentPadding.constant -= bottomPadding
            }
        }
    }
    
}

//MARK: - apply theme and appearance

extension UserProfileScreenViewController {
    
    fileprivate func setup() {
        
        header.updateTitle("profile_hdl_my_profile".localized())
        
        emailNotVerifiedLabel.textColor = .red
        emailNotVerifiedLabel.font = UIFont.dntLatoRegularFontWith(size: UIFont.dntLabelFontSize)
        emailNotVerifiedLabel.text = "profile_txt_email_not_verified".localized()
        
        let themeManager = ThemeManager.shared
        themeManager.setDCBlueTheme(
            to: resendEmailVerificationButton,
            ofType: .ButtonOptionStyle(
                label: "profile_txt_resend_verification_email".localized(),
                selected: false
            )
        )
        
        userEmailConfirationUpdated()
        
        fullNameLabel.textColor = .white
        fullNameLabel.font = UIFont.dntLatoLightFont(size: UIFont.dntTitleFontSize)
        
        emailLabel.textColor = .white
        emailLabel.font = UIFont.dntLatoLightFont(size: UIFont.dntLargeTextSize)
        
        addressLabel.textColor = .white
        addressLabel.font = UIFont.dntLatoLightFont(size: UIFont.dntLargeTextSize)
        
        ageLabel.textColor = .white
        ageLabel.font = UIFont.dntLatoLightFont(size: UIFont.dntLargeTextSize)
        
        genderLabel.textColor = .white
        genderLabel.font = UIFont.dntLatoLightFont(size: UIFont.dntLargeTextSize)
        
        userAvatarImage.layer.cornerRadius = userAvatarImage.frame.size.width / 2
        userAvatarImage.layer.masksToBounds = true
        
        editProfileButton.setTitle("profile_btn_edit".localized(), for: .normal)
        themeManager.setDCBlueTheme(to: editProfileButton, ofType: .ButtonDefault)
    }
    
    fileprivate func updateContent() {
        guard let data = UserDataContainer.shared.userInfo else { return }
        
        if let first = data.firstName {
            var fullName = first
            if let last = data.lastName {
                fullName += " " + last
            }
            fullNameLabel.text = fullName
        }
        
        emailLabel.text = data.email
        
        var address = ""
        if let postal = data.postalCode {
            address += postal
        }
        if let city = data.city {
            address += " " + city
        }
        if let country = data.country {
            address += " " + country
        }
        
        addressLabel.text = address
        
        if let image = UserDataContainer.shared.userAvatar {
            userAvatarImage.image = image
        }
        
        let formatter = DateFormatter.humanReadableFormat
        if let birthDay = data.birthDay {
            if let age = formatter.date(from: birthDay) {
                let calendar = Calendar.current
                let components = calendar.dateComponents([.year], from: age, to: Date())
                if let years = components.year {
                    ageLabel.text = "profile_txt_years_old".localized(String(years))
                }
            }
        }
        if data.gender != .unspecified {
            genderLabel.text = data.gender.rawValue.localized()
        }
        
        APIProvider.retreiveUserInfo() { [weak self] userData, error in
            if let error = error {
                print("UserProfileScreenViewController :: UpdateContent :: Unable to retreive userData \(error.errors)")
                return
            }
            if let data = userData {
                UserDataContainer.shared.userInfo = data
                self?.userEmailConfirationUpdated()
            }
        }
    }
    
    fileprivate func userEmailConfirationUpdated() {
        
        let confirmed = UserDataContainer.shared.getUserEmailConfirmed()
        
        verifiedIconImage.isHidden = !confirmed
        emailVerificationViewHeightConstraint.constant = confirmed ? 0 : 80
        emailNotVerifiedLabel.isHidden = confirmed
        resendEmailVerificationButton.isHidden = confirmed
        
    }
    
    fileprivate func sendNotificationForUserEmailConfirmationUpdate() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "userEmailConfirmationUpdated"), object: nil)
    }
    
}

//MARK: - InitialPageHeaderViewDelegate

extension UserProfileScreenViewController: InitialPageHeaderViewDelegate {
    
    func mainMenuButtonIsPressed() {
        contentDelegate?.openMainMenu()
    }
    
}

//MARK: - IBActions

extension UserProfileScreenViewController {
    
    @IBAction func editButtonPressed(_ sender: UIButton) {
        let vcID = String(describing: EditUserProfileScreenViewController.self)
        contentDelegate?.requestLoadViewController(vcID, nil)
    }
    
    @IBAction func onResendUserEmailVerificationPressed(_ sender: UIButton) {
        
        if emailConfirmationRequested == true {
            return
        }
        
        emailConfirmationRequested = true
        
        // Set email confirmation button to disabled state
        let themeManager = ThemeManager.shared
        themeManager.setDCBlueTheme(
            to: resendEmailVerificationButton,
            ofType: .ButtonOptionStyle(
                label: "profile_txt_resend_verification_email".localized(),
                selected: false
            )
        )
        resendEmailVerificationButton.alpha = 0.5
        
        APIProvider.requestEmailConfirmation() { [weak self] confirmed, error in
            
            if let error = error {
                
                if error.errors.first == ErrorKey.userEmailConfirmed.rawValue {
                    //User already confirmed error
                    UserDataContainer.shared.setUserEmailConfirmed(true)
                    self?.userEmailConfirationUpdated()
                    self?.sendNotificationForUserEmailConfirmationUpdate()
                }
                
                UIAlertController.show(
                    controllerWithTitle: "error_popup_title".localized(),
                    message: error.toNSError().localizedDescription,
                    buttonTitle: "txt_ok".localized()
                )
                
                return
            }
            
            UIAlertController.show(
                controllerWithTitle: "info_popup_title".localized(),
                message: "profile_txt_verification_email_sent".localized(),
                buttonTitle: "txt_ok".localized()
            )
            
        }
    }
    
}
