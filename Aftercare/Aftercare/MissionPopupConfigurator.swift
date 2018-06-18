//
// Aftercare
// Created by Dimitar Grudev on 28.02.18.
// Copyright © 2018 Stichting Administratiekantoor Dentacoin.
//

import Foundation
import FBSDKCoreKit
import FBSDKShareKit

struct MissionPopupConfigurator {
    
    static func config(_ popup: MissionPopupScreen, forType type: MissionPopupType) {
        
        popup.type = type
        
        switch type {
            case .routineStart:
                configRoutineStart(popup)
            case .routineEnd:
                configRoutineEnd(popup)
            case .journeyStart:
                configJourneyStart(popup)
            case .journeyFailed:
                configJourneyFailed(popup)
            case .journeyEnd:
                configJourneyEnd(popup)
        }
        
    }
    
    // MARK: - fileprivate configuration methods
    
    fileprivate static func configRoutineStart(_ popup: MissionPopupScreen) {
        
        guard let routine = UserDataContainer.shared.routine else {
            print("MissionPopupConfigurator : Missing active routine")
            return
        }
        
        toggleFacebookButton(false, forPopup: popup)
        
        if let journey = UserDataContainer.shared.journey {
            popup.titleLabel.text = "journey_hdl_daily".localized(String(journey.day), String(journey.targetDays))
            popup.subTitleLabel.text = "journey_sub_hdl_daily".localized(String(journey.skipped), String(journey.tolerance))
            popup.subTitleLabel.alpha = 1
        } else {
            popup.titleLabel.text = "welcome_txt_welcome"
            popup.subTitleLabel.alpha = 0
        }
        
        popup.descriptionTextView.text = routine.startDescription
        popup.actionButton.setTitle(routine.startButtonTitle, for: .normal)
        popup.actionButton.setTitle(routine.startButtonTitle, for: .highlighted)
        popup.cancelable = true
    }
    
    fileprivate static func configRoutineEnd(_ popup: MissionPopupScreen) {
        
        guard let routine = UserDataContainer.shared.routine else {
            print("MissionPopupConfigurator : Missing active routine")
            return
        }
        
        if let record = UserDataContainer.shared.lastRoutineRecord {
            popup.titleLabel.text?.append("\nDCN \(String(describing: record.earnedDCN)) earned!")
        } else {
            print("MissionPopupConfigurator : Missing routine record")
        }
        
        toggleFacebookButton(true, forPopup: popup)
        
        popup.titleLabel.text = routine.endTitle
        
        popup.subTitleLabel.alpha = 0
        popup.descriptionTextView.text = routine.endDescription
        
        var quote: String?
        if routine.type == .morning {
            quote = "fb_share_morning_routine_completed".localized()
        } else {
            quote = "fb_share_evening_routine_completed".localized()
        }
        
        let linkContent = FBSDKShareLinkContent()
        linkContent.quote = quote ?? ""
        linkContent.contentURL = URL(string: "https://itunes.apple.com/us/app/dentacare/id1274148338?ls=1&mt=8")
        popup.shareWithFacebook.shareContent = linkContent
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        
        let shareTitle = NSAttributedString(
            string: "btn_mission_popup_share".localized(),
            attributes: [NSAttributedStringKey.paragraphStyle: paragraph]
        )
        
        popup.shareWithFacebook.setAttributedTitle(shareTitle, for: .normal)
        popup.shareWithFacebook.setAttributedTitle(shareTitle, for: .highlighted)
        popup.cancelable = true
    }
    
    fileprivate static func configJourneyStart(_ popup: MissionPopupScreen) {
        
        toggleFacebookButton(false, forPopup: popup)
        
//        guard let journey = UserDataContainer.shared.journey else {
//            return
//        }
        
        popup.titleLabel.text = "journey_hdl_start".localized()
        popup.subTitleLabel.text = "journey_sub_hdl_start".localized()
        
        popup.descriptionTextView.text = "journey_txt_start_dp".localized(String(90), String(180), String(20))
        //journey_hdl_start
            
//            String(journey.targetDays),
//            String(journey.targetDays * 2),
//            String(journey.tolerance)
//        )
        let actionButtonLabel = "journey_btn_start".localized()
        popup.actionButton.setTitle(actionButtonLabel, for: .normal)
        popup.actionButton.setTitle(actionButtonLabel, for: .highlighted)
        popup.cancelable = false
    }
    
    fileprivate static func configJourneyFailed(_ popup: MissionPopupScreen) {
        
        toggleFacebookButton(false, forPopup: popup)
        
        popup.titleLabel.text = "journey_hdl_failed".localized()
        popup.subTitleLabel.text = "journey_sub_hdl_failed".localized()
        
//        var daysTolerance: Int = 10
//        if let journey = UserDataContainer.shared.journey {
//            //journey.tolerance is missed routines tolerance. Devide by two we get missed days
//            daysTolerance = journey.tolerance / 2
//        }
        
        popup.descriptionTextView.text = "journey_txt_failed".localized()
        
        let actionButtonLabel = "journey_btn_failed".localized()
        popup.actionButton.setTitle(actionButtonLabel, for: .normal)
        popup.actionButton.setTitle(actionButtonLabel, for: .highlighted)
        popup.cancelable = false
    }
    
    fileprivate static func configJourneyEnd(_ popup: MissionPopupScreen) {
        
        toggleFacebookButton(false, forPopup: popup)
        
//        guard let journey = UserDataContainer.shared.journey else {
//            return
//        }
        
        popup.titleLabel.text = "journey_hdl_completed".localized()
        popup.subTitleLabel.text = "journey_sub_hdl_completed".localized()
        
        popup.descriptionTextView.text = "journey_txt_completed".localized()
        let actionButtonLabel = "journey_btn_completed".localized()
        popup.actionButton.setTitle(actionButtonLabel, for: .normal)
        popup.actionButton.setTitle(actionButtonLabel, for: .highlighted)
        popup.cancelable = false
    }
    
    // MARK: - Helper methods
    
    fileprivate static func toggleFacebookButton(_ active: Bool, forPopup popup: MissionPopupScreen) {
        popup.shareWithFacebook.isUserInteractionEnabled = active
        popup.shareWithFacebook.alpha = active ? 1 : 0
        popup.actionButton.isUserInteractionEnabled = !active
        popup.actionButton.alpha = active ? 0 : 1
    }
    
}

enum MissionPopupType {
    case routineStart
    case routineEnd
    case journeyStart
    case journeyFailed
    case journeyEnd
}
