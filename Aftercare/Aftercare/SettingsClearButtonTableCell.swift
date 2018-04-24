//
//  SettingsClearButtonTableCell.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 25.10.17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import UIKit

class SettingsClearButtonTableCell: UITableViewCell {
    
    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var cellButton: UIButton!
    
    //MARK: - Delegates
    
    weak var delegate: SettingsClearButtonTableCellDelegate?
    
    //MARK: - Fileprivate vars
    
    fileprivate var indexPath: IndexPath?
    
    func config(_ indexPath: IndexPath) {
        
        self.indexPath = indexPath
        
        //apply theme style to the label
        cellLabel.textColor = UIColor.dntCharcoalGrey
        cellLabel.font = UIFont.dntLatoLightFont(size: UIFont.dntButtonFontSize)
        
        let themeManager = ThemeManager.shared
        themeManager.setDCBlueTheme(to: cellButton, ofType: .ButtonActionStyle(label: "btn_settings_reset".localized(), selected: true))
        
        //cellButton.setTitle(, for: .normal)
        cellButton.addTarget(self, action: Selector.buttonSelector, for: .touchUpInside)
    }
    
    @objc func onClearButtonPressed(_ sender: UIButton) {
        if let indexPath = self.indexPath {
            delegate?.onClearButtonPressed(indexPath)
            
            let themeManager = ThemeManager.shared
            themeManager.setDCBlueTheme(to: cellButton, ofType: .ButtonActionStyle(label: "btn_settings_reset".localized(), selected: false))
            
        }
    }
    
}


//MARK: - Delegate protocol

protocol SettingsClearButtonTableCellDelegate: class {
    func onClearButtonPressed(_ indexPath: IndexPath)
}

//MARK: - Selectors

fileprivate extension Selector {
    static let buttonSelector = #selector(SettingsClearButtonTableCell.onClearButtonPressed(_:))
}
