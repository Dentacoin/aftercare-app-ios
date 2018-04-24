//
// Aftercare
// Created by Dimitar Grudev on 6.11.17.
// Copyright © 2017 Stichting Administratiekantoor Dentacoin.
//

import UIKit
@IBDesignable
class ActionBarsView: UIView {
    
    @IBOutlet weak var lastBar: SmallCircularBar!
    @IBOutlet weak var leftBar: SmallCircularBar!
    @IBOutlet weak var dayBar: SmallCircularBar!
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
        let lastTimeLabel = SystemMethods.Utils.secondsToISO8601Format(value)
        self.lastBar.setValue(lastTimeLabel, lastTimeProgress)
    }
    
    func setLeftBarValue(_ value: Int, forType type: ActionRecordType) {
        let leftProgress = UserDataContainer.shared.getActionsLeftBarProgress(Double(value), forType: type)
        self.leftBar.setValue(String(value), leftProgress)
    }
    
    func setDayBarValue(_ value: Int, fromTotalOf total: Int) {
        if total < 0 {
            self.dayBar.setValue(String(0))
        } else {
            self.dayBar.setValue("\(value)/\(total)")
        }
    }
    
    //MARK: - internal logic
    
    fileprivate func customizeComponents() {
        
        #if TARGET_INTERFACE_BUILDER
            
            leftBar.setTitle("Last Bar")
            
            lastBar.setTitle("Routines Left")
            
            dayBar.setTitle("Day")
            
        #endif
        
        self.backgroundColor = .clear
    }
    
}
