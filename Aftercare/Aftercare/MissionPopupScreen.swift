//
// Aftercare
// Created by Dimitar Grudev on 7.11.17.
// Copyright © 2017 Stichting Administratiekantoor Dentacoin.
//

import Foundation
import UIKit
import FBSDKCoreKit
import FBSDKShareKit

class MissionPopupScreen: UIView {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var shareWithFacebook: FBSDKShareButton!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    
    //MARK: - Delegates
    
    var delegate: MissionPopupScreenDelegate?
    
    //MARK: - Lifecycle
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        setup()
    }
    
    // MARK: - Public
    
    var currentDay: Int = 0
    
    var cancelable: Bool = false {
        didSet {
            closeButton.isUserInteractionEnabled = self.cancelable
            closeButton.isHidden = !self.cancelable
            closeButton.alpha = self.cancelable ? 1.0 : 0.0
        }
    }
    
    //MARK: - Fileprivates
    
    fileprivate var routine: Routine?
    
    //MARK: - Detect touches
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if cancelable {
            if let touch = touches.first {
                let location = touch.location(in: self)
                let frame = containerView.frame
                if !frame.contains(location) {
                    self.delegate?.onActionButtonPressed()
                    self.removeFromSuperview()
                }
            }
        }
    }
    
    //MARK: - Public API
    
    func setup(_ routine: Routine) {
        self.routine = routine
    }
    
    //MARK: - Theme and appearance
    
    fileprivate func setup() {
        
        titleLabel.textColor = .white
        titleLabel.font = UIFont.dntLatoBlackFont(size: UIFont.dntLargeTitleFontSize)
        titleLabel.text = NSLocalizedString("Day", comment: "") + " 0"
        
        subTitleLabel.textColor = UIColor.lightGray
        subTitleLabel.font = UIFont.dntLatoRegularFontWith(size: UIFont.dntButtonFontSize)
        subTitleLabel.text = NSLocalizedString("of", comment: "") + " "  + String(90)
        
        descriptionTextView.textColor = .white
        descriptionTextView.font = UIFont.dntLatoRegularFontWith(size: UIFont.dntNormalTextSize)
        descriptionTextView.isUserInteractionEnabled = false
        descriptionTextView.isMultipleTouchEnabled = false
        descriptionTextView.contentMode = .center
        
        containerView.layer.masksToBounds = false
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset =  CGSize(width: 1.0, height: 2.0)
        containerView.layer.shadowOpacity = 1
        containerView.layer.shadowRadius = 20
        
        closeButton.tintColor = .white
        
        self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        let themeManager = ThemeManager.shared
        
        themeManager.setDCBlueTheme(
            to: actionButton,
            ofType: DCBlueThemeTypes.ButtonOptionStyle(
                label: self.routine?.startButtonTitle ?? "",
                selected: false
            )
        )
    }
    
    //MARK: - IBActions
    
    @IBAction func onActionButtonPressed(_ sender: UIButton) {
        self.delegate?.onActionButtonPressed()
    }
    
    @IBAction func onCloseButtonPressed(_ sender: UIButton) {
        self.delegate?.onPopupClosed()
        self.removeFromSuperview()
    }
}

//MARK: - Delegate protocol

protocol MissionPopupScreenDelegate {
    func onActionButtonPressed()
    func onPopupClosed()
}
