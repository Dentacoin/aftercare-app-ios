//
// Aftercare
// Created by Dimitar Grudev on 7.11.17.
// Copyright © 2017 Stichting Administratiekantoor Dentacoin.
//

import Foundation
import UIKit

class RoutinesPopupScreen: UIView {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var currentDayLabel: UILabel!
    @IBOutlet weak var daysTotalLabel: UILabel!
    @IBOutlet weak var startRoutineButton: UIButton!
    @IBOutlet weak var routineTextView: UITextView!
    @IBOutlet weak var containerView: UIView!
    
    //MARK: - Delegates
    
    var delegate: RoutinesPopupScreenDelegate?
    
    //MARK: - Fileprivates
    
    fileprivate var currentDay: Int = 0
    
    //MARK: - Lifecycle
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        setup()
    }
    
    //MARK: - Public API
    
    func setCurrentDay(_ day: Int) {
        currentDay = day
        currentDayLabel.text = NSLocalizedString("Day", comment: "") + " " + String(currentDay)
    }
    
    func setRoutinesDescription(_ description: String) {
        routineTextView.text = description
    }
    
    func setRoutinesStartLabel(_ label: String) {
        startRoutineButton.setTitle(label, for: .normal)
        startRoutineButton.setTitle(label, for: .highlighted)
    }
    
    //MARK: - Theme and appearance
    
    fileprivate func setup() {
        
        currentDayLabel.textColor = .white
        currentDayLabel.font = UIFont.dntLatoBlackFont(size: UIFont.dntLargeTitleFontSize)
        setCurrentDay(currentDay)
        
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
        
        self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        let themeManager = ThemeManager.shared
        
        themeManager.setDCBlueTheme(
            to: startRoutineButton,
            ofType: DCBlueThemeTypes.ButtonOptionStyle(
                label: startRoutineButton.titleLabel?.text ?? "",
                selected: false
            )
        )
    }
    
    //MARK: - IBActions
    @IBAction func routineButtonPressed(_ sender: UIButton) {
        delegate?.onRoutinesButtonPressed()
    }
    
}

//MARK: - Delegate protocol

protocol RoutinesPopupScreenDelegate {
    func onRoutinesButtonPressed()
}
