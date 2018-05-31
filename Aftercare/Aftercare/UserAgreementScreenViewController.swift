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
    
    //MARK: - fileprivate vars
    
    fileprivate var signUpData: AuthenticationRequestProtocol?
    fileprivate var signUpCallback: AuthenticationResult?
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    //MARK: - Public API
    
    func config(_ data: AuthenticationRequestProtocol) {
        self.signUpData = data
    }
}

//MARK: - Theme and components setup

extension UserAgreementScreenViewController {
    
    fileprivate func setup() {
        
        self.header.updateTitle(userAgreementTitleString)
        self.header.delegate = self
        
//        guard let fileURL = Bundle.main.url(forResource: "user-agreement", withExtension: "html") else { return }
//        let stringData = try? String.init(contentsOf: fileURL, encoding: .utf8)
//        self.textField.font = UIFont.dntLatoLightFont(size: UIFont.dntNormalTextSize)
//
//        let htmlData = NSString(string: stringData ?? "").data(using: String.Encoding.unicode.rawValue)
//        let options = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html]
//        let attributedString = try! NSAttributedString(data: htmlData!, options: options, documentAttributes: nil)
//        self.textField.attributedText = attributedString
        
        let htmlData = NSString(string: "user_agreement".localized()).data(using: String.Encoding.unicode.rawValue)
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
        
        //Create callback instance to handle signUp responces
        signUpCallback = { [weak self] result, error in
            
            self?.changeToNoneState()
            
            if let error = error?.toNSError() {
                self?.showErrorMessage(error)
                return
            }
            
            guard let session = result else {
                print("Error: Missing Session Data")
                return
            }
            
            self?.saveEmailSession(session)
            self?.retreiveUserInfo()
            
        }
    }
    
    fileprivate func userDisagree() {
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
    }
    
    fileprivate func userDidAgree() {
        //attempt signUp process
        if let emailData = self.signUpData as? EmailRequestData {
            self.signUpWithEmail(emailData)
        } else if let socialData = self.signUpData {
            self.signUpWithSocialNetwork(socialData)
        } else {
            //Error: no Sign Up data, can't proceed with the signUp process
        }
    }
    
    fileprivate func changeToLoadingState() {
        var loadingState = State(.loadingState)
        loadingState.title = "txt_loading".localized()
        self.showState(loadingState)
    }
    
    fileprivate func changeToNoneState() {
        let noneState = State(.none)
        self.showState(noneState)
    }
    
    fileprivate func signUpWithEmail(_ data: EmailRequestData) {
        changeToLoadingState()
        APIProvider.signUp(withEmail: data, onComplete: signUpCallback!)
    }
    
    fileprivate func signUpWithSocialNetwork(_ data: AuthenticationRequestProtocol) {
        changeToLoadingState()
        APIProvider.signUpWithSocial(params: data, onComplete: signUpCallback!)
    }
    
    fileprivate func saveEmailSession(_ sessionData: UserSessionData) {
        EmailProvider.shared.saveUserSession(sessionData)
    }
    
    fileprivate func retreiveUserInfo() {
        APIProvider.retreiveUserInfo() { [weak self] userData, error in
            if let error = error {
                self?.showErrorMessage(error.toNSError())
                return
            }
            if let data = userData {
                UserDataContainer.shared.userInfo = data
                self?.userDidSignUp()
            }
        }
    }
    
    fileprivate func showErrorMessage(_ error: NSError) {
        UIAlertController.show(
            controllerWithTitle: "error_popup_title".localized(),
            message: error.localizedDescription,
            buttonTitle: "txt_ok".localized()
        )
    }
    
    fileprivate func userDidSignUp() {
        if let navController = self.navigationController {
            let controller: WelcomeScreenViewController! = UIStoryboard.main.instantiateViewController()
            navController.pushViewController(controller, animated: true)
        }
    }
    
}

//MARK: - IBActions

extension UserAgreementScreenViewController {
    
    @IBAction func agreeButtonPressed(_ sender: UIButton) {
        userDidAgree()
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        userDisagree()
    }
    
}

//MARK: - InsidePageHeaderViewDelegate

extension UserAgreementScreenViewController: InsidePageHeaderViewDelegate {
    
    func backButtonIsPressed() {
        self.userDisagree()
    }
    
}
