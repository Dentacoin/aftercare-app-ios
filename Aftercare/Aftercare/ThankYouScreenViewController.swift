//
//  ThankYouScreen.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 9/28/17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import Foundation
import UIKit

class ThankYouScreenViewController: UIViewController, ContentConformer {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    var headerView: UIView?
    
    //MARK: - Fileprivates
    
    fileprivate let shouldStayForSeconds = 4
    fileprivate var timer: Timer?
    fileprivate var count = 0
    
    //MARK: - Delegate
    
    var contentDelegate: ContentDelegate?
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        startCountdownBeforeDismiss()
    }
    
    //MARK: - internal logic
    
    fileprivate func startCountdownBeforeDismiss() {
        
        timer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: Selector.updateTimerSelector,
            userInfo: nil,
            repeats: true
        )
        
    }
        
    @objc fileprivate func updateTimer() {
        count += 1
        if count >= shouldStayForSeconds {
            timer?.invalidate()
            presentContentViewController()
        }
    }
    
    fileprivate func presentContentViewController() {
        
        let vcID = String(describing: EmergencyScreenViewController.self)
        contentDelegate?.requestLoadViewController(vcID, nil)
        
    }
}

//MARK: - Theme and appearance

extension ThankYouScreenViewController {
    
    fileprivate func setup() {
        
        titleLabel.textColor = .white
        titleLabel.font = UIFont.dntLatoRegularFontWith(size: UIFont.dntLargeTextSize)
        
        messageLabel.textColor = .white
        titleLabel.font = UIFont.dntLatoLightFont(size: UIFont.dntButtonFontSize)
        
    }
    
}

//MARK: - InitialPageHeaderViewDelegate

extension ThankYouScreenViewController: InsidePageHeaderViewDelegate {
    
    func backButtonIsPressed() {
        contentDelegate?.backButtonIsPressed()
    }
    
}

//MARK: - Selector helper

fileprivate extension Selector {
    static let updateTimerSelector = #selector(ThankYouScreenViewController.updateTimer)
}
