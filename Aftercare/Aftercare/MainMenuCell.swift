//
//  MainMenuCell.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 9/8/17.
//  Copyright © 2017 Dimitar Grudev. All rights reserved.
//

import UIKit
import EasyTipView

class MainMenuCell: UITableViewCell {
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    fileprivate var activeTooltip = false
    
    func showTooltip(_ title: String, arrowPosition position: EasyTipView.ArrowPosition, id: String) {
        
        var active = UserDataContainer.shared.getTutorialSessionToggle(id)
        active = UserDataContainer.shared.getTutorialToggle(id)
        if !active { return }
        
        if activeTooltip { return }
        activeTooltip = true
        
        var preferences = ThemeManager.shared.tooltipPreferences
        preferences.drawing.arrowPosition = position
        
        let tooltipText = NSLocalizedString(
            title,
            comment: ""
        )
        
        EasyTipView.show(
            forView: label,
            withinSuperview: self.superview,
            text: tooltipText,
            preferences: preferences,
            delegate: self,
            id: id
        )
        
        //set to false so next time user opens the same screen this will not show
        UserDataContainer.shared.setTutorialSessionToggle(title, false)
        
    }
    
}

//MARK: - EasyTipViewDelegate

extension MainMenuCell: EasyTipViewDelegate {
    
    func easyTipViewDidDismiss(_ tipView: EasyTipView) {
        //turn off tooltip if dismissed by the user
        activeTooltip = false
        UserDataContainer.shared.setTutorialToggle(tipView.accessibilityIdentifier ?? "", false)
    }
    
}
