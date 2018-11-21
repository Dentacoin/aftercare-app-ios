//
//  LoginScreenViewController.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 8/7/17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import UIKit

typealias AgreementCompletion = (_ consent: Bool) -> Void

class LoginWithEmailScreenViewController : UIViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var emailTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var passwordTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    
    // MARK: - Private vars
    
    fileprivate var uiIsBlocked = false
    
    //MARK: - Clean Swift
    
    var output: LoginWithEmailScreenControllerOutputProtocol!
    var router: LoginWithEmailScreenRouterProtocol!
    
    //MARK: - initialize
    
    init(configurator: LoginWithEmailScreenConfigurator = LoginWithEmailScreenConfigurator.shared) {
        super.init(nibName: nil, bundle: nil)
        configure()
    }
    
    // override default initializers
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.configure()
    }
    
    //MARK: - Configurator
    
    private func configure(configurator: LoginWithEmailScreenConfigurator = LoginWithEmailScreenConfigurator.shared) {
        configurator.configure(viewController: self)
    }
    
    //MARK: - Lifecicle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        setup()
        addListenersForKeyboard()
    }
    
    deinit {
        self.removeListenersForKeyboard()
    }
    
    //MARK: - resign first responder
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}

//MARK: - Theme and components setup

extension LoginWithEmailScreenViewController {
    
    fileprivate func setup() {
        
        let themeManager = ThemeManager.shared
        
        //setup forgotPasswordButton theme
        
        themeManager.setDCBlueTheme(
            to: forgotPasswordButton,
            ofType: .ButtonLink(fontSize: UIFont.dntSmallLabelFontSize)
        )
        
        //setup Text Field theme
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .left
        
        themeManager.setDCBlueTheme(to: emailTextField, ofType: .TextFieldDefaut)
        let emailPlaceholder = NSAttributedString.init(
            string: "signup_hnt_email".localized(),
            attributes: [
                NSAttributedStringKey.foregroundColor: UIColor.white,
                NSAttributedStringKey.font: UIFont.dntLatoLightFont(size: UIFont.dntLabelFontSize)!,
                NSAttributedStringKey.paragraphStyle: paragraph
            ])
        emailTextField.attributedPlaceholder = emailPlaceholder
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocorrectionType = .no
        
        themeManager.setDCBlueTheme(to: passwordTextField, ofType: .TextFieldDefaut)
        passwordTextField.isSecureTextEntry = true
        let passwordPlaceholder = NSAttributedString.init(
            string: "signup_hnt_password".localized(),
            attributes: [
                NSAttributedStringKey.foregroundColor: UIColor.white,
                NSAttributedStringKey.font: UIFont.dntLatoLightFont(size: UIFont.dntLabelFontSize)!,
                NSAttributedStringKey.paragraphStyle: paragraph
            ])
        passwordTextField.attributedPlaceholder = passwordPlaceholder
        passwordTextField.autocorrectionType = .no
        
        //setup logonButton theme
        
        themeManager.setDCBlueTheme(to: loginButton, ofType: .ButtonDefault)
        loginButton.titleLabel?.text = "btn_auth_login".localized()
    }
    
    @discardableResult fileprivate func validateUserData() -> Bool {
        
        textFieldShouldEndEditing(emailTextField)
        textFieldShouldEndEditing(passwordTextField)
        
        if let error = emailTextField.errorMessage, !error.isEmpty {
            emailTextField.becomeFirstResponder()
            uiIsBlocked = false
            return false
        }

        if let error = passwordTextField.errorMessage, !error.isEmpty {
            passwordTextField.becomeFirstResponder()
            uiIsBlocked = false
            return false
        }
        return true
    }
    
    fileprivate func loginWithEmailCredentials() {
        if validateUserData() {
            showLoadingScreenState()
            if let email = emailTextField.text, let pass = passwordTextField.text {
                output.requestLoginWith(email: email, password: pass)
            }
        }
    }
    
}

//MARK: - UITextFieldDelegate

extension LoginWithEmailScreenViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.textFieldFirstResponder = textField
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            emailTextField.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            passwordTextField.resignFirstResponder()
            loginWithEmailCredentials()
        }
        return true
    }
    
    @discardableResult func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            if let email = emailTextField.text, SystemMethods.User.validateEmail(email) == true {
                emailTextField.errorMessage = ""
            } else {
                emailTextField.errorMessage = "error_txt_email_not_valid".localized()
            }
        } else if textField == passwordTextField {
            if let pass = passwordTextField.text, SystemMethods.User.validatePassword(pass) == true {
                passwordTextField.errorMessage = ""
            } else {
                passwordTextField.errorMessage = "error_txt_password_short".localized()
            }
        }
        return true
    }
    
}

//MARK: - IBActions

extension LoginWithEmailScreenViewController {
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        if uiIsBlocked == true { return }
        uiIsBlocked = true
        loginWithEmailCredentials()
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        if uiIsBlocked == true { return }
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
    }
    
    @IBAction func forgotPasswordButtonPressed(_ sender: UIButton) {
        if uiIsBlocked == true { return }
        router.showForgotPasswordScreen()
    }
    
}

extension LoginWithEmailScreenViewController: LoginWithEmailScreenControllerInputProtocol {
    
    fileprivate func showLoadingScreenState() {
        let loadingState = State(.loadingState, "txt_loading".localized())
        showState(loadingState)
    }
    
    fileprivate func clearState() {
        uiIsBlocked = false
        let noneState = State(.none)
        showState(noneState)
    }
    
    func showWelcomeScreen() {
        clearState()
        router.navigateToWelcomeScreen()
    }

    func showErrorMessage(_ message: String) {
        clearState()
        UIAlertController.show(
            controllerWithTitle: "error_popup_title".localized(),
            message: message,
            buttonTitle: "txt_ok".localized()
        )
    }
    
    func userNotConsentToTermsAndConditions() {
        router.showUserAgreementScreen() { [weak self] consent in
            if consent {
                // update user consent on terms and conditions
                self?.showWelcomeScreen()
            } else {
                UserDataContainer.shared.logout()
            }
            self?.clearState()
        }
    }
    
    func userDidCancelToAuthenticate() {
        clearState()
    }

}

//MARK: - Login Screen Protocols

protocol LoginWithEmailScreenControllerInputProtocol: ViewControllerInputProtocol, LoginWithEmailScreenPresenterOutputProtocol {}
protocol LoginWithEmailScreenControllerOutputProtocol: ViewControllerOutputProtocol {
    func requestLoginWith(email: String, password: String)
    func requestLoginWith(provider: SocialLoginProviderProtocol, in controller: UIViewController)
    func updateUserConsentOnTermsAndConditions()
}

