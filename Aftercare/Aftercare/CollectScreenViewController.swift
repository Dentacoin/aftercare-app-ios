//
//  CollectScreenViewController.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 9/9/17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import QRCodeReader

class CollectScreenViewController: UIViewController, ContentConformer {
    
    //MARK: - IBOutlets
    @IBOutlet weak var headerView: UIView?
    @IBOutlet weak var step1Label: UILabel!
    @IBOutlet weak var step1AddressLabel: UILabel!
    @IBOutlet weak var step2Label: UILabel!
    @IBOutlet weak var walletAddressTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomContentPadding: NSLayoutConstraint!
    
    //MARK: - Delegates
    
    var contentDelegate: ContentDelegate?
    
    //MARK: - Fileprivates
    
    fileprivate lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()
    
    fileprivate lazy var wrongWalletError: String = {
        return NSLocalizedString("Your Wallet address is not in correct format.", comment: "")
    }()
    
    fileprivate var calculatedConstraints = false
    
    //MARK: - Public
    
    var header: InitialPageHeaderView! {
        return headerView as! InitialPageHeaderView
    }
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        header.delegate = self
        walletAddressTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setup()
        self.addListenersForKeyboard()
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
    
    //MARK: - Private Logic
    
    fileprivate func showCameraQRScannerScreen() {
        
        // Retrieve the QRCode content
        // By using the delegate pattern
        readerVC.delegate = self
        
        // Or by using the closure pattern
        readerVC.completionBlock = { (result: QRCodeReaderResult?) in
            print(result ?? "null")
        }
        
        // Presents the readerVC as modal form sheet
        readerVC.modalPresentationStyle = .formSheet
        present(readerVC, animated: true, completion: nil)
        
    }
    
    fileprivate func cantCollectDCNNowError() {
        UIAlertController.show(
            controllerWithTitle: NSLocalizedString("Info", comment: ""),
            message: NSLocalizedString("You can collect your dentacoins only after you use the app for at least 90 days and have no less than 1000DCNs", comment: ""),
            buttonTitle: NSLocalizedString("Ok", comment: "")
        )
    }
    
    fileprivate func wrongWalletAddressError() {
        UIAlertController.show(
            controllerWithTitle: NSLocalizedString("Error", comment: ""),
            message: wrongWalletError,
            buttonTitle: NSLocalizedString("Ok", comment: "")
        )
    }
    
    fileprivate func validateWalletAddress(_ wallet: String) -> Bool {
        return Address(string: wallet) != nil
    }
    
}

//MARK: - Theme and appearancesetup

extension CollectScreenViewController {
    
    fileprivate func setup() {
        
        header.updateTitle(NSLocalizedString("Collect", comment: ""))
        
        let themeManager = ThemeManager.shared
        
        self.step1Label.textColor = UIColor.dntCharcoalGrey
        self.step1Label.font = UIFont.dntLatoLightFont(size: UIFont.dntLargeTitleFontSize)
        self.step1Label.text = NSLocalizedString("Create your crypto wallet at:", comment: "")
        self.step1Label.numberOfLines = 2
        
        self.step1AddressLabel.textColor = UIColor.dntCeruleanBlue
        self.step1AddressLabel.font = UIFont.dntLatoRegularFontWith(size: UIFont.dntLargeTextSize)
        self.step1AddressLabel.text = NSLocalizedString("www.myetherwallet.com", comment: "")
        
        self.step2Label.textColor = UIColor.dntCharcoalGrey
        self.step2Label.font = UIFont.dntLatoLightFont(size: UIFont.dntLargeTitleFontSize)
        self.step2Label.text = NSLocalizedString("Send us your crypto wallet address", comment: "")
        self.step2Label.numberOfLines = 2
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .left
        
        themeManager.setDCBlueTheme(to: self.walletAddressTextField, ofType: .TextFieldDarkBlue)
        let walletAddressPlaceholder = NSAttributedString.init(
            string: NSLocalizedString("Crypto wallet address", comment: ""),
            attributes: [
                NSAttributedStringKey.foregroundColor: UIColor.dntCeruleanBlue,
                NSAttributedStringKey.font: UIFont.dntLatoLightFont(size: UIFont.dntLabelFontSize)!,
                NSAttributedStringKey.paragraphStyle: paragraph
            ])
        self.walletAddressTextField.attributedPlaceholder = walletAddressPlaceholder
        
        themeManager.setDCBlueTheme(to: sendButton, ofType: .ButtonDefaultBlueGradient)
        
    }
    
}

//MARK: - QRCodeReaderViewControllerDelegate

extension CollectScreenViewController: QRCodeReaderViewControllerDelegate {
    
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        
        //Dismiss the QR Camera screen first and then process the QR data.
        //If something goes wrong and data can't be processed the User wont be left on the frozen QR Camera screen
        dismiss(animated: true, completion: nil)
        
        //get scanned value
        if self.validateWalletAddress(result.value) {
            
            //clear if any error
            self.walletAddressTextField.errorMessage = nil
            walletAddressTextField.text = result.value
            return
            
        } else {
            var ibanComponents = result.value.components(separatedBy: ":")
            if ibanComponents.count == 0 {
                self.walletAddressTextField.errorMessage = self.wrongWalletError
                wrongWalletAddressError()
                return
            }
            ibanComponents.removeFirst()
            ibanComponents = ibanComponents.joined().components(separatedBy: "?amount=")
            if ibanComponents.count == 0 {
                self.walletAddressTextField.errorMessage = self.wrongWalletError
                wrongWalletAddressError()
                return
            }
            
            let ibanValue = ibanComponents.removeFirst()
            if ibanValue == "" {
                self.walletAddressTextField.errorMessage = self.wrongWalletError
                wrongWalletAddressError()
                return
            }
            let forthIndex = ibanValue.index(ibanValue.startIndex, offsetBy: 4)
            let ibanBase36 = String(ibanValue[forthIndex...])
            ibanComponents = ibanComponents.joined().components(separatedBy: "&token=")
            if ibanComponents.count == 0 {
                self.walletAddressTextField.errorMessage = self.wrongWalletError
                wrongWalletAddressError()
                return
            }
            
            guard let amount = Int(ibanComponents.removeFirst()) else {
                self.walletAddressTextField.errorMessage = self.wrongWalletError
                wrongWalletAddressError()
                return
            }
            guard let token = ibanComponents.last else {
                self.walletAddressTextField.errorMessage = self.wrongWalletError
                wrongWalletAddressError()
                return
            }
            
            //Simple tuple that holds the processed data from the QR Code
            let qrData: (iban: String, amount: Int, token: String) = (
                iban: ibanBase36,
                amount: amount,
                token: token
            )
            
            let bigNumb = BigNumber(base36String: qrData.iban)
            if let walletAddress = bigNumb?.hexString {
                let valid = self.validateWalletAddress(walletAddress)
                if !valid {
                    self.walletAddressTextField.errorMessage = self.wrongWalletError
                    wrongWalletAddressError()
                } else {
                    self.walletAddressTextField.errorMessage = nil
                    walletAddressTextField.text = walletAddress
                }
            } else {
                self.walletAddressTextField.errorMessage = self.wrongWalletError
                wrongWalletAddressError()
            }
            //print("BIG NUMBER TO HEX: \(bigNumb?.hexString)")
        }
    }
    
    //This is an optional delegate method, that allows you to be notified when the user switches the cameraName
    //By pressing on the switch camera button
    func reader(_ reader: QRCodeReaderViewController, didSwitchCamera newCaptureDevice: AVCaptureDeviceInput) {
        print("Switching capturing to: \(newCaptureDevice.device.localizedName)")
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - UITextFieldDelegate

extension CollectScreenViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.textFieldFirstResponder = textField
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let wallet = self.walletAddressTextField.text {
            let valid = self.validateWalletAddress(wallet)
            if !valid {
                self.walletAddressTextField.errorMessage = self.wrongWalletError
            }
        } else {
            self.walletAddressTextField.errorMessage = self.wrongWalletError
        }
        return true
    }
    
}

//MARK: - IBActions

extension CollectScreenViewController {
    
    @IBAction func scanQRCodeButtonPressed(_ sender: UIButton) {
        
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            UIAlertController.show(
                controllerWithTitle: NSLocalizedString("Error", comment: ""),
                message: NSLocalizedString("This device doesn't have builtin Camera", comment: ""),
                buttonTitle: NSLocalizedString("Ok", comment: "")
            )
            return
        }
        
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        
        if authStatus == AVAuthorizationStatus.denied {
            //User has denied access to Camera
            
            UIAlertController.show(
                controllerWithTitle: NSLocalizedString("Unable to access the Camera", comment: ""),
                message: NSLocalizedString("To enable access, go to Settings > Privacy > Camera and turn on Camera access for this app.", comment: ""),
                buttonTitle: NSLocalizedString("Ok", comment: "")
            )
            
        } else if authStatus == AVAuthorizationStatus.notDetermined {
            // The user has not yet been presented with the option to grant access to the camera hardware.
            // Ask for it.
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { [weak self] access in
                // If access was denied, we do not set the setup error message since access was just denied.
                if access {
                    // Allowed access to camera, go ahead and present the UIImagePickerController.
                    self?.showCameraQRScannerScreen()
                }
            })
        } else {
            // Allowed access to camera
            self.showCameraQRScannerScreen()
        }
        
    }
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        
        guard let wallet = self.walletAddressTextField.text else {
            print("No Wallet Address")
            return
        }
        
        if !self.validateWalletAddress(wallet) {
            self.wrongWalletAddressError()
            self.walletAddressTextField.errorMessage = self.wrongWalletError
            return
        }
        
        let vcID = String(describing: CollectSecondScreenViewController.self)
        contentDelegate?.requestLoadViewController(vcID, ["userWallet" : wallet])
        
    }
    
}

//MARK: - InitialPageHeaderViewDelegate

extension CollectScreenViewController: InitialPageHeaderViewDelegate {
    
    func mainMenuButtonIsPressed() {
        contentDelegate?.openMainMenu()
        self.view.endEditing(true)
    }
    
}
