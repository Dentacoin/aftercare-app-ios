//
// Aftercare
// Created by Dimitar Grudev on 6.11.17.
// Copyright © 2017 Stichting Administratiekantoor Dentacoin.
//

import UIKit
import EasyTipView

@IBDesignable
class TotalDCNBar: UIView {
    
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var totalValueLabel: UILabel!
    
    //MARK: - Delegate
    
    var delegate: TotalDCNBarDelegate?
    
    //MARK: - fileprivate vars
    
    fileprivate var contentView : UIView?
    fileprivate var totalDCN: Int = 0
    
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
    
    func setTotalValue(_ total: Int) {
        totalDCN = total
        totalValueLabel.text = String(totalDCN) + " DCN"
    }
    
    func showTutorials() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: { [weak self] in
            let tooltips: [(id: String ,text: String, forView: UIView, arrowAt: EasyTipView.ArrowPosition)] = [
                (
                    id: TutorialIDs.totalDcn.rawValue,
                    text: NSLocalizedString("This is the total amount of DCN you've earned.", comment: ""),
                    forView: self!,
                    arrowAt: EasyTipView.ArrowPosition.top
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
    
    
    
    //MARK: - private logic
    
    fileprivate func customizeComponents() {
        totalLabel.textColor = .dntWarmGrey
        totalLabel.font = UIFont.dntLatoLightFont(size: UIFont.dntNoteFontSize)
        totalLabel.text = NSLocalizedString("TOTAL", comment: "")
        
        totalValueLabel.textColor = .dntCeruleanBlue
        totalValueLabel.font = UIFont.dntLatoLightFont(size: UIFont.dntButtonFontSize)
        self.setTotalValue(totalDCN)
        
        self.backgroundColor = .clear
    }
    
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
    //MARK: - IBActions
    
    @IBAction func totalBarButtonPressed(_ sender: UIButton) {
        delegate?.onTotalBarPressed()
    }
    
}

//MARK: - TotalDCNBarDelegate

protocol TotalDCNBarDelegate {
    func onTotalBarPressed()
}

//MARK: - EasyTipViewDelegate

extension TotalDCNBar: EasyTipViewDelegate {
    
    func easyTipViewDidDismiss(_ tipView: EasyTipView) {
        //turn off tooltip if dismissed by the user
        UserDataContainer.shared.setTutorialToggle(tipView.accessibilityIdentifier ?? "", false)
    }
    
}
