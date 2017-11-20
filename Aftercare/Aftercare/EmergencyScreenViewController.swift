//
//  EmergencyScreenViewController.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 9/9/17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import Foundation
import UIKit

class EmergencyScreenViewController: UIViewController, ContentConformer {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var headerView: UIView?
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var mouthContainer: UIView!
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomContentPadding: NSLayoutConstraint!
    
    //Teeths
    @IBOutlet weak var tooth01: UIButton!
    @IBOutlet weak var tooth02: UIButton!
    @IBOutlet weak var tooth03: UIButton!
    @IBOutlet weak var tooth04: UIButton!
    @IBOutlet weak var tooth05: UIButton!
    @IBOutlet weak var tooth06: UIButton!
    @IBOutlet weak var tooth07: UIButton!
    @IBOutlet weak var tooth08: UIButton!
    @IBOutlet weak var tooth09: UIButton!
    @IBOutlet weak var tooth10: UIButton!
    @IBOutlet weak var tooth11: UIButton!
    @IBOutlet weak var tooth12: UIButton!
    @IBOutlet weak var tooth13: UIButton!
    @IBOutlet weak var tooth14: UIButton!
    @IBOutlet weak var tooth15: UIButton!
    @IBOutlet weak var tooth16: UIButton!
    @IBOutlet weak var tooth17: UIButton!
    @IBOutlet weak var tooth18: UIButton!
    @IBOutlet weak var tooth19: UIButton!
    @IBOutlet weak var tooth20: UIButton!
    @IBOutlet weak var tooth21: UIButton!
    @IBOutlet weak var tooth22: UIButton!
    @IBOutlet weak var tooth23: UIButton!
    @IBOutlet weak var tooth24: UIButton!
    @IBOutlet weak var tooth25: UIButton!
    @IBOutlet weak var tooth26: UIButton!
    @IBOutlet weak var tooth27: UIButton!
    @IBOutlet weak var tooth28: UIButton!
    @IBOutlet weak var tooth29: UIButton!
    @IBOutlet weak var tooth30: UIButton!
    @IBOutlet weak var tooth31: UIButton!
    @IBOutlet weak var tooth32: UIButton!
    
    var contentDelegate: ContentDelegate?
    
    //MARK: - Public
    
    var header: InitialPageHeaderView! {
        return headerView as! InitialPageHeaderView
    }
    
    //MARK: - Fileprivates
    
    fileprivate var teeth: [UIButton] = []
    fileprivate var teethsStateKeeper: [Int : UIButton?] = [:]
    fileprivate var calculatedConstraints = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        header.delegate = self
        
        teeth = [
            tooth01, tooth02, tooth03, tooth04, tooth05, tooth06, tooth07, tooth08, tooth09, tooth10,
            tooth11, tooth12, tooth13, tooth14, tooth15, tooth16, tooth17, tooth18, tooth19, tooth20,
            tooth21, tooth22, tooth23, tooth24, tooth25, tooth26, tooth27, tooth28, tooth29, tooth30,
            tooth31, tooth32
        ]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setup()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        calculateLayouts()
    }
    
    //MARK: - internal logic
    
    @objc fileprivate func toothButtonPressed(_ sender: UIButton) {
        
        let themeManager = ThemeManager.shared
        
        if let button = teethsStateKeeper[sender.tag], button != nil {
            
            teethsStateKeeper.updateValue(nil, forKey: (button!.tag))
            themeManager.setDCBlueTheme(to: button!, ofType: .ButtonTooth(color: .red, selected: false))
            
        } else {
            
            teethsStateKeeper.updateValue(sender, forKey: sender.tag)
            themeManager.setDCBlueTheme(to: sender, ofType: .ButtonTooth(color: .red, selected: true))
            
        }
        
    }
    
}

//MARK: - Theme and appearance

extension EmergencyScreenViewController {
    
    fileprivate func setup() {
        
        header.updateTitle(NSLocalizedString("Emergency", comment: ""))
        
        titleLabel.textColor = UIColor.dntCeruleanBlue
        titleLabel.font = UIFont.dntLatoLightFont(size: UIFont.dntTitleFontSize)
        titleLabel.text = NSLocalizedString("Select a sick tooth", comment: "")
        
        let themeManager = ThemeManager.shared
        
        themeManager.setDCBlueTheme(to: nextButton, ofType: .ButtonDefaultBlueGradient)
        nextButton.setTitle(NSLocalizedString("Next", comment: ""), for: .normal)
        nextButton.setTitle(NSLocalizedString("Next", comment: ""), for: .highlighted)
        
    }
    
    fileprivate func calculateLayouts() {
        
        //Scale and position Mouth Container on the screen
        
        let containerPadding: CGFloat = 8
        let titleRect = titleLabel.frame
        let screenRect = self.view.bounds
        let positionRectY = (titleRect.origin.y + titleRect.height + containerPadding)
        let positionRectHeight = (nextButton.frame.origin.y - containerPadding) - positionRectY
        
        let positionRect = CGRect(
            x: containerPadding,
            y: positionRectY,
            width: screenRect.size.width - (2 * containerPadding),
            height: positionRectHeight
        )
        
        let containerSize = mouthContainer.frame
        let widthScale: CGFloat = positionRect.width / containerSize.width
        let heightScale: CGFloat = positionRect.height / containerSize.height
        let scaleFactor = min(widthScale, heightScale)
        
        mouthContainer.transform = mouthContainer.transform.scaledBy(x: scaleFactor, y: scaleFactor)
        mouthContainer.frame.origin.x = positionRect.origin.x + ((positionRect.width - mouthContainer.frame.width) / 2)
        mouthContainer.frame.origin.y = positionRect.origin.y
        
        //Apply teeths styles
        
        let themeManager = ThemeManager.shared
        
        var tagId = 1
        
        for tooth in teeth {
            tooth.tag = tagId
            themeManager.setDCBlueTheme(to: tooth, ofType: .ButtonTooth(color: .red, selected: false))
            tooth.addTarget(self, action: Selector.toothButtonPressed, for: .touchUpInside)
            tagId += 1
        }
        
        if #available(iOS 11.0, *) {
            if !calculatedConstraints {
                calculatedConstraints = true
                let topPadding = self.view.safeAreaInsets.top
                headerHeightConstraint.constant += topPadding
                //let bottomPadding = self.view.safeAreaInsets.bottom
                //bottomContentPadding.constant -= bottomPadding
            }
        }
    }
    
}

//MARK: - IBActions

extension EmergencyScreenViewController {
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        
        UserDataContainer.shared.emergencyScreenImage = self.takeSnapshotOfView(mouthContainer)
        
        let vcID = String(describing: DescribeCaseScreenViewController.self)
        contentDelegate?.requestLoadViewController(vcID, nil)
        
    }
    
}

//MARK: - InitialPageHeaderViewDelegate

extension EmergencyScreenViewController: InitialPageHeaderViewDelegate {
    
    func mainMenuButtonIsPressed() {
        contentDelegate?.openMainMenu()
    }
    
}

//MARK: - Selectors helper

fileprivate extension Selector {
    static let toothButtonPressed = #selector(EmergencyScreenViewController.toothButtonPressed(_:))
}

//MARK: - Utils

extension EmergencyScreenViewController {
    
    fileprivate func takeSnapshotOfView(_ view: UIView) -> UIImage {
        
        UIGraphicsBeginImageContext(CGSize(width: view.frame.size.width, height: view.frame.size.height))
        view.drawHierarchy(
            in: CGRect(
                x: 0,
                y: 0,
                width: view.frame.size.width,
                height: view.frame.size.height
            ),
            afterScreenUpdates: true
        )
            let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
    
        return image!
    }
    
}

