//
//  GoalPopupScreen.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 9/18/17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import Foundation
import UIKit
import FBSDKCoreKit
import FBSDKShareKit

class GoalPopupScreen: UIView {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var badgeContainerView: UIView!
    @IBOutlet weak var popupPanel: UIImageView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var shareWithFBButton: FBSDKShareButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var counturImage: UIImageView!
    @IBOutlet weak var ovalImage: UIImageView!
    @IBOutlet weak var toothImage: UIImageView!
    @IBOutlet weak var starImage: UIImageView!
    @IBOutlet weak var ribbonImage: UIImageView!
    @IBOutlet weak var numberLabel: UILabel!
    
    @IBOutlet weak var shareWithFBButtonHeightConstraint: NSLayoutConstraint!
    
    
    //MARK: - fileprivates
    
    fileprivate var data: GoalData?
    
    //MARK: - Lifecycle
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        setup()
    }
    
    //MARK: - Detect touches
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            let frame = containerView.frame
            if !frame.contains(location) {
                self.removeFromSuperview()
            }
        }
    }
}

//MARK: - Theme & appearance

extension GoalPopupScreen {
    
    func config(_ data: GoalData) {
        self.data = data
    }
    
    fileprivate func setup() {
        self.titleLabel.text = self.data?.title
        self.descriptionLabel.text = self.data?.description
        if let reward = self.data?.reward {
            self.descriptionLabel.text?.append("\n\n DCN \(reward)")
        }
        let completed = self.data?.completed ?? false
        
        titleLabel.font = UIFont.dntLatoRegularFontWith(size: UIFont.dntLargeTextSize)
        titleLabel.text = data?.title
        
        descriptionLabel.textColor = UIColor.dntCharcoalGrey
        descriptionLabel.font = UIFont.dntLatoLightFont(size: UIFont.dntMainMenuLabelFontSize)
        
        numberLabel.textColor = .white
        numberLabel.font = UIFont.dntLatoBlackFont(size: 90)
        
        //add drop shadow to the view
        
        containerView.layer.masksToBounds = false
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset =  CGSize(width: 1.0, height: 2.0)
        containerView.layer.shadowOpacity = 1
        containerView.layer.shadowRadius = 20
        
        self.backgroundColor = UIColor.dntCharcoalGrey.withAlphaComponent(0.6)
        
        if completed {
            self.achievedStyle()
        } else {
            self.unachievedStyle()
        }
    }
    
    fileprivate func achievedStyle() {
        
        guard let id = self.data?.id else { return }
        let colorStyle: GoalColors = self.getColorStyle(byID: id)
        
        if colorStyle == GoalColors.purple {
            toothImage.image = UIImage(named: "tooth-" + colorStyle.rawValue)
            numberLabel.text = ""
        } else {
            toothImage.image = nil
            numberLabel.text = id.getGoalLabel()
        }
        
        titleLabel.textColor = UIColor.dntCeruleanBlue
        
        starImage.image = UIImage(named: "star-" + colorStyle.rawValue)
        counturImage.image = UIImage(named: "countur-" + colorStyle.rawValue)
        ovalImage.image = UIImage(named: "oval-" + colorStyle.rawValue)
        ribbonImage.image = UIImage(named: "ribbon-" + colorStyle.rawValue)
        
        popupPanel.image = UIImage(named: ImageIDs.goalBackground)
        popupPanel.layer.cornerRadius = 10
        popupPanel.clipsToBounds = true
        
        //create Facebook Share Button
        let linkContent = FBSDKShareLinkContent()
        if let reward = self.data?.reward, let goalTitle = self.titleLabel.text {
            linkContent.quote = "fb_share_goal_message_dp".localized(String(reward), goalTitle)
        } else {
            linkContent.quote = "fb_share_goal_message_dp".localized("0", self.titleLabel.text!)
        }
        linkContent.contentURL = URL(string: "https://itunes.apple.com/us/app/dentacare/id1274148338?ls=1&mt=8")
        
        shareWithFBButton.shareContent = linkContent
        self.layoutIfNeeded()
        
        shareWithFBButtonHeightConstraint.constant = 40
        shareWithFBButton.backgroundColor = .clear
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        
        let shareTitle = NSAttributedString(
            string: "btn_goal_popup_share".localized(),
            attributes: [.paragraphStyle: paragraph]
        )
        shareWithFBButton.setAttributedTitle(shareTitle, for: .normal)
        
        animateGoalLogo()
    }
    
    fileprivate func unachievedStyle() {
        
        guard let id = self.data?.id else { return }
        
        let firstGoal = id.contains(GoalStyles.first.rawValue)
        
        if firstGoal {
            toothImage.image = UIImage(named: "tooth-" + GoalColors.gray.rawValue)
            numberLabel.text = ""
        } else {
            toothImage.image = nil
            numberLabel.text = id.getGoalLabel()
            numberLabel.alpha = 1
        }
        
        titleLabel.textColor = UIColor.black
        
        starImage.image = nil
        counturImage.image = UIImage(named: "countur-" + GoalColors.gray.rawValue)
        ovalImage.image = UIImage(named: "oval-" + GoalColors.gray.rawValue)
        ribbonImage.image = UIImage(named: "ribbon-" + GoalColors.gray.rawValue)
        
        popupPanel.image = UIImage(named: ImageIDs.goalBackground)
        popupPanel.layer.cornerRadius = 10
        popupPanel.clipsToBounds = true
        
        shareWithFBButtonHeightConstraint.constant = 0
        
    }
    
    fileprivate func animateGoalLogo() {
        
        counturImage.alpha = 0
        ovalImage.alpha = 0
        toothImage.alpha = 0
        starImage.alpha = 0
        ribbonImage.alpha = 0
        numberLabel.alpha = 0
        
        guard let id = self.data?.id else { return }
        let colorStyle: GoalColors = self.getColorStyle(byID: id)
        let animateLogo = colorStyle == GoalColors.purple
        
        var ovalEndFrame = ovalImage.frame
        ovalEndFrame.origin.x = (badgeContainerView.frame.width - ovalEndFrame.width) / 2
        
        ovalImage.frame = CGRect(
            x: ovalEndFrame.origin.x + (ovalEndFrame.width / 2),
            y: ovalEndFrame.origin.y + (ovalEndFrame.height / 2),
            width: 0,
            height: 0
        )
        
        var badgeEndFrame: CGRect?
        if animateLogo {
            
            var ovalFrame = ovalImage.frame
            ovalFrame.origin.x = (badgeContainerView.frame.width - ovalFrame.width) / 2
            
            // I HATE THIS HACK: - Hardcoding the start and end frame of toothImage
            // fixes strange problem that makes height of the toothImage equal to zero
            
            badgeEndFrame = CGRect(
                x: ovalFrame.midX - 31.5,
                y: ovalFrame.midY - 34,
                width: 63,
                height: 68
            )
            
            toothImage.frame = CGRect(
                x: ovalFrame.midX - 31.5,
                y: ovalFrame.midY + 17,
                width: 63,
                height: 68
            )
            
        } else {
            var endFrame = numberLabel.frame
            endFrame.origin.x = (badgeContainerView.frame.width - endFrame.width) / 2
            badgeEndFrame = endFrame
            numberLabel.frame.origin.y += endFrame.size.height / 4
        }
    
        var ribbonEndFrame = ribbonImage.frame
        ribbonEndFrame.origin.x = (badgeContainerView.frame.width - ribbonEndFrame.width) / 2
        var ribbonStartFrame = ribbonImage.frame
        ribbonStartFrame.origin.y -= ribbonImage.frame.height
        ribbonImage.frame = ribbonStartFrame
        
        let starEndFrame = starImage.frame
        starImage.frame = CGRect(
            x: starEndFrame.origin.x - (starEndFrame.width / 2),
            y: starEndFrame.origin.y - (starEndFrame.height / 2),
            width: starEndFrame.width * 2,
            height: starEndFrame.height * 2
        )
        
        let animatorStep1 = UIViewPropertyAnimator(duration: 0.5, curve: .easeOut) { [weak self] in
            self?.ovalImage.alpha = 1
            self?.ovalImage.frame = ovalEndFrame
            self?.counturImage.alpha = 1
            if let transform = self?.counturImage.transform.rotated(by: .pi) {
                self?.counturImage.transform = transform
            }
        }
        
        let animatorStep2 = UIViewPropertyAnimator(duration: 0.5, curve: .easeIn) { [weak self] in
            if animateLogo {
                self?.toothImage.alpha = 1
                self?.toothImage.frame = badgeEndFrame!
            } else {
                self?.numberLabel.alpha = 1
                self?.numberLabel.frame = badgeEndFrame!
            }
            self?.ribbonImage.alpha = 1
            self?.ribbonImage.frame = ribbonEndFrame
            self?.starImage.alpha = 1
            self?.starImage.frame = starEndFrame
            
            // I HATE THIS HACK: - only this way we can rotate a view .pi * 2
            let fullRotation = CABasicAnimation(keyPath: "transform.rotation")
            fullRotation.fromValue = NSNumber(floatLiteral: 0)
            fullRotation.toValue = NSNumber(floatLiteral: Double(CGFloat.pi * 2))
            fullRotation.duration = 0.5
            fullRotation.repeatCount = 1
            self?.starImage.layer.add(fullRotation, forKey: "360")
            
            // DON'T WORK FOR .PI * 2
//            if let transform = self?.starImage.transform.rotated(by: .pi * 2) {
//                self?.starImage.transform = transform
//            }
        }
        
        animatorStep1.startAnimation()
        animatorStep2.startAnimation(afterDelay: 0.25)
        
    }
    
    fileprivate func getColorStyle(byID id: String) -> GoalColors {
        if id.contains(GoalStyles.first.rawValue) { return GoalColors.purple }
        if id.contains(GoalStyles.week.rawValue) { return GoalColors.green }
        if id.contains(GoalStyles.month.rawValue) { return GoalColors.blue }
        if id.contains(GoalStyles.year.rawValue) { return GoalColors.yellow }
        return GoalColors.gray
    }
    
    //MARK: - IBActions
    
    @IBAction func onCloseButtonPressed(_ sender: UIButton) {
        self.removeFromSuperview()
    }
    
}

//MARK: - Goal Types

enum GoalStyles: String {
    case first = "first"
    case week = "week"
    case month = "month"
    case year = "year"
    case unachieved = "unachieved"
}

enum GoalColors: String {
    case purple = "purple"
    case green = "green"
    case blue = "blue"
    case yellow = "yellow"
    case gray = "gray"
}

//MARK: - String Helpers

fileprivate extension String {
    
    func contains(_ value: String) -> Bool {
        if self.range(of: value) != nil {
            return true
        }
        return false
    }
    
    func getGoalLabel() -> String {
        let components = self.components(separatedBy: "_")
        return components.last ?? "0"
    }
    
}


