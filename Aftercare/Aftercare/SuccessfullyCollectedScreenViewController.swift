//
//  SucessfulyCollectedScreenViewController.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 9/29/17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import Foundation
import UIKit

class SuccessfullyCollectedScreenViewController: UIViewController, ContentConformer {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var collectedLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    //MARK: - Delegates
    
    var contentDelegate: ContentDelegate?
    
    //MARK: - Public
    
    var headerView: UIView?
    
    //MARK: - Fileprivates
    
    fileprivate var data: [String : Any]?
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
}

//MARK: - Internal Logic

extension SuccessfullyCollectedScreenViewController {
    
    //MARK: - Theme and appearance
    
    fileprivate func setup() {
        
        collectedLabel.textColor = .white
        collectedLabel.font = UIFont.dntLatoRegularFontWith(size: UIFont.dntTitleFontSize)
        updateCollectedDCNValue()
        
        infoLabel.textColor = .white
        infoLabel.font = UIFont.dntLatoLightFont(size: UIFont.dntButtonFontSize)
        infoLabel.text = NSLocalizedString("Successfully Collected to the Crypto Wallet", comment: "")
        
        if self.data != nil {
            updateCollectedDCNValue()
            showNextScreenAfterTime()
        }
    }
    
    internal func config(_ data: [String : Any]) {
        self.data = data
        
        //Update label
        if self.collectedLabel != nil {
            updateCollectedDCNValue()
            showNextScreenAfterTime()
        }
    }
    
    fileprivate func updateCollectedDCNValue() {
        if let data = self.data {
            if let collectValue = data["collectDCN"] as? Int {
                collectedLabel.text = String(collectValue) + " DCN"
            }
        } else {
            collectedLabel.text = "0 DCN"
        }
    }
    
    //MARK: - internal API
    
    func showNextScreenAfterTime() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 4, execute: { [weak self] in
            self?.presentContentViewController()
        })
    }
    
    func presentContentViewController() {
        let vcID = String(describing: CollectScreenViewController.self)
        contentDelegate?.requestLoadViewController(vcID, nil)
    }
    
}
