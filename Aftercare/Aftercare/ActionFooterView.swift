//
// Aftercare
// Created by Dimitar Grudev on 6.11.17.
// Copyright © 2017 Stichting Administratiekantoor Dentacoin.
//

import UIKit
import EasyTipView

//TODO: Make IBDesignable a protocol and move all the logic for it there
@IBDesignable
class ActionFooterView: UIView {
    
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var statisticsButton: UIButton!
    
    //MARK: - Delegates
    
    var delegate: ActionFooterViewDelegate?
    
    //MARK: - fileprivate vars
    
    fileprivate var contentView : UIView?
    
    //MARK: - IBDesignable
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    fileprivate func setup() {
        contentView = loadViewFromNib()
        contentView!.frame = bounds
        contentView!.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        addSubview(contentView!)
    }
    
    fileprivate func loadViewFromNib() -> UIView! {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        customizeComponents()
    }
    
    //MARK: - public api
    
    func setActionButtonLabel(_ label: String, withState state: ActionButtonState) {
        
        //change action button appearance
        actionButton.setTitle(label, for: .normal)
        actionButton.setTitle(label, for: .highlighted)
        
        let themeManager = ThemeManager.shared
        
        switch state {
            case .blue:
                themeManager.setDCBlueTheme(to: actionButton, ofType: .ButtonDefaultBlueGradient)
                break
            case .red:
                themeManager.setDCBlueTheme(to: actionButton, ofType: .ButtonDefaultRedGradient)
                break
        }
        
    }
    
    func showTutorials() {
        let tooltips: [(id: String ,text: String, forView: UIView, arrowAt: EasyTipView.ArrowPosition)] = [
            (
                id: TutorialIDs.dashboardStatistics.rawValue,
                text: NSLocalizedString("Tap to open statistics", comment: ""),
                forView: (statisticsButton)!,
                arrowAt: EasyTipView.ArrowPosition.bottom
            )
        ]
        
        for tooltip in tooltips {
            showTooltip(
                tooltip.text,
                forView: tooltip.forView,
                at: tooltip.arrowAt,
                id: tooltip.id
            )
        }
    }
    
    //MARK: - private api
    
    fileprivate func customizeComponents() {
        //initial label and state
        setActionButtonLabel("Action", withState: .blue)
        
        self.backgroundColor = .clear
    }
    
    //TODO: move this in protocol
    fileprivate func showTooltip(_ text: String, forView: UIView, at position: EasyTipView.ArrowPosition, id: String) {
        
        //check if already seen by the user in this app session. "True" means still valid for this session
        var active = UserDataContainer.shared.getTutorialSessionToggle(id)//session state
        active = UserDataContainer.shared.getTutorialToggle(id)//between session state
        
        if  active {
            
            var preferences = ThemeManager.shared.tooltipPreferences
            preferences.drawing.arrowPosition = position
            
            let tooltipText = NSLocalizedString(
                text,
                comment: ""
            )
            
            EasyTipView.show(
                forView: forView,
                withinSuperview: self,
                text: tooltipText,
                preferences: preferences,
                delegate: self,
                id: id
            )
            
            //set to false so next time user opens the same screen this will not show
            UserDataContainer.shared.setTutorialSessionToggle(id, false)
            
        }
    }
    
    //MARK: - IBActions
    
    @IBAction func actionButtonPressed(_ sender: UIButton) {
        delegate?.onActionButtonPressed()
    }
    
    @IBAction func statisticsButtonPressed(_ sender: UIButton) {
        delegate?.onStatisticsButtonPressed()
    }
    
}

//MARK: - Action Button State Types

enum ActionButtonState {
    case blue
    case red
}

//MARK: - ActionFooterViewDelegate

protocol ActionFooterViewDelegate {
    func onActionButtonPressed()
    func onStatisticsButtonPressed()
}

//MARK: - EasyTipViewDelegate

extension ActionFooterView: EasyTipViewDelegate {
    
    func easyTipViewDidDismiss(_ tipView: EasyTipView) {
        //turn off tooltip if dismissed by the user
        UserDataContainer.shared.setTutorialToggle(tipView.accessibilityIdentifier ?? "", false)
    }
    
}
