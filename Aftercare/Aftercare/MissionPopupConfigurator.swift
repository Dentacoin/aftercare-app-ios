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
            
            popup.titleLabel.text = NSLocalizedString("Day", comment: "") + " \(journey.day) of \(journey.targetDays)"
            
            popup.subTitleLabel.text = "Skipped routines \(journey.skipped) of \(journey.tolerance)"
            popup.subTitleLabel.alpha = 1
        } else {
            popup.titleLabel.text = NSLocalizedString("Welcome", comment: "")
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
        
        let linkContent = FBSDKShareLinkContent()
        linkContent.quote = NSLocalizedString("Improve your dental healt habits and earn some DCNs in the same time. Try Dentacare app available in the App Store.", comment: "")
        linkContent.contentURL = URL(string: "https://itunes.apple.com/us/app/dentacare/id1274148338?ls=1&mt=8")
        popup.shareWithFacebook.shareContent = linkContent
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        
        let shareTitle = NSAttributedString(
            string: NSLocalizedString("Share", comment: ""),
            attributes: [NSAttributedStringKey.paragraphStyle: paragraph]
        )
        
        popup.shareWithFacebook.setAttributedTitle(shareTitle, for: .normal)
        popup.shareWithFacebook.setAttributedTitle(shareTitle, for: .highlighted)
        popup.cancelable = true
    }
    
    fileprivate static func configJourneyStart(_ popup: MissionPopupScreen) {
        
        toggleFacebookButton(false, forPopup: popup)
        
        guard let journey = UserDataContainer.shared.journey else {
            return
        }
        
        popup.titleLabel.text = NSLocalizedString("Start your journey", comment: "")
        popup.subTitleLabel.text = NSLocalizedString("towards a beautiful smile", comment: "")
        
        popup.descriptionTextView.text = NSLocalizedString("Complete \(journey.targetDays) days of\nconsecutive morning and\nevening routines.\n\nComplete \(journey.targetDays * 2) routines with \(journey.tolerance)\nroutines tolerance and collect\nyour DCN reward!", comment: "")
        let actionButtonLabel = NSLocalizedString("Start Jorney", comment: "")
        popup.actionButton.setTitle(actionButtonLabel, for: .normal)
        popup.actionButton.setTitle(actionButtonLabel, for: .highlighted)
        popup.cancelable = false
    }
    
    fileprivate static func configJourneyFailed(_ popup: MissionPopupScreen) {
        
        toggleFacebookButton(false, forPopup: popup)
        
        popup.titleLabel.text = NSLocalizedString("Oh No...", comment: "")
        popup.subTitleLabel.text = NSLocalizedString("journey failed!", comment: "")
        
        var daysTolerance: Int = 10
        if let journey = UserDataContainer.shared.journey {
            //journey.tolerance is missed routines tolerance. Devide by two we get missed days
            daysTolerance = journey.tolerance / 2
        }
        
        popup.descriptionTextView.text = NSLocalizedString("Unfortuantely you exceeded\nyour \(daysTolerance) days tolerance.\nTherefore you have to start your\njourney over!", comment: "")
        
        let actionButtonLabel = NSLocalizedString("Start Over", comment: "")
        popup.actionButton.setTitle(actionButtonLabel, for: .normal)
        popup.actionButton.setTitle(actionButtonLabel, for: .highlighted)
        popup.cancelable = false
    }
    
    fileprivate static func configJourneyEnd(_ popup: MissionPopupScreen) {
        
        toggleFacebookButton(false, forPopup: popup)
        
        guard let journey = UserDataContainer.shared.journey else {
            return
        }
        
        popup.titleLabel.text = NSLocalizedString("Congratulations!", comment: "")
        popup.subTitleLabel.text = NSLocalizedString("journey completed!", comment: "")
        
        popup.descriptionTextView.text = NSLocalizedString("You have completed your \(journey.targetDays)\ndays jorney congratulations!\nYou can collect your reward\nnow!", comment: "")
        let actionButtonLabel = NSLocalizedString("Collect Reward", comment: "")
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
