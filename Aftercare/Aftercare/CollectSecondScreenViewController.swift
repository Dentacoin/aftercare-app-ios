//
//  CollectSecondScreenViewController.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 9/29/17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
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
}

//MARK: - Theme and appearance

extension CollectSecondScreenViewController {
    
    fileprivate func setup() {
        
        header.updateTitle("settings_lbl_collect_dentacoins".localized())
        
        collectTitleOneLabel.textColor = UIColor.dntCharcoalGrey
        collectTitleOneLabel.font = UIFont.dntLatoLightFont(size: UIFont.dntLargeTitleFontSize)
        collectTitleOneLabel.text = "collect_hdl_total_dcn".localized()
        
        collectValueOneLabel.textColor = UIColor.dntCeruleanBlue
        collectValueOneLabel.font = UIFont.dntLatoRegularFontWith(size: UIFont.dntLargeTitleFontSize)
        
        guard let earned = UserDataContainer.shared.actionScreenData?.earnedDCN else {
            return
        }
        guard let pending = UserDataContainer.shared.actionScreenData?.pendingDCN else {
            return
        }
        collectValueOneLabel.text = "txt_dcn".localized(String(earned + pending))
        
        separatorLineViewOne.backgroundColor = UIColor.dntCeruleanBlue
        separatorLineViewTwo.backgroundColor = UIColor.dntCeruleanBlue
        
        collectTitleTwoLabel.textColor = UIColor.dntCharcoalGrey
        collectTitleTwoLabel.font = UIFont.dntLatoLightFont(size: UIFont.dntLargeTitleFontSize)
        collectTitleTwoLabel.text = "collect_hdl_current_balance".localized()
        
        collectValueTwoLabel.textColor = UIColor.dntCeruleanBlue
        collectValueTwoLabel.font = UIFont.dntLatoRegularFontWith(size: UIFont.dntLargeTitleFontSize)
        collectValueTwoLabel.text = "txt_dcn".localized(String(earned))
        
        let themeManager = ThemeManager.shared
        
        collectButton.setTitle("collect_wallet_btn_collect".localized(), for: .normal)
        themeManager.setDCBlueTheme(to: collectButton, ofType: .ButtonDefaultBlueGradient)
        
        collectButton.isEnabled = !(earned <= 0)
        
        whatIsDentacoinButton.setTitle("collect_txt_what_is_dentacoin".localized(), for: .normal)
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
        guard let earnedAmount = UserDataContainer.shared.actionScreenData?.earnedDCN else {
            return
        }
        
        guard let wallet = self.data?["userWallet"] as? String else {
            print("Invalid Wallet")
            return
        }
        
        var parameters = TransactionData()
        parameters.amount = earnedAmount
        parameters.wallet = wallet
        
        let loadingState = State(.loadingState, "txt_loading".localized())
        self.showState(loadingState)
        
        APIProvider.requestCollectionOfDCN(parameters) { [weak self] result, error in
            
            self?.showState(State(.none))
            
            if let error = error {
                UIAlertController.show(
                    controllerWithTitle: "error_popup_title".localized(),
                    message: error.toNSError().localizedDescription,
                    buttonTitle: "txt_ok".localized()
                )
                return
            }
            
            self?.showSuccessScreen(earnedAmount)
            
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
