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
    
    // After how many seconds this screen should close itself
    fileprivate let shouldStayForSeconds: Int = 4
    
    //MARK: - Delegate
    
    var contentDelegate: ContentDelegate?
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        showNextScreenAfterTime()
    }
    
    //MARK: - internal logic
    
    func showNextScreenAfterTime() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(shouldStayForSeconds), execute: { [weak self] in
            self?.presentContentViewController()
        })
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
        titleLabel.text = "feedback_hdl_thank_you".localized()
        
        messageLabel.textColor = .white
        messageLabel.font = UIFont.dntLatoLightFont(size: UIFont.dntButtonFontSize)
        messageLabel.text = "feedback_txt_message_sent".localized()
        
    }
    
}

//MARK: - InitialPageHeaderViewDelegate

extension ThankYouScreenViewController: InsidePageHeaderViewDelegate {
    
    func backButtonIsPressed() {
        contentDelegate?.backButtonIsPressed()
    }
    
}
