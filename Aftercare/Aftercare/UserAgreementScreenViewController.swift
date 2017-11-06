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
    
    @IBOutlet weak var header: InsidePageHeaderView!
    @IBOutlet weak var textField: UITextView!
    @IBOutlet weak var agreeButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    //MARK: - Delegates
    
    var contentDelegate: ContentDelegate?
    
    //MARK: - lazy init strings
    
    fileprivate lazy var userAgreementTitleString: String = {
        return NSLocalizedString("User Agreements", comment: "")
    }()
    
    fileprivate lazy var agreeButtonTitleString: String = {
        return NSLocalizedString("Agree", comment: "")
    }()
    
    fileprivate lazy var cancelButtonTitleString: String = {
        return NSLocalizedString("Cancel", comment: "")
    }()
    
    //MARK: - fileprivate vars
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
}

//MARK: - Theme and components setup

extension UserAgreementScreenViewController {
    
    func setup() {
        
        self.header.updateTitle(userAgreementTitleString)
        
        guard let fileURL = Bundle.main.url(forResource: "user-agreement", withExtension: "html") else { return }
        let stringData = try? String.init(contentsOf: fileURL, encoding: .utf8)
        self.textField.font = UIFont.dntLatoLightFont(size: UIFont.dntNormalTextSize)

        let htmlData = NSString(string: stringData ?? "").data(using: String.Encoding.unicode.rawValue)
        let options = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html]
        let attributedString = try! NSAttributedString(data: htmlData!, options: options, documentAttributes: nil)
        self.textField.attributedText = attributedString
        
        let themeManager = ThemeManager.shared
        
        self.agreeButton.setTitle(agreeButtonTitleString, for: .normal)
        self.agreeButton.setTitle(agreeButtonTitleString, for: .highlighted)
        themeManager.setDCBlueTheme(to: self.agreeButton, ofType: .ButtonDefaultWhite)
        
        self.cancelButton.setTitle(cancelButtonTitleString, for: .normal)
        self.cancelButton.setTitle(cancelButtonTitleString, for: .highlighted)
        themeManager.setDCBlueTheme(to: self.cancelButton, ofType: .ButtonDefaultWhite)
    }
    
    func userDisagree() {
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
    }
}

//MARK: - IBActions

extension UserAgreementScreenViewController {
    
    @IBAction func agreeButtonPressed(_ sender: UIButton) {
        if let navController = self.navigationController {
            let controller: WelcomeScreenViewController! = UIStoryboard.login.instantiateViewController()
            navController.pushViewController(controller, animated: true)
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        userDisagree()
    }
    
}

//MARK: - InsidePageHeaderViewDelegate

extension UserAgreementScreenViewController: InsidePageHeaderViewDelegate {
    
    func backButtonIsPressed() {
        contentDelegate?.backButtonIsPressed()
    }
    
}
