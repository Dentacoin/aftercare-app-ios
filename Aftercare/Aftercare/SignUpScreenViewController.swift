//
//  SignUpScreenViewController.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 8/7/17.
//  Copyright © 2017 Dimitar Grudev. All rights reserved.
//

import UIKit

class SignUpScreenViewController : UIViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var signUpLabel: UILabel!
    @IBOutlet weak var uploadUserAvatarButton: UploadImageButton!
    @IBOutlet weak var firstNameTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var lastNameTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var emailTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var passwordTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var connectWithLabel: UILabel!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var twitterButton: UIButton!
    @IBOutlet weak var googlePlusButton: UIButton!
    
    fileprivate var uiIsBlocked = false
    fileprivate var newAvatarUploaded = false
    fileprivate var firstResponderTextField: UITextField?
    
    //MARK: - error message lazy init strings
    
    fileprivate lazy var errorFirstNameString: String = {
        return NSLocalizedString("Wrong first name, should be 2 symbols min.", comment: "Wrong first name message")
    }()
    
    fileprivate lazy var errorLastNameString: String = {
        return NSLocalizedString("Wrong last name, should be 2 symbols min.", comment: "Wrong last name message")
    }()
    
    fileprivate lazy var errorEmailString: String = {
        return  NSLocalizedString("Wrong email.", comment: "Wrong email")
    }()
    
    fileprivate lazy var errorPasswordString: String = {
        return NSLocalizedString("Password is too short.", comment: "Password is too short")
    }()
    
    //MARK: - Clean Swift
    
    var output: SignUpScreenControllerOutputProtocol!
    var router: SignUpScreenRouterProtocol!
    
    //MARK: - initialize
    
    init(configurator: SignUpScreenConfigurator = SignUpScreenConfigurator.shared) {
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
    
    private func configure(configurator: SignUpScreenConfigurator = SignUpScreenConfigurator.shared) {
        configurator.configure(viewController: self)
    }
    
    //MARK: - Lifecicle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addListenersForKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.uploadUserAvatarButton.delegate = self
        self.firstNameTextField.delegate = self
        self.lastNameTextField.delegate = self
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        
        self.addListenersForKeyboard()
        
        setup()
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

extension SignUpScreenViewController {
    
    fileprivate func setup() {
        
        let themeManager = ThemeManager.shared
        
        //setup theme styles
        
        signUpLabel.font = UIFont.dntLatoLightFont(size: UIFont.dntTitleFontSize)
        signUpLabel.textColor = .white
        
        //setup text fields theme styles
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .left
        
        themeManager.setDCBlueTheme(
            to: self.firstNameTextField,
            ofType: .TextFieldDefaut
        )
        
        let firstNamePlaceholder = NSAttributedString.init(
            string: NSLocalizedString("First name", comment: "First Name text field placeholder"),
            attributes: [
                NSAttributedStringKey.foregroundColor: UIColor.white,
                NSAttributedStringKey.font: UIFont.dntLatoLightFont(
                    size: UIFont.dntLabelFontSize
                )!,
                NSAttributedStringKey.paragraphStyle: paragraph
            ]
        )
        
        firstNameTextField.attributedPlaceholder = firstNamePlaceholder
        
        themeManager.setDCBlueTheme(
            to: self.lastNameTextField,
            ofType: .TextFieldDefaut
        )
        
        let lastNamePlaceholder = NSAttributedString.init(
            string: NSLocalizedString("Last name", comment: "Last Name text field placeholder"),
            attributes: [
                NSAttributedStringKey.foregroundColor: UIColor.white,
                NSAttributedStringKey.font: UIFont.dntLatoLightFont(
                    size: UIFont.dntLabelFontSize
                    )!,
                NSAttributedStringKey.paragraphStyle: paragraph
            ]
        )
        
        lastNameTextField.attributedPlaceholder = lastNamePlaceholder
        
        themeManager.setDCBlueTheme(
            to: self.emailTextField,
            ofType: .TextFieldDefaut
        )
        
        let emailPlaceholder = NSAttributedString.init(
                string: NSLocalizedString("Email", comment: "email text field placeholder"),
                attributes: [
                NSAttributedStringKey.foregroundColor: UIColor.white,
                NSAttributedStringKey.font: UIFont.dntLatoLightFont(
                    size: UIFont.dntLabelFontSize
                )!,
                NSAttributedStringKey.paragraphStyle: paragraph
            ]
        )
        
        emailTextField.attributedPlaceholder = emailPlaceholder
        emailTextField.keyboardType = .emailAddress
        
        themeManager.setDCBlueTheme(
            to: self.passwordTextField,
            ofType: .TextFieldDefaut
        )
        
        passwordTextField.isSecureTextEntry = true
        
        let passwordPlaceholder = NSAttributedString.init(
            string: NSLocalizedString("Password", comment: "password text field placeholder"),
            attributes: [
                NSAttributedStringKey.foregroundColor: UIColor.white,
                NSAttributedStringKey.font: UIFont.dntLatoLightFont(
                    size: UIFont.dntLabelFontSize
                )!,
                NSAttributedStringKey.paragraphStyle: paragraph
            ]
        )
        
        passwordTextField.attributedPlaceholder = passwordPlaceholder
        
        themeManager.setDCBlueTheme(
            to: self.createButton,
            ofType: .ButtonDefault
        )
        createButton.titleLabel?.text = NSLocalizedString(
            "Create",
            comment: "Create new user account button label"
        )
        
        //setting social media buttons and a label
        
        connectWithLabel.font = UIFont.dntLatoRegularFontWith(size: UIFont.dntNoteFontSize)
        connectWithLabel.textColor = .white
        
        themeManager.setDCBlueTheme(
            to: facebookButton,
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
    
    func validateAndSignUp() {
        
        _ = textFieldShouldEndEditing(firstNameTextField)
        if let error = firstNameTextField.errorMessage, error != "" {
            firstNameTextField.becomeFirstResponder()
            return
        }
        
        _ = textFieldShouldEndEditing(lastNameTextField)
        if let error = lastNameTextField.errorMessage, error != "" {
            lastNameTextField.becomeFirstResponder()
            return
        }
        
        _ = textFieldShouldEndEditing(emailTextField)
        if let error = emailTextField.errorMessage, error != "" {
            emailTextField.becomeFirstResponder()
            return
        }
        
        _ = textFieldShouldEndEditing(passwordTextField)
        if let error = passwordTextField.errorMessage, error != "" {
            passwordTextField.becomeFirstResponder()
            return
        }
        
        if uiIsBlocked == true {
            return
        }
        uiIsBlocked = true
        showLoadingScreenState()
        
        output.requestSignUpUser(
            firstName: firstNameTextField.text!,
            lastName: lastNameTextField.text!,
            email: emailTextField.text!,
            password: passwordTextField.text!
        )
    }
    
}

//MARK: - IBActions

extension SignUpScreenViewController {
    
    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        if uiIsBlocked == true {
            return
        }
        self.validateAndSignUp()
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        if uiIsBlocked == true {
            return
        }
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
        UserDataContainer.shared.userAvatar = nil
    }
    
    @IBAction func facebookButtonPressed(_ sender: UIButton) {
        if uiIsBlocked == true {
            return
        }
        showLoadingScreenState()
        output.requestLoginWith(provider: FacebookProvider.shared, in: self)
    }
    
    @IBAction func twitterButtonPressed(_ sender: UIButton) {
        if uiIsBlocked == true {
            return
        }
        showLoadingScreenState()
        output.requestLoginWith(provider: TwitterProvider.shared, in: self)
    }
    
    @IBAction func googlePlusButtonPressed(_ sender: UIButton) {
        if uiIsBlocked == true {
            return
        }
        showLoadingScreenState()
        output.requestLoginWith(provider: GooglePlusProvider.shared, in: self)
    }
}

//MARK: - UITextFieldDelegate

extension SignUpScreenViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.textFieldFirstResponder = textField
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == firstNameTextField {
            firstNameTextField.resignFirstResponder()
            lastNameTextField.becomeFirstResponder()
        } else if textField == lastNameTextField {
            lastNameTextField.resignFirstResponder()
            emailTextField.becomeFirstResponder()
        } else if textField == emailTextField {
            emailTextField.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            passwordTextField.resignFirstResponder()
            self.validateAndSignUp()
        }
        
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        
        if textField == firstNameTextField {
            
            if let name = firstNameTextField.text, SystemMethods.User.validateFirstName(name) == true {
                firstNameTextField.errorMessage = ""
            } else {
                firstNameTextField.errorMessage = errorFirstNameString
            }
            
        } else if textField == lastNameTextField {
            
            if let name = lastNameTextField.text, SystemMethods.User.validateLastName(name) == true {
                lastNameTextField.errorMessage = ""
            } else {
                lastNameTextField.errorMessage = errorLastNameString
            }
            
        } else if textField == emailTextField {
            
            if let email = emailTextField.text, SystemMethods.User.validateEmail(email) == true {
                emailTextField.errorMessage = ""
            } else {
                emailTextField.errorMessage = errorEmailString
            }
            
        } else if textField == passwordTextField {
            if let pass = passwordTextField.text, SystemMethods.User.validatePassword(pass) == true {
                passwordTextField.errorMessage = ""
            } else {
                passwordTextField.errorMessage = errorPasswordString
            }
        }
        
        return true
        
    }
    
}

//MARK: - UploadImageButtonDelegate

extension SignUpScreenViewController: UploadImageButtonDelegate {
    
    func showUploadOptions(_ optionsViewController: UIAlertController) {
        if uiIsBlocked == true {
            return
        }
        uiIsBlocked = true
        self.present(optionsViewController, animated: true)
    }
    
    func optionsPresent() {
        uiIsBlocked = false
    }
    
    func optionsCanceled() {
        uiIsBlocked = false
    }
    
    func optionPicked(_ imagePickerViewController: UIImagePickerController) {
        uiIsBlocked = false
        self.present(imagePickerViewController, animated: true, completion: nil)
    }
    
    func optionDidFinishPickingMedia(_ image: UIImage?) {
        uiIsBlocked = false
        UserDataContainer.shared.userAvatar = image
        newAvatarUploaded = true
    }
    
}

extension SignUpScreenViewController: SignUpScreenControllerInputProtocol {
    
    fileprivate func showLoadingScreenState() {
        uiIsBlocked = true
        let loadingState = State(.loadingState, NSLocalizedString("Loading...", comment: ""))
        self.showState(loadingState)
    }
    
    fileprivate func clearState() {
        uiIsBlocked = false
        let noneState = State(.none)
        self.showState(noneState)
    }
    
    func showWelcomeScreen() {
        
        if newAvatarUploaded == true, let avatar = UserDataContainer.shared.userAvatar {
            var data = UpdateUserRequestData()
            data.avatarBase64 = avatar.toBase64()
            APIProvider.updateUser(data) { [weak self] response, error in
                if let error = error {
                    print("Upload User Avatar Error: \(error)")
                    UserDataContainer.shared.userAvatar = nil
                }
                self?.uiIsBlocked = false
                self?.router.navigateToWelcomeScreen()
            }
            
        } else {
            self.uiIsBlocked = false
            self.router.navigateToWelcomeScreen()
        }
    }
    
    func showUserAgreementScreen() {
        
        if newAvatarUploaded == true, let avatar = UserDataContainer.shared.userAvatar {
            var data = UpdateUserRequestData()
            data.avatarBase64 = avatar.toBase64()
            APIProvider.updateUser(data) { [weak self] response, error in
                if let error = error {
                    print("Upload User Avatar Error: \(error)")
                    UserDataContainer.shared.userAvatar = nil
                }
                self?.uiIsBlocked = false
                self?.router.showUserAgreementScreen()
            }
        } else {
            self.uiIsBlocked = false
            self.router.showUserAgreementScreen()
        }
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

//MARK: - SignUp Screen Protocols

protocol SignUpScreenControllerInputProtocol: ViewControllerInputProtocol, SignUpScreenPresenterOutputProtocol {}
protocol SignUpScreenControllerOutputProtocol: ViewControllerOutputProtocol {
    func requestSignUpUser(firstName: String, lastName: String, email: String, password: String)
    func requestLoginWith(provider: SocialLoginProviderProtocol, in controller: UIViewController)
}

