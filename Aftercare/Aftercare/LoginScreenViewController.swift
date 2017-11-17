//
//  LoginScreenViewController.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 8/7/17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import UIKit

class LoginScreenViewController : UIViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var emailTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var passwordTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var orConnectWithLabel: UILabel!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var twitterButton: UIButton!
    @IBOutlet weak var googlePlusButton: UIButton!
    
    //MARK: - Private vars
    
    fileprivate lazy var emailErrorString:String = {
        return NSLocalizedString("Wrong email.", comment: "Wrong email")
    }()
    
    fileprivate lazy var passwordErrorString: String = {
        return NSLocalizedString("Password is too short.", comment: "Password is too short")
    }()
    
    fileprivate var uiIsBlocked = false
    
    //MARK: - Clean Swift
    
    var output: LoginScreenControllerOutputProtocol!
    var router: LoginScreenRouterProtocol!
    
    //MARK: - initialize
    
    init(configurator: LoginScreenConfigurator = LoginScreenConfigurator.shared) {
        super.init(nibName: nil, bundle: nil)
        configure()
    }
    
    // override default initializers
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.configure()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.configure()
    }
    
    //MARK: - Configurator
    
    private func configure(configurator: LoginScreenConfigurator = LoginScreenConfigurator.shared) {
        configurator.configure(viewController: self)
    }
    
    //MARK: - Lifecicle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        setup()
        
        self.addListenersForKeyboard()
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

extension LoginScreenViewController {
    
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
        
        themeManager.setDCBlueTheme(to: self.emailTextField, ofType: .TextFieldDefaut)
        let emailPlaceholder = NSAttributedString.init(
            string: NSLocalizedString("email", comment: ""),
            attributes: [
                NSAttributedStringKey.foregroundColor: UIColor.white,
                NSAttributedStringKey.font: UIFont.dntLatoLightFont(size: UIFont.dntLabelFontSize)!,
                NSAttributedStringKey.paragraphStyle: paragraph
            ])
        self.emailTextField.attributedPlaceholder = emailPlaceholder
        self.emailTextField.keyboardType = .emailAddress
        self.emailTextField.autocorrectionType = .no
        
        themeManager.setDCBlueTheme(to: self.passwordTextField, ofType: .TextFieldDefaut)
        self.passwordTextField.isSecureTextEntry = true
        let passwordPlaceholder = NSAttributedString.init(
            string: NSLocalizedString("password", comment: ""),
            attributes: [
                NSAttributedStringKey.foregroundColor: UIColor.white,
                NSAttributedStringKey.font: UIFont.dntLatoLightFont(size: UIFont.dntLabelFontSize)!,
                NSAttributedStringKey.paragraphStyle: paragraph
            ])
        self.passwordTextField.attributedPlaceholder = passwordPlaceholder
        self.passwordTextField.autocorrectionType = .no
        
        //setup "Or Connect With" Label theme
        
        self.orConnectWithLabel.font = UIFont.dntLatoRegularFontWith(size: UIFont.dntNoteFontSize)
        self.orConnectWithLabel.textColor = .white
        
        //setup logonButton theme
        
        themeManager.setDCBlueTheme(to: self.loginButton, ofType: .ButtonDefault)
        loginButton.titleLabel?.text = NSLocalizedString("Login", comment: "Login button")
        
        //setting social networks buttons themes
        
        themeManager.setDCBlueTheme(
            to: self.facebookButton,
            ofType: .ButtonSocialNetworkWith(
                logoNormal: UIImage(named: ImageIDs.facebookIcon)!,
                logoHighlighted: UIImage(named: ImageIDs.facebookHighlightedIcon)!
            )
        )
        
        themeManager.setDCBlueTheme(
            to: self.twitterButton,
            ofType: .ButtonSocialNetworkWith(
                logoNormal: UIImage(named: ImageIDs.twitterIcon)!,
                logoHighlighted: UIImage(named: ImageIDs.twitterHighlightedIcon)!
            )
        )
        
        themeManager.setDCBlueTheme(
            to: self.googlePlusButton,
            ofType: .ButtonSocialNetworkWith(
                logoNormal: UIImage(named: ImageIDs.googlePlusIcon)!,
                logoHighlighted: UIImage(named: ImageIDs.googlePlusHighlightedIcon)!
            )
        )
        
    }
    
    func validateAndRequestLogin() {
        
        _ = textFieldShouldEndEditing(emailTextField)
        _ = textFieldShouldEndEditing(passwordTextField)
        
        if let error = emailTextField.errorMessage, !error.isEmpty {
            emailTextField.becomeFirstResponder()
            self.uiIsBlocked = false
            return
        }

        if let error = passwordTextField.errorMessage, !error.isEmpty {
            passwordTextField.becomeFirstResponder()
            self.uiIsBlocked = false
            return
        }
        
        if let email = emailTextField.text, let pass = passwordTextField.text {
            output.requestLoginWith(email: email, password: pass)
        }
        
        self.showLoadingScreenState()
    }
    
}

//MARK: - UITextFieldDelegate

extension LoginScreenViewController: UITextFieldDelegate {
    
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
            validateAndRequestLogin()
        }
        
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        
        if textField == emailTextField {
            
            if let email = emailTextField.text, SystemMethods.User.validateEmail(email) == true {
                emailTextField.errorMessage = ""
            } else {
                emailTextField.errorMessage = emailErrorString
            }
            
        } else if textField == passwordTextField {
            if let pass = passwordTextField.text, SystemMethods.User.validatePassword(pass) == true {
                passwordTextField.errorMessage = ""
            } else {
                passwordTextField.errorMessage = passwordErrorString
            }
        }
        
        return true
        
    }
    
}

//MARK: - IBActions

extension LoginScreenViewController {
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        if uiIsBlocked == true { return }
        uiIsBlocked = true
        self.validateAndRequestLogin()
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        if uiIsBlocked == true { return }
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
    }
    
    @IBAction func facebookButtonPressed(_ sender: UIButton) {
        if uiIsBlocked == true { return }
        uiIsBlocked = true
        output.requestLoginWith(provider: FacebookProvider.shared, in: self)
        self.showLoadingScreenState()
    }
    
    @IBAction func twitterButtonPressed(_ sender: UIButton) {
        if uiIsBlocked == true { return }
        uiIsBlocked = true
        output.requestLoginWith(provider: TwitterProvider.shared, in: self)
        self.showLoadingScreenState()
    }
    
    @IBAction func googlePlusButtonPressed(_ sender: UIButton) {
        if uiIsBlocked == true { return }
        uiIsBlocked = true
        output.requestLoginWith(provider: GooglePlusProvider.shared, in: self)
        self.showLoadingScreenState()
    }
    
    @IBAction func forgotPasswordButtonPressed(_ sender: UIButton) {
        if uiIsBlocked == true { return }
        router.showForgotPasswordScreen()
    }
    
}

extension LoginScreenViewController: LoginScreenControllerInputProtocol {
    
    fileprivate func showLoadingScreenState() {
        let loadingState = State(.loadingState, NSLocalizedString("Loading...", comment: ""))
        self.showState(loadingState)
    }
    
    fileprivate func clearState() {
        uiIsBlocked = false
        let noneState = State(.none)
        self.showState(noneState)
    }
    
    func showWelcomeScreen() {
        clearState()
        router.navigateToWelcomeScreen()
    }
    
    func showUserAgreementScreen() {
        clearState()
        router.showUserAgreementScreen()
    }

    func showErrorMessage(_ message: String) {
        clearState()
        UIAlertController.show(
            controllerWithTitle: NSLocalizedString("Error", comment: ""),
            message: message,
            buttonTitle: NSLocalizedString("Ok", comment: "")
        )
    }
    
    func userDidCancelToAuthenticate() {
        clearState()
    }

}

//MARK: - Login Screen Protocols

protocol LoginScreenControllerInputProtocol: ViewControllerInputProtocol, LoginScreenPresenterOutputProtocol {}
protocol LoginScreenControllerOutputProtocol: ViewControllerOutputProtocol {
    func requestLoginWith(email: String, password: String)
    func requestLoginWith(provider: SocialLoginProviderProtocol, in controller: UIViewController)
}

