//
//  ActionHeaderView.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 9/8/17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class ActionHeaderView: UIView {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var mainMenuButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var flossButton: UIButton!
    @IBOutlet weak var brushButton: UIButton!
    @IBOutlet weak var rinseButton: UIButton!
    @IBOutlet weak var headerContentTopPadding: NSLayoutConstraint!
    
    //MARK: - delegate
    
    weak var delegate: ActionHeaderViewDelegate?
    
    //MARK: - fileprivate vars
    
    fileprivate var contentView : UIView?
    fileprivate var lastTabBarButtonPressed: UIButton?
    fileprivate var lastTabBarIndex = -1
    fileprivate var tabsArray: [UIButton]?
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
        
        tabsArray = [flossButton, brushButton, rinseButton]
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
    
    //MARK: - public api
    
    func selectTab(atIndex index: Int) {
        
        //if index == self.lastTabBarIndex { return }
        
        let themeManager = ThemeManager.shared
        
        if let lastPressed = self.lastTabBarButtonPressed {
            themeManager.setDCBlueTheme(
                to: lastPressed,
                ofType: .ButtonTabStyle(
                    label: (lastPressed.titleLabel?.text)!
                )
            )
        }
        
        if let tabs = self.tabsArray, index >= 0 && index < tabs.count {
            if let selectButton = tabsArray?[index] {
                
                themeManager.setDCBlueTheme(
                    to: selectButton,
                    ofType: .ButtonTabSelectedStyle(
                        label: (selectButton.titleLabel?.text)!
                    )
                )
                self.lastTabBarButtonPressed = selectButton
                self.lastTabBarIndex = index
                
                return
            }
        }
            
        self.lastTabBarButtonPressed = nil
        self.lastTabBarIndex = -1
        
    }
    
}

//MARK: - apply theme

extension ActionHeaderView {
    
    fileprivate func customizeComponents() {
        
        let themeManager = ThemeManager.shared
        themeManager.setDCBlueTheme(to: mainMenuButton, ofType: .ButtonMainMenu)
        mainMenuButton.addTarget(self, action: Selector.mainMenuButtonSelector, for: .touchUpInside)
        
        titleLabel.textColor = .white
        titleLabel.font = UIFont.dntLatoLightFont(size: UIFont.dntHeaderTitleFontSize)
        
        themeManager.setDCBlueTheme(to: flossButton, ofType: .ButtonTabStyle(label: NSLocalizedString("FLOSS", comment: "")))
        flossButton.addTarget(self, action: Selector.tabBarButtonPressed, for: .touchUpInside)
        
        themeManager.setDCBlueTheme(to: brushButton, ofType: .ButtonTabStyle(label: NSLocalizedString("BRUSH", comment: "")))
        brushButton.addTarget(self, action: Selector.tabBarButtonPressed, for: .touchUpInside)
        
        themeManager.setDCBlueTheme(to: rinseButton, ofType: .ButtonTabStyle(label: NSLocalizedString("RINSE", comment: "")))
        rinseButton.addTarget(self, action: Selector.tabBarButtonPressed, for: .touchUpInside)
        
        //default selected floss tab button
        self.selectTab(atIndex: 0)
    }
    
}

//MARK: - IBActions and button selectors

extension ActionHeaderView {
    
    @objc fileprivate func tabBarButtonPressed(_ sender: UIButton) {
        
        let themeManager = ThemeManager.shared
        
        if let btn = lastTabBarButtonPressed, let label = lastTabBarButtonPressed?.titleLabel?.text {
            themeManager.setDCBlueTheme(
                to: btn,
                ofType: .ButtonTabStyle(label: label)
            )
        }
        
        lastTabBarButtonPressed = sender
        
        guard let senderLabel = lastTabBarButtonPressed?.titleLabel?.text else { return }
        
        themeManager.setDCBlueTheme(
            to: sender,
            ofType: .ButtonTabSelectedStyle(label: senderLabel)
        )
        
        switch sender {
            case flossButton:
                delegate?.tabBarButtonPressed(0)
            case brushButton:
                delegate?.tabBarButtonPressed(1)
            case rinseButton:
                delegate?.tabBarButtonPressed(2)
            default:
                print("unknown tab bar pressed")
        }
    }
    
    @objc func mainMenuButtonPressed() {
        delegate?.mainMenuButtonIsPressed()
    }
}

//MARK: - HeaderHolderDelegate

extension ActionHeaderView: HeaderDelegate {
    
    func updateTitle(_ title: String) {
        titleLabel.text = title
    }
    
}

//MARK: - selectors

fileprivate extension Selector {
    static let tabBarButtonPressed = #selector(ActionHeaderView.tabBarButtonPressed(_:))
    static let mainMenuButtonSelector = #selector(ActionHeaderView.mainMenuButtonPressed)
}
