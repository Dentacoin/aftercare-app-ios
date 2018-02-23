//
// Aftercare
// Created by Dimitar Grudev on 7.11.17.
// Copyright © 2017 Stichting Administratiekantoor Dentacoin.
//

import Foundation
import UIKit
import FBSDKCoreKit
import FBSDKShareKit

class RoutinesPopupScreen: UIView {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var currentDayLabel: UILabel!
    @IBOutlet weak var daysTotalLabel: UILabel!
    @IBOutlet weak var startRoutineButton: UIButton!
    @IBOutlet weak var shareWithFacebook: FBSDKShareButton!
    @IBOutlet weak var routineTextView: UITextView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    
    //MARK: - Delegates
    
    var delegate: RoutinesPopupScreenDelegate?
    
    //MARK: - Public variables
    
    var popupType: RoutinesPopupType = .start {
        didSet {
            updateState()
        }
    }
    
    //MARK: - Lifecycle
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        setup()
    }
    
    //MARK: - Fileprivates
    
    fileprivate var currentDay: Int = 0
    fileprivate var routine: Routine?
    
    //MARK: - Detect touches
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            let frame = containerView.frame
            if !frame.contains(location) {
                self.delegate?.onRoutinesClosed()
                self.removeFromSuperview()
            }
        }
    }
    
    //MARK: - Public API
    
    func setup(_ routine: Routine) {
        self.routine = routine
    }
    
    //MARK: - Theme and appearance
    
    fileprivate func setup() {
        
        currentDayLabel.textColor = .white
        currentDayLabel.font = UIFont.dntLatoBlackFont(size: UIFont.dntLargeTitleFontSize)
        currentDayLabel.text = NSLocalizedString("Day", comment: "") + " 0"
        
        daysTotalLabel.textColor = UIColor.lightGray
        daysTotalLabel.font = UIFont.dntLatoRegularFontWith(size: UIFont.dntButtonFontSize)
        daysTotalLabel.text = NSLocalizedString("of", comment: "") + " "  + String(90)
        
        routineTextView.textColor = .white
        routineTextView.font = UIFont.dntLatoRegularFontWith(size: UIFont.dntNormalTextSize)
        routineTextView.isUserInteractionEnabled = false
        routineTextView.isMultipleTouchEnabled = false
        routineTextView.contentMode = .center
        
        containerView.layer.masksToBounds = false
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset =  CGSize(width: 1.0, height: 2.0)
        containerView.layer.shadowOpacity = 1
        containerView.layer.shadowRadius = 20
        
        closeButton.tintColor = .white
        
        //create Facebook Share Button
        let linkContent = FBSDKShareLinkContent()
        linkContent.quote = NSLocalizedString("Improve your dental healt habits and earn some DCNs in the same time. Try Dentacare app available in the App Store.", comment: "")
        linkContent.contentURL = URL(string: "https://itunes.apple.com/us/app/dentacare/id1274148338?ls=1&mt=8")
        shareWithFacebook.shareContent = linkContent
        let shareWithFBTitle = NSLocalizedString("Share With Facebook", comment: "")
        shareWithFacebook.setTitle(shareWithFBTitle, for: .normal)
        shareWithFacebook.setTitle(shareWithFBTitle, for: .highlighted)
        self.layoutIfNeeded()
        
        self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        let themeManager = ThemeManager.shared
        
        themeManager.setDCBlueTheme(
            to: startRoutineButton,
            ofType: DCBlueThemeTypes.ButtonOptionStyle(
                label: self.routine?.startButtonTitle ?? "",
                selected: false
            )
        )
    }
    
    fileprivate func updateState() {
        
        if self.popupType == .start {
            
            self.shareWithFacebook.isUserInteractionEnabled = false
            self.shareWithFacebook.alpha = 0
            self.startRoutineButton.isUserInteractionEnabled = true
            self.startRoutineButton.alpha = 1
            self.daysTotalLabel.alpha = 1
            
            self.currentDay = UserDataContainer.shared.dayNumberOf90DaysSession ?? 0
            self.currentDayLabel.text = NSLocalizedString("Day", comment: "") + " \(currentDay)"
            
            self.routineTextView.text = self.routine?.startDescription
            self.startRoutineButton.setTitle(self.routine?.startButtonTitle, for: .normal)
            self.startRoutineButton.setTitle(self.routine?.startButtonTitle, for: .highlighted)
            
        } else {
            
            self.shareWithFacebook.isUserInteractionEnabled = true
            self.shareWithFacebook.alpha = 1
            self.startRoutineButton.isUserInteractionEnabled = false
            self.startRoutineButton.alpha = 0
            self.daysTotalLabel.alpha = 0
            
            self.currentDayLabel.text = self.routine?.endTitle
            self.routineTextView.text = self.routine?.endDescription
            
            if let type = self.routine?.type {
                SoundManager.shared.playSound(SoundType.sound(type, .rinse, .done(.congratulations)))
            }
            
        }
        
    }
    
    //MARK: - IBActions
    @IBAction func routineButtonPressed(_ sender: UIButton) {
        delegate?.onRoutinesButtonPressed()
    }
    
    @IBAction func closeRoutinesButtonIsPressed(_ sender: UIButton) {
        self.delegate?.onRoutinesClosed()
        self.removeFromSuperview()
    }
}

//MARK: - Delegate protocol

protocol RoutinesPopupScreenDelegate {
    func onRoutinesButtonPressed()
    func onRoutinesClosed()
}

//MARK: - Routines Popup Type

enum RoutinesPopupType {
    case start
    case end
}
