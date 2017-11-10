//
// Aftercare
// Created by Dimitar Grudev on 6.11.17.
// Copyright © 2017 Stichting Administratiekantoor Dentacoin.
//

import UIKit
import EasyTipView

@IBDesignable
class ActionBarsView: UIView {
    
    @IBOutlet weak var lastBar: SmallCircularBar!
    @IBOutlet weak var leftBar: SmallCircularBar!
    @IBOutlet weak var earnedBar: SmallCircularBar!
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
        customizeComponents()
        invalidateIntrinsicContentSize()
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
        invalidateIntrinsicContentSize()
    }
    
    override var intrinsicContentSize: CGSize {
        if let frame = contentView?.frame {
            return CGSize(width: UIViewNoIntrinsicMetric, height: frame.size.height)
        }
        return CGSize(width: UIViewNoIntrinsicMetric, height: UIViewNoIntrinsicMetric)
    }

    //MARK: - public api
    
    func setLastBarValue(_ value: Int, _ type: ActionRecordType) {
        let lastTimeProgress = UserDataContainer.shared.getActionsLastTimeBarProgress(Double(value), type)
        let lastTimeLabel = SystemMethods.Utils.secondsToHumanReadableFormat(value)
        self.lastBar.setValue(lastTimeLabel, lastTimeProgress)
    }
    
    func setLeftBarValue(_ value: Int, forType type: ActionRecordType) {
        let leftProgress = UserDataContainer.shared.getActionsLeftBarProgress(Double(value), forType: type)
        self.leftBar.setValue(String(value), leftProgress)
    }
    
    func setEarnedBarValue(_ value: Int) {
        self.earnedBar.setValue(String(value))
    }
    
    func showTutorials() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: { [weak self] in
            let tooltips: [(id: String ,text: String, forView: UIView, arrowAt: EasyTipView.ArrowPosition)] = [
                (
                    id: TutorialIDs.lastActivityTime.rawValue,
                    text: NSLocalizedString("Last recorded time", comment: ""),
                    forView: (self?.lastBar)!,
                    arrowAt: EasyTipView.ArrowPosition.bottom
                ), (
                    id: TutorialIDs.leftActivitiesCount.rawValue,
                    text: NSLocalizedString("Remaining activities for today", comment: ""),
                    forView: (self?.leftBar)!,
                    arrowAt: EasyTipView.ArrowPosition.top
                ), (
                    id: TutorialIDs.dcnEarned.rawValue,
                    text: NSLocalizedString("Earned DCN from this activity", comment: ""),
                    forView: (self?.earnedBar)!,
                    arrowAt: EasyTipView.ArrowPosition.bottom
                )
            ]
            
            for tooltip in tooltips {
                self?.showTooltip(
                    tooltip.text,
                    forView: tooltip.forView,
                    at: tooltip.arrowAt,
                    id: tooltip.id
                )
            }
        })
    }
    
    
    
    //MARK: - internal logic
    
    fileprivate func customizeComponents() {
        
        #if TARGET_INTERFACE_BUILDER
            
            leftBar.setTitle(NSLocalizedString("Left Bar", comment: ""))
            
            lastBar.setTitle(NSLocalizedString("Last Bar", comment: ""))
            
            earnedBar.setTitle(NSLocalizedString("Earned Bar", comment: ""))
            
        #endif
        
        self.backgroundColor = .clear
    }
    
    //TODO: move this into protocol
    
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
                withinSuperview: forView.superview,
                text: tooltipText,
                preferences: preferences,
                delegate: self,
                id: id
            )
            
            //set to false so next time user opens the same screen this will not show
            UserDataContainer.shared.setTutorialSessionToggle(id, false)
            
        }
    }
    
}

//MARK: - EasyTipViewDelegate

extension ActionBarsView: EasyTipViewDelegate {
    
    func easyTipViewDidDismiss(_ tipView: EasyTipView) {
        //turn off tooltip if dismissed by the user
        UserDataContainer.shared.setTutorialToggle(tipView.accessibilityIdentifier ?? "", false)
    }
    
}
