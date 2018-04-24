//
//  DescribeCaseScreenViewController.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 9/28/17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import Foundation
import UIKit
import MessageUI

class DescribeCaseScreenViewController: UIViewController, ContentConformer {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var headerView: UIView?
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var describeYourCaseTextView: UITextView!
    @IBOutlet weak var preferenceLabel: UILabel!
    @IBOutlet weak var contactTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomContentPadding: NSLayoutConstraint!
    
    //MARK: - Fileprivates
    
    fileprivate var firstResponderTextField: UITextField?
    
    //MARK: - Delegates
    
    var contentDelegate: ContentDelegate?
    
    //MARK: - Public
    
    var header: InsidePageHeaderView! {
        return headerView as! InsidePageHeaderView
    }
    
    //MARK: - fileprivates
    
    fileprivate lazy var phonePlaceholder: String = {
        return "emergency_hnt_phone".localized()
    }()
    
    fileprivate lazy var describeYourCasePlaceholder: String = {
        return "emergency_hnt_write_message".localized()
    }()
    
    fileprivate lazy var errorPhoneContactString: String = {
        return "error_txt_wrong_phone_number".localized()
    }()
    
    fileprivate var calculatedConstraints = false
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addListenersForKeyboard()
        contactTextField.delegate = self
        setup()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if #available(iOS 11.0, *) {
            if !calculatedConstraints {
                calculatedConstraints = true
                let topPadding = self.view.safeAreaInsets.top
                headerHeightConstraint.constant += topPadding
                let bottomPadding = self.view.safeAreaInsets.bottom
                bottomContentPadding.constant -= bottomPadding
            }
        }
    }
    
    deinit {
        self.removeListenersForKeyboard()
    }
    
    //MARK: - Internal logic
    
    fileprivate func validateCaseData() -> String? {
        
        if let data = describeYourCaseTextView.text {
            if data.isEmpty || data == describeYourCasePlaceholder {
                return "emergency_hdl_describe".localized()
            }
        }
        
        return nil
    }
    
    //MARK: - resign first responder
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}

//MARK: - Theme and appearance

extension DescribeCaseScreenViewController {
    
    fileprivate func setup() {
        
        header.delegate = self
        header.updateTitle("emergency_hdl_emergency".localized())
        
        titleLabel.textColor = UIColor.dntCeruleanBlue
        titleLabel.font = UIFont.dntLatoLightFont(size: UIFont.dntTitleFontSize)
        
        describeYourCaseTextView.textColor = UIColor.darkGray
        describeYourCaseTextView.font = UIFont.dntLatoRegularFontWith(size: UIFont.dntMainMenuLabelFontSize)
        describeYourCaseTextView.text = describeYourCasePlaceholder
        describeYourCaseTextView.delegate = self
        describeYourCaseTextView.keyboardType = .default
        
        preferenceLabel.textColor = .white
        preferenceLabel.font = UIFont.dntLatoLightFont(size: UIFont.dntButtonFontSize)
        
        let themeManager = ThemeManager.shared
        themeManager.setDCBlueTheme(to: self.sendButton, ofType: .ButtonDefault)
        sendButton.titleLabel?.text = "txt_send".localized()
        
        themeManager.setDCBlueTheme(to: self.contactTextField, ofType: .TextFieldDefaut)
        contactTextField.keyboardType = .phonePad
    }
    
}

//MARK: - UITextViewDelegate

extension DescribeCaseScreenViewController: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        self.textViewFirstResponder = textView
        if textView.text == describeYourCasePlaceholder {
            textView.text = ""
        }
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if textView.text == "" || textView.text.isEmpty {
            textView.text = describeYourCasePlaceholder
        }
        return true
    }
    
}

//MARK: - UITextFieldDelegate

extension DescribeCaseScreenViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.textFieldFirstResponder = textField
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == contactTextField {
            if validateContactData() {
                contactTextField.resignFirstResponder()
            }
            return true
        }
        
        //imitate send button pressed on keyboard return
        sendButtonPressed(self.sendButton)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField == contactTextField {
            if validateContactData() {
                contactTextField.resignFirstResponder()
            }
        }
        return true
    }
    
    fileprivate func validateContactData() -> Bool {
        if let phone = contactTextField.text, SystemMethods.User.validatePhone(phone) == true {
            contactTextField.errorMessage = ""
            return true
        } else {
            contactTextField.errorMessage = errorPhoneContactString
            return false
        }
    }
    
}

//MARK: - IBActions

extension DescribeCaseScreenViewController {
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        
        if let error = self.validateCaseData() {
            
            UIAlertController.show(
                controllerWithTitle: "error_popup_title".localized(),
                message: error,
                buttonTitle: "txt_ok".localized()
            )
            
        } else {
            
            if let mailVC = configueMailComposerViewController() {
                self.present(mailVC, animated: true, completion: nil)
            }
            
        }
        
    }
    
}

//MARK: - MFMailComposeViewControllerDelegate

extension DescribeCaseScreenViewController: MFMailComposeViewControllerDelegate {
    
    fileprivate func configueMailComposerViewController() -> MFMailComposeViewController? {
        
        if !MFMailComposeViewController.canSendMail() {
            
            UIAlertController.show(
                controllerWithTitle: "error_popup_title".localized(),
                message: "error_txt_cant_send_emails".localized(),
                buttonTitle: "txt_ok".localized()
            )
            
            return nil
            
        } else {
            var messageBody = describeYourCaseTextView.text!
            if !(contactTextField.text?.isEmpty)! {
                messageBody += "\n"
                messageBody += "emergency_lbl_phone".localized() + contactTextField.text!
            }
            
            let mailComposerViewController = MFMailComposeViewController()
            mailComposerViewController.mailComposeDelegate = self
            mailComposerViewController.setToRecipients(["emergency@dentacoin.com"])
            mailComposerViewController.setSubject("emergency_email_subject".localized())
            mailComposerViewController.setMessageBody(messageBody, isHTML: false)
            mailComposerViewController.addAttachmentData(
                UIImageJPEGRepresentation(UserDataContainer.shared.emergencyScreenImage!,
                CGFloat(1.0))!,
                mimeType: "image/jpeg",
                fileName:  "dentalCaseImage.jpeg"
            )
            
            return mailComposerViewController
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        controller.dismiss(animated: true, completion: nil)
        
        switch result {
        case .cancelled:
            //...
            break
        case .failed:
            //...
            break
        case .saved:
            //...
            break
        case .sent:
            let vcID = String(describing: ThankYouScreenViewController.self)
            contentDelegate?.requestLoadViewController(vcID, nil)
        }
        
    }
    
}

//MARK: - InitialPageHeaderViewDelegate

extension DescribeCaseScreenViewController: InsidePageHeaderViewDelegate {
    
    func backButtonIsPressed() {
        contentDelegate?.backButtonIsPressed()
    }
    
}
