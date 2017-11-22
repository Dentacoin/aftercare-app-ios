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
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var bar: KDCircularProgress!
    @IBOutlet weak var centerLabel: UILabel!
    
    //MARK: - fileprivate vars
    
    fileprivate var contentView : UIView?
    
    //MARK: - IBDesignable Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        customizeComponents()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeAfter(using aDecoder: NSCoder) -> Any? {
        if self.subviews.count == 0 {
            setup()
        }
        return self
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        customizeComponents()
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        calculateLayouts()
    }
    
}

//MARK: - apply theme and appearance

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
        
        var labelFrame = centerLabel.frame
        let barFrame = bar.frame
        labelFrame.size.width = barFrame.width / 2
        labelFrame.size.height = barFrame.height / 2
        labelFrame.origin.x = barFrame.origin.x + (barFrame.width - labelFrame.size.width) / 2
        labelFrame.origin.y = barFrame.origin.y + (barFrame.height - labelFrame.size.height) / 2
        centerLabel.frame = labelFrame
        
    }
    
    fileprivate func calculateLayouts() {
        
        let containerPadding: CGFloat = 8
        let screenRect = self.bounds
        let positionRectSide = min(screenRect.height, screenRect.width) - (2 * containerPadding)
        
        let positionRect = CGRect(
            x: containerPadding,
            y: containerPadding,
            width: positionRectSide,
            height: positionRectSide
        )
        
        let containerSize = container.frame
        let widthScale: CGFloat = positionRect.width / containerSize.width
        let heightScale: CGFloat = positionRect.height / containerSize.height
        let scaleFactor = min(widthScale, heightScale)
        
        container.transform = container.transform.scaledBy(x: scaleFactor, y: scaleFactor)
        var containerFrame = container.frame
        containerFrame.origin.x = (screenRect.width - containerFrame.width) / 2
        containerFrame.origin.y = (screenRect.height - containerFrame.height) / 2
        
        container.frame = containerFrame
        
    }

}
