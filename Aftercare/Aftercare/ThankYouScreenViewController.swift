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
