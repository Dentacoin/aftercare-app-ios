//
// Aftercare
// Created by Dimitar Grudev on 6.11.17.
// Copyright © 2017 Stichting Administratiekantoor Dentacoin.
//

import UIKit

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
        totalValueLabel.text = "DCN " + String(totalDCN)
    }
    
    //MARK: - private logic
    
    fileprivate func customizeComponents() {
        totalLabel.textColor = .dntWarmGrey
        totalLabel.font = UIFont.dntLatoRegularFontWith(size: UIFont.dntNoteFontSize)
        totalLabel.text = NSLocalizedString("TOTAL", comment: "")
        
        totalValueLabel.textColor = .dntCeruleanBlue
        totalValueLabel.font = UIFont.dntLatoRegularFontWith(size: UIFont.dntLargeTextSize)
        self.setTotalValue(totalDCN)
        
        self.backgroundColor = .clear
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
