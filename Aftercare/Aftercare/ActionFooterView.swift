//
// Aftercare
// Created by Dimitar Grudev on 6.11.17.
// Copyright © 2017 Stichting Administratiekantoor Dentacoin.
//

import UIKit

//TODO: Make IBDesignable a protocol and move all the logic for it there
@IBDesignable
class ActionFooterView: UIView {
    
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var statisticsButton: UIButton!
    
    //MARK: - Delegates
    
    var delegate: ActionFooterViewDelegate?
    
    //MARK: - public vars
    
    var isStatisticsButtonHidden: Bool = false {
        didSet {
            UIView.animate(withDuration: 0.5, animations: { [weak self] in
                if let isHidden = self?.isStatisticsButtonHidden {
                    self?.statisticsButton.alpha = isHidden ? 0 : 1
                }
            })
        }
    }
    
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
        contentView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
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
            case .red:
                themeManager.setDCBlueTheme(to: actionButton, ofType: .ButtonDefaultRedGradient)
        }
        
    }
    
    //MARK: - private api
    
    fileprivate func customizeComponents() {
        //initial label and state
        setActionButtonLabel("Action", withState: .blue)
        
        self.backgroundColor = .clear
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
