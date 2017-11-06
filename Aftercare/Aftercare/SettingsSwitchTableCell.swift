//
//  NotificationsScreenTableCell.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 9/10/17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import UIKit

class SettingsSwitchTableCell: UITableViewCell {

    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var cellSwitch: UISwitch!
    
    //MARK: - Delegates
    
    weak var delegate: SettingsSwitchTableCellDelegate?
    
    //MARK: - Fileprivate vars
    
    fileprivate var indexPath: IndexPath?
    
    func config(_ indexPath: IndexPath) {
        self.indexPath = indexPath
        
        //apply theme style to the label
        cellLabel.textColor = UIColor.dntCharcoalGrey
        cellLabel.font = UIFont.dntLatoLightFont(size: UIFont.dntButtonFontSize)
        
        cellSwitch.tintColor = UIColor.dntCeruleanBlue
        cellSwitch.thumbTintColor = UIColor.dntCeruleanBlue
        cellSwitch.onTintColor = UIColor.dntCeruleanBlue.withAlphaComponent(0.5)
        cellSwitch.addTarget(self, action: Selector.switchSelector, for: .valueChanged)
    }
    
    @objc fileprivate func onSwitchToggled(_ uiswitch: UISwitch) {
        if let indexPath = self.indexPath {
            delegate?.onCellToggleSwitch(indexPath, uiswitch.isOn)
        }
    }
}

//MARK: - Delegate protocol

protocol SettingsSwitchTableCellDelegate: class {
    func onCellToggleSwitch(_ indexPath: IndexPath, _ value: Bool)
}

//MARK: - Selectors

fileprivate extension Selector {
    static let switchSelector = #selector(SettingsSwitchTableCell.onSwitchToggled(_:))
}
