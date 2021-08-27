//
//  SignUpScreenViewController.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 8/7/17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
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
    @IBOutlet weak var captchaCodeTextField: SkyFloatingLabelTextField!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var connectWithLabel: UILabel!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var twitterButton: UIButton!
    @IBOutlet weak var googlePlusButton: UIButton!
    
    @IBOutlet weak var captchaView: CaptchaView!
    
    fileprivate var uiIsBlocked = false
    fileprivate var newAvatarUploaded = false
    fileprivate var firstResponderTextField: UITextField?
    
    //MARK: - error message lazy init strings
    
    fileprivate lazy var errorFirstNameString: String = {
        return "error_txt_first_name_too_short".localized()
    }()
    
    fileprivate lazy var errorLastNameString: String = {
        return "error_txt_last_name_too_short".localized()
    }()
    
    fileprivate lazy var errorEmailString: String = {
        return  "error_txt_email_not_valid".localized()
    }()
    
    fileprivate lazy var errorPasswordString: String = {
        return "error_txt_password_short".localized()
    }()
    
    fileprivate lazy var errorWrongCaptchaCodeString: String = {
        return "profile_wrong_code_error".localized()
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
        
        uploadUserAvatarButton.delegate = self
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        captchaCodeTextField.delegate = self
        captchaView.requestNewCaptcha()
        
        addListenersForKeyboard()
        setup()
    }
    
    deinit {
        self.removeListenersForKeyboard()
        self.captchaView.disposeCaptcha()
    }
    
    //MARK: - resign first responder
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func onScrollViewTapGuesture(_ sender: UITapGestureRecognizer) {
        self.scrollView.endEditing(true)
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
            string: "signup_hnt_first_name".localized(),
            attributes: [
                .foregroundColor: UIColor.white,
                .font: UIFont.dntLatoLightFont(
                    size: UIFont.dntLabelFontSize
                )!,
                .paragraphStyle: paragraph
            ]
        )
        
        firstNameTextField.attributedPlaceholder = firstNamePlaceholder
        firstNameTextField.autocorrectionType = .no
        
        themeManager.setDCBlueTheme(
            to: self.lastNameTextField,
            ofType: .TextFieldDefaut
        )
        
        let lastNamePlaceholder = NSAttributedString.init(
            string: "signup_hnt_last_name".localized(),
            attributes: [
                .foregroundColor: UIColor.white,
                .font: UIFont.dntLatoLightFont(
                    size: UIFont.dntLabelFontSize
                    )!,
                .paragraphStyle: paragraph
            ]
        )
        
        lastNameTextField.attributedPlaceholder = lastNamePlaceholder
        lastNameTextField.autocorrectionType = .no
        
        themeManager.setDCBlueTheme(
            to: self.emailTextField,
            ofType: .TextFieldDefaut
        )
        
        let emailPlaceholder = NSAttributedString.init(
                string: "signup_hnt_email".localized(),
                attributes: [
                .foregroundColor: UIColor.white,
                .font: UIFont.dntLatoLightFont(
                    size: UIFont.dntLabelFontSize
                )!,
                .paragraphStyle: paragraph
            ]
        )
        
        emailTextField.attributedPlaceholder = emailPlaceholder
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocorrectionType = .no
        
        themeManager.setDCBlueTheme(
            to: self.passwordTextField,
            ofType: .TextFieldDefaut
        )
        
        passwordTextField.isSecureTextEntry = true
        
        let passwordPlaceholder = NSAttributedString.init(
            string: "signup_hnt_password".localized(),
            attributes: [
                .foregroundColor: UIColor.white,
                .font: UIFont.dntLatoLightFont(
                    size: UIFont.dntLabelFontSize
                )!,
                .paragraphStyle: paragraph
            ]
        )
        
        passwordTextField.attributedPlaceholder = passwordPlaceholder
        passwordTextField.autocorrectionType = .no
        
        let captchaPlaceholder = NSAttributedString.init(
            string: "signup_hnt_captcha".localized(),
            attributes: [
                .foregroundColor: UIColor.white,
                .font: UIFont.dntLatoLightFont(
                    size: UIFont.dntLabelFontSize
                    )!,
                .paragraphStyle: paragraph
            ]
        )
        
        themeManager.setDCBlueTheme(
            to: self.captchaCodeTextField,
            ofType: .TextFieldDefaut
        )
        
        captchaCodeTextField.attributedPlaceholder = captchaPlaceholder
        captchaCodeTextField.autocorrectionType = .no
        
        themeManager.setDCBlueTheme(
            to: self.createButton,
            ofType: .ButtonDefault
        )
        createButton.titleLabel?.text = "signup_btn_create".localized()
        
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
    }
    
    @discardableResult fileprivate func validateUserData() -> Bool {
        
        _ = textFieldShouldEndEditing(firstNameTextField)
        if let error = firstNameTextField.errorMessage, error != "" {
            firstNameTextField.becomeFirstResponder()
            return false
        }
        
        _ = textFieldShouldEndEditing(lastNameTextField)
        if let error = lastNameTextField.errorMessage, error != "" {
            lastNameTextField.becomeFirstResponder()
            return false
        }
        
        _ = textFieldShouldEndEditing(emailTextField)
        if let error = emailTextField.errorMessage, error != "" {
            emailTextField.becomeFirstResponder()
            return false
        }
        
        _ = textFieldShouldEndEditing(passwordTextField)
        if let error = passwordTextField.errorMessage, error != "" {
            passwordTextField.becomeFirstResponder()
            return false
        }
        
        _ = textFieldShouldEndEditing(captchaCodeTextField)
        if let error = captchaCodeTextField.errorMessage, error != "" {
            captchaCodeTextField.becomeFirstResponder()
            return false
        }
        
        return true
    }
    
}

//MARK: - IBActions

extension SignUpScreenViewController {
    
    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        if uiIsBlocked == true {
            return
        }
        if validateUserData() {
            // the sign up process continues from one of the two methods
            // userDidAcceptTermsAndConditions() or userDidDeclineTermsAndConditions()
            router.showUserAgreementScreen() { [weak self] consent in
                
                if consent {
                    self?.output.requestSignUpUser(
                        firstName: self?.firstNameTextField.text ?? "",
                        lastName: self?.lastNameTextField.text ?? "",
                        email: self?.emailTextField.text ?? "",
                        password: self?.passwordTextField.text ?? "",
                        captchaId: self?.captchaView.data?.id ?? 0,
                        captchaCode: self?.captchaCodeTextField.text ?? ""
                    )
                } else {
                    self?.clearState()
                }
            }
            showLoadingScreenState()
            uiIsBlocked = true
        }
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
        output.requestLoginWith(provider: FacebookProvider.shared, in: self)
        showLoadingScreenState()
        uiIsBlocked = true
    }
    
    @IBAction func twitterButtonPressed(_ sender: UIButton) {
        if uiIsBlocked == true {
            return
        }
        output.requestLoginWith(provider: TwitterProvider.shared, in: self)
        showLoadingScreenState()
        uiIsBlocked = true
    }
    
    @IBAction func googlePlusButtonPressed(_ sender: UIButton) {
        if uiIsBlocked == true {
            return
        }
        output.requestLoginWith(provider: GooglePlusProvider.shared, in: self)
        showLoadingScreenState()
        uiIsBlocked = true
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
            captchaCodeTextField.becomeFirstResponder()
        } else if textField == captchaCodeTextField {
            captchaCodeTextField.resignFirstResponder()
            validateUserData()
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
        } else if textField == captchaCodeTextField {
            if let captchaCode = captchaCodeTextField.text, captchaCode != "" {
                captchaCodeTextField.errorMessage = ""
            } else {
                captchaCodeTextField.errorMessage = errorWrongCaptchaCodeString
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
        let loadingState = State(.loadingState, "txt_loading".localized())
        self.showState(loadingState)
    }
    
    fileprivate func clearState() {
        uiIsBlocked = false
        let noneState = State(.none)
        self.showState(noneState)
        UserDataContainer.shared.userAvatar = nil
    }
    
    func showWelcomeScreen() {
        if newAvatarUploaded == true, let avatar = UserDataContainer.shared.userAvatar {
            // Upload user avatar before routing to welcome screen
            var data = UpdateUserRequestData()
            data.avatarBase64 = avatar.toBase64()
            APIProvider.updateUser(data) { [weak self] response, error in
                if let _ = error {
                    //print("Upload User Avatar Error: \(error)")
                    UserDataContainer.shared.userAvatar = nil
                }
                self?.clearState()
                self?.router.navigateToWelcomeScreen()
            }
            
        } else {
            // no user avatar selected so we route to welcome screen
            clearState()
            self.router.navigateToWelcomeScreen()
        }
    }
    
    func showErrorMessage(_ message: String) {
        clearState()
        UIAlertController.show(
            title: "error_popup_title".localized(),
            message: message,
            handler: { [weak self] in
                self?.captchaView.invalidate()
                self?.captchaCodeTextField.text = ""
            }
        )
    }
    
    func userIsNotConsentOnTermsAndConditions() {
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

//MARK: - SignUp Screen Protocols

protocol SignUpScreenControllerInputProtocol: ViewControllerInputProtocol, SignUpScreenPresenterOutputProtocol {}
protocol SignUpScreenControllerOutputProtocol: ViewControllerOutputProtocol {
    func requestSignUpUser(firstName: String, lastName: String, email: String, password: String, captchaId: Int, captchaCode: String)
    func requestLoginWith(provider: SocialLoginProviderProtocol, in controller: UIViewController)
    func updateUserConsentOnTermsAndConditions()
}

