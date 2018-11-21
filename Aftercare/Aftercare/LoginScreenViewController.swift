//
// Aftercare
// Created by Dimitar Grudev on 9.10.18.
// Copyright © 2018 Stichting Administratiekantoor Dentacoin.
//

import Foundation
import UIKit

class LoginScreenViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var connectWithCivitButtonContainer: UIView!
    @IBOutlet weak var connectWithFacebookButtonContainer: UIView!
    @IBOutlet weak var connectWithGoogleButtonContainer: UIView!
    @IBOutlet weak var connectWithTwitterButtonContainer: UIView!
    @IBOutlet weak var orLabel: UILabel!
    @IBOutlet weak var loginWithEmailButton: UIButton!
    
    // MARK: - Private vars

    fileprivate var uiIsBlocked = false
    
    // MARK: - Clean Swift

    var output: LoginScreenControllerOutputProtocol!
    var router: LoginScreenRouterProtocol!
    
    // MARK: - initialize
    
    init(configurator: LoginScreenConfigurator = LoginScreenConfigurator.shared) {
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
    
    // MARK: - Configurator
    
    private func configure(configurator: LoginScreenConfigurator = LoginScreenConfigurator.shared) {
        configurator.configure(viewController: self)
    }
    
    // MARK: - Lifecicle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
}

// MARK: - Theme and components setup

extension LoginScreenViewController {
    
    fileprivate func setup() {
        
        let themeManager = ThemeManager.shared
        
        if let civicButton = LoginButton.loadViewFromNib() {
            connectWithCivitButtonContainer.addSubview(civicButton)
            (civicButton as! LoginButton).delegate = self
            civicButton.frame.size = connectWithCivitButtonContainer.frame.size
            themeManager.setDCBlueTheme(to: civicButton, ofType: .ButtonLogin(type: .civic))
        }
        
        if let facebookButton = LoginButton.loadViewFromNib() {
            connectWithFacebookButtonContainer.addSubview(facebookButton)
            (facebookButton as! LoginButton).delegate = self
            facebookButton.frame.size = connectWithFacebookButtonContainer.frame.size
            themeManager.setDCBlueTheme(to: facebookButton, ofType: .ButtonLogin(type: .facebook))
        }
        
        if let googleButton = LoginButton.loadViewFromNib() {
            connectWithGoogleButtonContainer.addSubview(googleButton)
            (googleButton as! LoginButton).delegate = self
            googleButton.frame.size = connectWithGoogleButtonContainer.frame.size
            themeManager.setDCBlueTheme(to: googleButton, ofType: .ButtonLogin(type: .google))
        }
        
        if let twitterButton = LoginButton.loadViewFromNib() {
            connectWithTwitterButtonContainer.addSubview(twitterButton)
            (twitterButton as! LoginButton).delegate = self
            twitterButton.frame.size = connectWithTwitterButtonContainer.frame.size
            themeManager.setDCBlueTheme(to: twitterButton, ofType: .ButtonLogin(type: .twitter))
        }
        
        orLabel.text = "txt_auth_or".localized()
        loginWithEmailButton.setTitle("txt_auth_login_with_email".localized(), for: .normal)
    }
    
}

// MARK: - LoginButtonDelegate conformance

extension LoginScreenViewController: LoginButtonDelegate {
    
    func loginButtonPressed(_ button: LoginButton) {
        
        showLoadingScreenState()
        
        guard let buttonType = button.type else {
            return
        }
        switch buttonType {
        case .civic:
            output.requestLoginWith(provider: CivicProvider.shared, in: self)
        case .facebook:
            output.requestLoginWith(provider: FacebookProvider.shared, in: self)
        case .google:
            output.requestLoginWith(provider: GooglePlusProvider.shared, in: self)
        case .twitter:
            output.requestLoginWith(provider: TwitterProvider.shared, in: self)
        }
    }
    
}

// MARK: - IBActions

extension LoginScreenViewController {
    
    @IBAction func emailLoginButtonPressed() {
        router.showLoginWithEmailScreen()
    }
    
}

extension LoginScreenViewController: LoginScreenControllerInputProtocol {
    
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

protocol LoginScreenControllerInputProtocol: ViewControllerInputProtocol, LoginScreenPresenterOutputProtocol {}
protocol LoginScreenControllerOutputProtocol: ViewControllerOutputProtocol {
    func requestLoginWith(provider: SocialLoginProviderProtocol, in controller: UIViewController)
    func updateUserConsentOnTermsAndConditions()
}
