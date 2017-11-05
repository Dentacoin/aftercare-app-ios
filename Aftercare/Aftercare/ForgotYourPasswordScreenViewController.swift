//
//  ForgotYourPasswordScreenViewController.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 14.10.17.
//  Copyright © 2017 Dimitar Grudev. All rights reserved.
//

import Foundation
import UIKit

class ForgotYourPasswordScreenViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var postRequestMessageLabel: UILabel!
    @IBOutlet weak var emailTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var descriptionYConstraint: NSLayoutConstraint!
    @IBOutlet weak var postRequestMessageYConstraint: NSLayoutConstraint!
    
    //MARK: - fileprivates
    
    fileprivate var uiIsBlocked = false
    fileprivate var requestSent = false
    
    fileprivate lazy var emailErrorString:String = {
        return NSLocalizedString("Wrong email.", comment: "Wrong email")
    }()
    
    fileprivate lazy var sendButtonOKState:String = {
        return NSLocalizedString("OK", comment: "")
    }()
    
    //MARK: - lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setup()
    }
    
    //MARK: - resign first responder
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //MARK: - Internal logic
    
    fileprivate func animateToSuccessRequestState() {
        
        sendButton.setTitle(sendButtonOKState, for: .normal)
        sendButton.setTitle(sendButtonOKState, for: .highlighted)
        
        self.view.layoutIfNeeded()
        self.descriptionYConstraint.constant += 30
        
        UIView.animate(withDuration: 1) { [weak self] in
            self?.descriptionLabel.alpha = 0
            self?.titleLabel.alpha = 0
            self?.emailTextField.alpha = 0
            self?.view.layoutIfNeeded()
            self?.uiIsBlocked = false
            self?.requestSent = true
        }
        
        UIView.animate(
            withDuration: 1,
            delay: 0.5,
            options: UIViewAnimationOptions.curveEaseIn,
            animations: { [weak self] in
            
            self?.postRequestMessageYConstraint.constant = 0
            self?.postRequestMessageLabel.alpha = 1
            
        }, completion: nil)
        
    }
    
    fileprivate func validateEmail() {
        if let email = emailTextField.text, SystemMethods.User.validateEmail(email) == true {
            emailTextField.errorMessage = nil
        } else {
            emailTextField.errorMessage = emailErrorString
        }
    }
}

//MARK: - Theme and Appearance

extension ForgotYourPasswordScreenViewController {
    
    fileprivate func setup() {
        
        self.titleLabel.font = UIFont.dntLatoRegularFontWith(size: UIFont.dntHeaderTitleFontSize)
        self.titleLabel.textColor = .white
        self.titleLabel.text = NSLocalizedString("Forget your password?", comment: "")
        
        self.descriptionLabel.font = UIFont.dntLatoRegularFontWith(size: UIFont.dntLabelFontSize)
        self.descriptionLabel.textColor = .white
        self.descriptionLabel.text = NSLocalizedString("We will send you an email with instructions on how to reset your password.", comment: "")
        
        self.postRequestMessageLabel.font = UIFont.dntLatoRegularFontWith(size: UIFont.dntLabelFontSize)
        self.postRequestMessageLabel.textColor = .white
        self.postRequestMessageLabel.text = NSLocalizedString("Successfully sent reset request, you will receive an email shortly.", comment: "")
        self.postRequestMessageLabel.alpha = 0
        
        let themeManager = ThemeManager.shared
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .left
        
        themeManager.setDCBlueTheme(to: self.emailTextField, ofType: .TextFieldDefaut)
        let emailPlaceholder = NSAttributedString.init(
            string: NSLocalizedString("email", comment: ""),
            attributes: [
                NSAttributedStringKey.foregroundColor: UIColor.white,
                NSAttributedStringKey.font: UIFont.dntLatoLightFont(size: UIFont.dntLabelFontSize)!,
                NSAttributedStringKey.paragraphStyle: paragraph
            ])
        self.emailTextField.attributedPlaceholder = emailPlaceholder
        
        let sendButtonTitle = NSLocalizedString("Send", comment: "")
        sendButton.setTitle(sendButtonTitle, for: .normal)
        sendButton.setTitle(sendButtonTitle, for: .highlighted)
        themeManager.setDCBlueTheme(to: sendButton, ofType: .ButtonDefault)
    }
    
}

//MARK: - UITextFieldDelegate

extension ForgotYourPasswordScreenViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == emailTextField {
            emailTextField.resignFirstResponder()
        }
        
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        
        if textField == emailTextField {
            validateEmail()
        }
        
        return true
    }
    
}

//MARK: - IBActions

extension ForgotYourPasswordScreenViewController {
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        if self.uiIsBlocked == true { return }
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
    }
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        if self.uiIsBlocked == true { return }
        
        if requestSent == false {
            
            validateEmail()
            
            if let email = emailTextField.text,
                emailTextField.errorMessage == nil {
                
                self.uiIsBlocked = true
                APIProvider.requestResetPassword(email: email)
                
                //TODO: create animation, show message that email will be send shortly and close the screen after few seconds
                animateToSuccessRequestState()
            }
            
        } else {
            self.backButtonPressed(sendButton)
        }
    }
    
}
