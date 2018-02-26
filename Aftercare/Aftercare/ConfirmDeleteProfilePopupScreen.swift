//
// Aftercare
// Created by Dimitar Grudev on 25.02.18.
// Copyright © 2018 Stichting Administratiekantoor Dentacoin.
//

import Foundation
import UIKit

class ConfirmDeleteProfilePopupScreen: UIView {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var captchaView: CaptchaView!
    @IBOutlet weak var captchaTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    
    // MARK: - Delegate
    
    var delegate: ConfirmDeleteProfileDelegate?
    
    // MARK: - Fileprivate
    
    fileprivate lazy var errorWrongCaptchaCodeString: String = {
        return NSLocalizedString("Wrong Code", comment: "")
    }()
    
    // MARK: - Lifecycle
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        setup()
    }
    
    //MARK: - resign first responder
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.endEditing(true)
    }
    
    // MARK: - internal
    
    fileprivate func setup() {
        
        addListenersForKeyboard()
        
        containerView.layer.masksToBounds = false
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset =  CGSize(width: 1.0, height: 2.0)
        containerView.layer.shadowOpacity = 1
        containerView.layer.shadowRadius = 20
        
        self.backgroundColor = UIColor.dntCeruleanBlue.withAlphaComponent(0.6)
        
        titleLabel.text = NSLocalizedString("Delete your profile?", comment: "")
        descriptionLabel.text = NSLocalizedString("Are you sure you want to delete your profile? Enter the code to delete your profile. This will erase all your data.", comment: "")
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .left
        let captchaPlaceholder = NSAttributedString.init(
            string: NSLocalizedString("Enter Code", comment: ""),
            attributes: [
                NSAttributedStringKey.foregroundColor: UIColor.dntCeruleanBlue,
                NSAttributedStringKey.font: UIFont.dntLatoLightFont(
                    size: UIFont.dntLabelFontSize
                    )!,
                NSAttributedStringKey.paragraphStyle: paragraph
            ]
        )
        captchaTextField.attributedPlaceholder = captchaPlaceholder
        captchaView.requestNewCaptcha()
        
    }
    
    deinit {
        self.removeListenersForKeyboard()
        self.captchaView.disposeCaptcha()
    }
    
    // MARK: - Overlapping keyboard fix
    
    func addListenersForKeyboard() {
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillShow),
            name: NSNotification.Name.UIKeyboardWillShow,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillHide),
            name: NSNotification.Name.UIKeyboardWillHide,
            object: nil
        )
        
    }
    
    func removeListenersForKeyboard() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            guard let textField = self.captchaTextField else {
                return
            }
            
            let position: CGPoint = textField.convert(CGPoint(x: 0, y: 0), to: self)
            let textFrame: CGRect = textField.bounds
            
            let gapBetweenTextAndKeyboard: CGFloat = 16
            let screenSize = UIScreen.main.bounds
            let keyboardPossition = CGPoint(x: 0, y: screenSize.size.height - keyboardSize.height)
            let textBottom = position.y + textFrame.size.height + gapBetweenTextAndKeyboard
            if textBottom > keyboardPossition.y {
                self.frame.origin.y = -(textBottom - keyboardPossition.y)
            }
            
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.frame.origin.y = 0
    }
    
    // MARK: - IBActions
    
    @IBAction func onPopupClosed(_ sender: UIButton) {
        delegate?.deleteProfileCancaled()
        self.removeFromSuperview()
    }
    
    @IBAction func onPopupConfirmed(_ sender: UIButton) {
        
        guard let captchaCode = captchaTextField.text, captchaCode != "" else {
            captchaTextField.errorMessage = errorWrongCaptchaCodeString
            UIAlertController.show(
                controllerWithTitle: NSLocalizedString("Error", comment: ""),
                message: errorWrongCaptchaCodeString,
                buttonTitle: NSLocalizedString("Ok", comment: "")
            )
            return
        }
        
        guard let captchaID = captchaView.data?.id else {
            return print("Error: ConfirmDeleteProfilePopupScreen : Missing captcha ID")
        }
        
        captchaTextField.errorMessage = ""
        
        let params = DeleteUserRequest(captchaCode: captchaCode, captchaId: captchaID)
        
        APIProvider.requestDeleteUser(params) { [weak self] deleted, error in
            if let error = error {
                UIAlertController.show(
                    controllerWithTitle: NSLocalizedString("Error", comment: ""),
                    message: error.toNSError().localizedDescription,
                    buttonTitle: NSLocalizedString("Ok", comment: "")
                )
                //invalidate current captcha and request new one
                self?.captchaTextField.text = ""
                self?.captchaView.invalidate()
                self?.delegate?.deleteProfileCancaled()
                return
            } else {
                self?.delegate?.deleteProfileConfirmed()
            }
        }
        
        self.removeFromSuperview()
        
    }
}

// MARK: - Delegate Protocol

protocol ConfirmDeleteProfileDelegate {
    func deleteProfileConfirmed()
    func deleteProfileCancaled()
}
