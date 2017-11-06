//
//  CircularBar.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 9/14/17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class CircularBar: UIView {
    
    //MARK: - IBOutlets
    @IBOutlet weak var bar: KDCircularProgress!
    @IBOutlet weak var centerLabel: UILabel!
    
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
    
}

//MARK: - apply theme

extension CircularBar {
    
    fileprivate func customizeComponents() {
        
        bar.startAngle = -90
        bar.progressThickness = 0.21
        bar.trackThickness = 0.2
        bar.trackColor = UIColor.black.withAlphaComponent(0.1)
        bar.clockwise = true
        bar.gradientRotateSpeed = 2
        bar.roundedCorners = true
        bar.glowMode = .noGlow
        bar.set(colors: UIColor.dntBrightSkyBlue, UIColor.dntCeruleanBlue)
        
        centerLabel.textColor = .dntDarkSkyBlue
        centerLabel.font = UIFont.dntLatoLightFont(size: 120)
        centerLabel.adjustsFontSizeToFitWidth = true
        
    }
    
//    fileprivate func degToRad(angle: Double) -> Double {
//        return angle / 180 * .pi
//    }

}
