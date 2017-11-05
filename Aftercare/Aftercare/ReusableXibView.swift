//
//  ReusableXibView.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 26.10.17.
//  Copyright © 2017 Dimitar Grudev. All rights reserved.
//

import UIKit

class ReusableXibView: UIView {
    
    class func loadViewFromNib<T : UIView>() -> T? {
        let bundle = Bundle.main
        let nib = UINib(nibName:self.nibName(), bundle: bundle)
        let view = nib.instantiate(withOwner: nil, options: nil).first as? T
        return view
    }
    
    override func awakeAfter(using aDecoder: NSCoder) -> Any? {
        
        if self.subviews.count > 0 {
            return self
        }
        
        let bundle = Bundle(for: type(of: self))
        let nibName = type(of: self).nibName()
        let loadedViews = bundle.loadNibNamed(nibName, owner: nil, options: [:])
        guard let loadedView = loadedViews!.first as? UIView else {
            return nil
        }
        
        loadedView.frame = self.frame
        loadedView.autoresizingMask = self.autoresizingMask
        loadedView.translatesAutoresizingMaskIntoConstraints =
            self.translatesAutoresizingMaskIntoConstraints
        
        for constraint in constraints {
            var firstItem = constraint.firstItem
            if firstItem === self {
                firstItem = loadedView
            }
            var secondItem = constraint.secondItem
            if secondItem === self {
                secondItem = loadedView
            }
            
            let newConstraint = NSLayoutConstraint(item: firstItem!,
                                                   attribute: constraint.firstAttribute,
                                                   relatedBy: constraint.relation,
                                                   toItem: secondItem,
                                                   attribute: constraint.secondAttribute,
                                                   multiplier: constraint.multiplier,
                                                   constant: constraint.constant)
            loadedView.addConstraint(newConstraint)
        }
        
        return loadedView
        
    }
    
    class func nibName() -> String {
        assert(false, "Must be overriden")
        return ""
    }
}
