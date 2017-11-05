//
//  CollectSecondScreenViewController.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 9/29/17.
//  Copyright © 2017 Dimitar Grudev. All rights reserved.
//

import Foundation
import UIKit

class CollectSecondScreenViewController: UIViewController, ContentConformer {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var headerView: UIView?
    @IBOutlet weak var collectTitleOneLabel: UILabel!
    @IBOutlet weak var collectValueOneLabel: UILabel!
    @IBOutlet weak var separatorLineViewOne: UIView!
    @IBOutlet weak var separatorLineViewTwo: UIView!
    @IBOutlet weak var collectTitleTwoLabel: UILabel!
    @IBOutlet weak var collectValueTwoLabel: UILabel!
    @IBOutlet weak var amountTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var collectButton: UIButton!
    @IBOutlet weak var whatIsDentacoinButton: UIButton!
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomContentPadding: NSLayoutConstraint!
    
    //MARK: - Delegates
    
    var contentDelegate: ContentDelegate?
    
    //MARK: - fileprivates
    
    fileprivate var calculatedConstraints = false
    fileprivate var showTitleBar = false
    fileprivate var data: [String : Any]?
    
    fileprivate lazy var webView: UIWebView = {
        let webView = UIWebView()
        webView.delegate = self
        return webView
    }()
    
    fileprivate lazy var webViewController: UIViewController = {
        let controller = UIViewController()
        return controller
    }()
    
    fileprivate lazy var invalidAmountClaimedError: String = {
        let totalDCN = UserDataContainer.shared.actionScreenData?.totalDCN ?? 0
        return NSLocalizedString("Please claim valid amount of DCN. More than 0 and less than \(totalDCN) DCN", comment: "")
    }()
    
    //MARK: - public
    
    var header: InsidePageHeaderView! {
        return headerView as! InsidePageHeaderView
    }
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        header.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        setup()
        self.addListenersForKeyboard()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.setNavigationBarHidden(!showTitleBar, animated: false)
        showTitleBar = false
    }
    
    deinit {
        self.removeListenersForKeyboard()
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
    
    //MARK: - resign first responder
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //MARK: - Public API
    
    func config(_ data: [String: Any]) {
        self.data = data
    }
    
    //MARK: - Private Logic
    
    fileprivate func showInvalidAmountClaimedError() {
        UIAlertController.show(
            controllerWithTitle: NSLocalizedString("Error", comment: ""),
            message: invalidAmountClaimedError,
            buttonTitle: NSLocalizedString("Ok", comment: "")
        )
        self.amountTextField.errorMessage = invalidAmountClaimedError
    }
}

//MARK: - Theme and appearance

extension CollectSecondScreenViewController {
    
    fileprivate func setup() {
        
        header.updateTitle(NSLocalizedString("Collect", comment: ""))
        
        collectTitleOneLabel.textColor = UIColor.dntCharcoalGrey
        collectTitleOneLabel.font = UIFont.dntLatoLightFont(size: UIFont.dntLargeTitleFontSize)
        collectTitleOneLabel.text = NSLocalizedString("Collect DCN in Wallet", comment: "")
        
        collectValueOneLabel.textColor = UIColor.dntCeruleanBlue
        collectValueOneLabel.font = UIFont.dntLatoRegularFontWith(size: UIFont.dntLargeTitleFontSize)
        let defaults = UserDefaults.standard
        if let totalClaimed = defaults.value(forKey: "TotalDCNClaimed") as? Int {
            collectValueOneLabel.text = String(totalClaimed) + "DCN"
        } else {
            collectValueOneLabel.text = "0 DCN"
        }
        
        separatorLineViewOne.backgroundColor = UIColor.dntCeruleanBlue
        separatorLineViewTwo.backgroundColor = UIColor.dntCeruleanBlue
        
        collectTitleTwoLabel.textColor = UIColor.dntCharcoalGrey
        collectTitleTwoLabel.font = UIFont.dntLatoLightFont(size: UIFont.dntLargeTitleFontSize)
        collectTitleTwoLabel.text = NSLocalizedString("Current Balance in App", comment: "")
        
        collectValueTwoLabel.textColor = UIColor.dntCeruleanBlue
        collectValueTwoLabel.font = UIFont.dntLatoRegularFontWith(size: UIFont.dntLargeTitleFontSize)
        
        if let totalDCN = UserDataContainer.shared.actionScreenData?.totalDCN {
            collectValueTwoLabel.text = String(totalDCN) + " DCN"
        }
        
        let themeManager = ThemeManager.shared
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .left
        
        themeManager.setDCBlueTheme(to: self.amountTextField, ofType: .TextFieldDarkBlue)
        let amountPlaceholder = NSAttributedString.init(
            string: NSLocalizedString("Amount", comment: ""),
            attributes: [
                NSAttributedStringKey.foregroundColor: UIColor.dntCeruleanBlue,
                NSAttributedStringKey.font: UIFont.dntLatoLightFont(size: UIFont.dntLabelFontSize)!,
                NSAttributedStringKey.paragraphStyle: paragraph
            ])
        self.amountTextField.attributedPlaceholder = amountPlaceholder
        amountTextField.keyboardType = .numberPad
        
        themeManager.setDCBlueTheme(to: collectButton, ofType: .ButtonDefaultBlueGradient)
        themeManager.setDCBlueTheme(to: whatIsDentacoinButton, ofType: .ButtonLinkWithColor(fontSize: UIFont.dntNoteFontSize, color: .dntCeruleanBlue))
    }
    
}

//MARK: - UITextFieldDelegate

extension CollectSecondScreenViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.textFieldFirstResponder = textField
        return true
    }
    
}

//MARK: - InsidePageHeaderViewDelegate

extension CollectSecondScreenViewController: InsidePageHeaderViewDelegate {
    
    func backButtonIsPressed() {
        contentDelegate?.backButtonIsPressed()
    }
    
}

//MARK: - IBActions

extension CollectSecondScreenViewController {
    
    @IBAction func collectButtonPressed(_ sender: UIButton) {
        //Validate the ammount claimed by the user
        guard let claimedAmountString = self.amountTextField.text else {
            self.showInvalidAmountClaimedError()
            return
        }
        if let claimedAmount = Int(claimedAmountString) {
            if let totalDCN = UserDataContainer.shared.actionScreenData?.totalDCN {
                if claimedAmount <= totalDCN, claimedAmount > 0 {
                    
                    guard let wallet = self.data?["userWallet"] as? String else {
                        print("Invalid Wallet")
                        return
                    }
                    
                    let parameters = TransactionData(amount: claimedAmount, wallet: wallet)
                    
                    let loadingState = State(.loadingState, NSLocalizedString("Loading...", comment: ""))
                    self.showState(loadingState)
                    
                    APIProvider.requestCollectionOfDCN(parameters) { [weak self] result, error in
                        
                        if let error = error {
                            UIAlertController.show(
                                controllerWithTitle: NSLocalizedString("Error", comment: ""),
                                message: error.toNSError().localizedDescription,
                                buttonTitle: NSLocalizedString("Ok", comment: "")
                            )
                            return
                        }

                        self?.amountTextField.text = ""
                        self?.amountTextField.errorMessage = nil

                        //save in Defaults
                        let defaults = UserDefaults.standard

                        //add claimed DCN to already claimed before
                        if let totalClaimed = defaults.value(forKey: "TotalDCNClaimed") as? Int {
                            defaults.set(totalClaimed + claimedAmount, forKey: "TotalDCNClaimed")
                        } else {
                            defaults.set(claimedAmount, forKey: "TotalDCNClaimed")
                        }
                        
                        //change state to none and show next screen
                        self?.showState(State(.none))
                        self?.showSuccessScreen(claimedAmount)
                        
                    }
                    
                } else {
                    self.showInvalidAmountClaimedError()
                }
            } else {
                self.showInvalidAmountClaimedError()
            }
        } else {
            self.showInvalidAmountClaimedError()
        }
    }
    
    @IBAction func whatIsDCNButtonPressed(_ sender: UIButton) {
        
        showTitleBar = true
        self.navigationController?.pushViewController(webViewController, animated: true)
        
        webView.frame = webViewController.view.frame
        webView.backgroundColor = .white
        webView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        webViewController.view.addSubview(webView)
        if let url = URL(string: "https://www.dentacoin.com") {
            webView.loadRequest(URLRequest(url: url))
        }
        
    }
    
    fileprivate func showSuccessScreen(_ collectAmount: Int) {
        let vcID = String(describing: SuccessfullyCollectedScreenViewController.self)
        let params: [String: Any] = ["collectDCN": collectAmount]
        self.contentDelegate?.requestLoadViewController(vcID, params)
    }
    
}


extension CollectSecondScreenViewController: UIWebViewDelegate {
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        print(error)
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        print("REQUEST: \(request)")
        return true
    }
}
