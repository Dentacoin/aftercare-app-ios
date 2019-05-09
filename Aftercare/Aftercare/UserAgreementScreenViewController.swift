//
//  UserAgreementScreenViewController.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 9/4/17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import UIKit

class UserAgreementScreenViewController: UIViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var textField: UITextView!
    @IBOutlet weak var agreeButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    //MARK: - lazy init strings
    
    fileprivate lazy var userAgreementTitleString: String = {
        return "user_agreement_title".localized()
    }()
    
    fileprivate lazy var agreeButtonTitleString: String = {
        return "btn_accept".localized()
    }()
    
    fileprivate lazy var cancelButtonTitleString: String = {
        return "btn_decline".localized()
    }()
    
    // MARK: - public
    
    var delegate: UserAgreementScreenDelegate?
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
}

//MARK: - Theme and components setup

extension UserAgreementScreenViewController {
    
    fileprivate func setup() {
        
        let themeManager = ThemeManager.shared
        
        self.agreeButton.setTitle(agreeButtonTitleString, for: .normal)
        self.agreeButton.setTitle(agreeButtonTitleString, for: .highlighted)
        themeManager.setDCBlueTheme(to: self.agreeButton, ofType: .ButtonDefaultWhite)
        
        self.cancelButton.setTitle(cancelButtonTitleString, for: .normal)
        self.cancelButton.setTitle(cancelButtonTitleString, for: .highlighted)
        themeManager.setDCBlueTheme(to: self.cancelButton, ofType: .ButtonDefaultWhite)
        
        loadText()
    }
    
    fileprivate func loadText() {
        
        // load from localization files
        let htmlData = NSString(string: "user_agreement".localized()).data(using: String.Encoding.unicode.rawValue)
        let options = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html]
        let attributedString = try! NSAttributedString(data: htmlData!, options: options, documentAttributes: nil)
        textField.attributedText = attributedString
        
        // I HATE THIS HACK: - this fixes a bug where the text field that we use to load our terms & conditions
        // starts scrolled from few rows below the top
        textField.scrollRangeToVisible(NSMakeRange(0, 1))
    }
    
}

//MARK: - IBActions

extension UserAgreementScreenViewController {
    
    @IBAction func agreeButtonPressed(_ sender: UIButton) {
        delegate?.userDidAgree()
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        delegate?.userDidDecline()
    }
    
}

// MARK: - UserAgreementScreenDelegate

protocol UserAgreementScreenDelegate {
    func userDidAgree()
    func userDidDecline()
}
