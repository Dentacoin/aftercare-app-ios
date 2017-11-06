//
//  InitialPageHeaderView.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 9/9/17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class InitialPageHeaderView: UIView {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var mainMenuButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var headerContentTopPadding: NSLayoutConstraint!
    
    //MARK: - delegate
    
    weak var delegate: InitialPageHeaderViewDelegate?
    
    //MARK: - fileprivate vars
    
    fileprivate var contentView : UIView?
    fileprivate var calculatedConstraints = false
    
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
        self.customizeComponents()
    }
    
    override func layoutSubviews() {
        if #available(iOS 11.0, *) {
            if !calculatedConstraints {
                calculatedConstraints = true
                let topPadding = self.safeAreaInsets.top
                headerContentTopPadding.constant += topPadding
            }
        }
    }
}

//MARK: - apply theme

extension InitialPageHeaderView {
    
    func customizeComponents() {
        
        let themeManager = ThemeManager.shared
        themeManager.setDCBlueTheme(to: mainMenuButton, ofType: .ButtonMainMenu)
        mainMenuButton.addTarget(self, action: Selector.mainMenuButtonSelector, for: .touchUpInside)
        
        titleLabel.textColor = .white
        titleLabel.font = UIFont.dntLatoLightFont(size: UIFont.dntHeaderTitleFontSize)
        
    }
    
}

//MARK: - IBActions

extension InitialPageHeaderView {
    
    @IBAction func mainMenuButtonPressed(_ sender: UIButton) {
        delegate?.mainMenuButtonIsPressed()
    }
    
}

//MARK: - HeaderHolderDelegate

extension InitialPageHeaderView: HeaderDelegate {
    
    func updateTitle(_ title: String) {
        titleLabel.text = title
    }
    
}

//MARK: - selectors

fileprivate extension Selector {
    static let mainMenuButtonSelector = #selector(InitialPageHeaderView.mainMenuButtonPressed)
}
