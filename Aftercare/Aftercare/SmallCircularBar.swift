//
//  SmallCircularBar.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 9/15/17.
//  Copyright © 2017 Dimitar Grudev. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class SmallCircularBar: UIView {
    
    @IBOutlet weak var bar: KDCircularProgress!
    @IBOutlet weak var barLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
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
    
    func setValue(_ valueLabel: String, _ valueBar: Double = 0) {
        barLabel.text = valueLabel
        bar.angle = valueBar
    }
    
    func setTitle(_ label: String) {
        titleLabel.text = label
    }
    
}

//MARK: - apply theme

extension SmallCircularBar {
    
    func changeStyle(_ style: SmallCircularBarStyle) {
        customizeComponents(style)
    }
    
    fileprivate func customizeComponents(_ style: SmallCircularBarStyle = .dark) {
        
        switch style {
            case .dark:
                darkThemed()
                break
            case .light:
                lightThemed()
                break
        }
    }
    
    fileprivate func darkThemed() {
        
        bar.startAngle = -90
        bar.progressThickness = 0.12
        bar.trackThickness = 0.06
        bar.trackColor = UIColor.dntCeruleanBlue
        bar.clockwise = true
        bar.gradientRotateSpeed = 2
        bar.roundedCorners = true
        bar.glowMode = .noGlow
        bar.set(colors: UIColor.dntCeruleanBlue, UIColor.dntCeruleanBlue)
        bar.angle = 0
        
        barLabel.textColor = .dntCeruleanBlue
        barLabel.font = UIFont.dntLatoRegularFontWith(size: UIFont.dntLabelFontSize)
        barLabel.adjustsFontSizeToFitWidth = true
        
        titleLabel.textColor = .dntCeruleanBlue
        titleLabel.font = UIFont.dntLatoRegularFontWith(size: UIFont.dntNoteFontSize)
        
    }
    
    fileprivate func lightThemed() {
        
        bar.startAngle = -90
        bar.progressThickness = 0.08
        bar.trackThickness = 0.06
        bar.trackColor = UIColor.white.withAlphaComponent(0.5)
        bar.clockwise = true
        bar.gradientRotateSpeed = 2
        bar.roundedCorners = true
        bar.glowMode = .noGlow
        bar.set(colors: UIColor.white, UIColor.white)
        bar.angle = 0
        
        barLabel.textColor = UIColor.white
        barLabel.font = UIFont.dntLatoRegularFontWith(size: UIFont.dntLabelFontSize)
        barLabel.adjustsFontSizeToFitWidth = true
        
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.dntLatoRegularFontWith(size: UIFont.dntNoteFontSize)
        
    }
    
}

enum SmallCircularBarStyle {
    case dark
    case light
}
