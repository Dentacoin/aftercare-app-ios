//
//  EditUserProfileScreenViewController.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 9/9/17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import Foundation
import UIKit
import GooglePlaces
import GooglePlacePicker

class EditUserProfileScreenViewController: UIViewController, ContentConformer {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var headerView: UIView?
    @IBOutlet weak var uploadAvatarButton: UploadImageButton!
    @IBOutlet weak var cancelIconImage: UIImageView!
    @IBOutlet weak var firstNameTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var lastNameTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var passwordTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var zipCodeTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var cityCountryTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var birthDateTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var maleButton: UIButton!
    @IBOutlet weak var femaleButton: UIButton!
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var deleteProfileButton: UIButton!
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomContentPadding: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    
    //MARK: - Delegates
    
    var contentDelegate: ContentDelegate?
    
    //MARK: - Public
    
    var header: InsidePageHeaderView! {// TODO: remove this property and find solution for it
        return headerView as? InsidePageHeaderView
    }
    
    //MARK: - error message lazy init strings
    
    fileprivate lazy var errorFirstNameString: String = {
        return "error_txt_first_name_too_short".localized()
    }()
    
    fileprivate lazy var errorLastNameString: String = {
        return "error_txt_last_name_too_short".localized()
    }()
    
    fileprivate lazy var errorPasswordString: String = {
        return "error_txt_password_short".localized()
    }()
    
    fileprivate lazy var errorCityCountryString: String = {
        return "error_txt_wrong_city_country".localized()
    }()
    
    fileprivate lazy var errorZipString: String = {
        return "error_txt_wrong_zip_code".localized()
    }()
    
    fileprivate var genderOptionSelected = true
    fileprivate var uiIsBlocked = false
    fileprivate var newAvatarUploaded = false
    fileprivate var calculatedConstraints = false
    fileprivate var genderType: GenderType = GenderType.unspecified
    fileprivate var newAvatar: UIImage?
    
    fileprivate let datePickerView: UIDatePicker = {
        let datePickerView: UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePicker.Mode.date
        
        let nowDate = Date()
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: nowDate)
        let currentMonth = calendar.component(.month, from: nowDate)
        let currentDay = calendar.component(.day, from: nowDate)
        
        var maxDateComponents = DateComponents()
        maxDateComponents.year = currentYear - 5
        maxDateComponents.month = currentMonth
        maxDateComponents.day = currentDay
        let maximumDate = calendar.date(from: maxDateComponents)
        
        var minDateComponents = DateComponents()
        minDateComponents.year = currentYear - 110
        minDateComponents.month = currentMonth
        minDateComponents.day = currentDay
        let minimumDate = calendar.date(from: minDateComponents)
        
        datePickerView.minimumDate = minimumDate
        datePickerView.maximumDate = maximumDate
        
        if let userInfo = UserDataContainer.shared.userInfo {
            if let birthDay = userInfo.birthDay {
                let formatter = DateFormatter.humanReadableFormat
                if let date = formatter.date(from: birthDay) {
                    // set default selected date, to current user birthday
                    datePickerView.date = date
                }
            }
        }
        return datePickerView
    }()
    
    fileprivate lazy var deleteProfilePopupScreen: ConfirmDeleteProfilePopupScreen = {
        let popup = Bundle.main.loadNibNamed(
            String(describing: ConfirmDeleteProfilePopupScreen.self),
            owner: self,
            options: nil
            )?.first as! ConfirmDeleteProfilePopupScreen
        return popup
    }()
    
    //MARK: - lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addListenersForKeyboard()
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
    
    deinit {
        self.removeListenersForKeyboard()
    }
    
    //MARK: - resign first responder
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func onScrollViewTapGuesture(_ sender: UITapGestureRecognizer) {
        self.scrollView.endEditing(true)
    }
}

//MARK: - apply theme and appearance

extension EditUserProfileScreenViewController {
    
    fileprivate func setup() {
        
        header.delegate = self
        uploadAvatarButton.delegate = self
        
        self.addListenersForKeyboard()
        
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        passwordTextField.delegate = self
        cityCountryTextField.delegate = self
        zipCodeTextField.delegate = self
        birthDateTextField.delegate = self
        
        header.updateTitle("profile_hdl_my_profile".localized())
        
        let themeManager = ThemeManager.shared
        
        let updateButtonTitle = "txt_update".localized()
        updateButton.setTitle(updateButtonTitle, for: .normal)
        themeManager.setDCBlueTheme(to: updateButton, ofType: .ButtonDefault)
        
        let deleteProfileButtonTitle = "profile_btn_delete".localized()
        deleteProfileButton.setTitle(deleteProfileButtonTitle, for: .normal)
        themeManager.setDCBlueTheme(to: deleteProfileButton, ofType: .ButtonDefaultRedGradient)
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .left
        
        themeManager.setDCBlueTheme(to: self.firstNameTextField, ofType: .TextFieldDefaut)
        let firstNamePlaceholder = NSAttributedString.init(
            string: "signup_hnt_first_name".localized(),
            attributes: [
                .foregroundColor: UIColor.white,
                .font: UIFont.dntLatoLightFont(size: UIFont.dntLabelFontSize)!,
                .paragraphStyle: paragraph
            ])
        self.firstNameTextField.attributedPlaceholder = firstNamePlaceholder
        if let firstName = UserDataContainer.shared.userInfo?.firstName {
            self.firstNameTextField.text = firstName
        }
        
        themeManager.setDCBlueTheme(to: self.lastNameTextField, ofType: .TextFieldDefaut)
        let lastNamePlaceholder = NSAttributedString.init(
            string: "signup_hnt_last_name".localized(),
            attributes: [
                .foregroundColor: UIColor.white,
                .font: UIFont.dntLatoLightFont(size: UIFont.dntLabelFontSize)!,
                .paragraphStyle: paragraph
            ])
        self.lastNameTextField.attributedPlaceholder = lastNamePlaceholder
        if let lastName = UserDataContainer.shared.userInfo?.lastName {
            self.lastNameTextField.text = lastName
        }
        
        themeManager.setDCBlueTheme(to: self.passwordTextField, ofType: .TextFieldDefaut)
        let passwordPlaceholder = NSAttributedString.init(
            string: "signup_hnt_password".localized(),
            attributes: [
                .foregroundColor: UIColor.white,
                .font: UIFont.dntLatoLightFont(size: UIFont.dntLabelFontSize)!,
                .paragraphStyle: paragraph
            ])
        self.passwordTextField.attributedPlaceholder = passwordPlaceholder
        self.passwordTextField.isSecureTextEntry = true
        
        themeManager.setDCBlueTheme(to: self.zipCodeTextField, ofType: .TextFieldDefaut)
        let zipPlaceholder = NSAttributedString.init(
            string: "profile_hnt_zip".localized(),
            attributes: [
                .foregroundColor: UIColor.white,
                .font: UIFont.dntLatoLightFont(size: UIFont.dntLabelFontSize)!,
                .paragraphStyle: paragraph
            ])
        self.zipCodeTextField.attributedPlaceholder = zipPlaceholder
        if let zip = UserDataContainer.shared.userInfo?.postalCode {
            self.zipCodeTextField.text = zip
        }
        
        themeManager.setDCBlueTheme(to: self.cityCountryTextField, ofType: .TextFieldDefaut)
        let cityCountryPlaceholder = NSAttributedString.init(
            string: "profile_hnt_city_country".localized(),
            attributes: [
                .foregroundColor: UIColor.white,
                .font: UIFont.dntLatoLightFont(size: UIFont.dntLabelFontSize)!,
                .paragraphStyle: paragraph
            ])
        self.cityCountryTextField.attributedPlaceholder = cityCountryPlaceholder
        if let city = UserDataContainer.shared.userInfo?.city, let country = UserDataContainer.shared.userInfo?.country {
            self.cityCountryTextField.text = city + ", " +  NSLocale.countryNameFromLocaleCode(localeCode: country)
        }
        
        themeManager.setDCBlueTheme(to: self.birthDateTextField, ofType: .TextFieldDefaut)
        let birthDatePlaceholder = NSAttributedString.init(
            string: "profile_hnt_birthday".localized(),
            attributes: [
                .foregroundColor: UIColor.white,
                .font: UIFont.dntLatoLightFont(size: UIFont.dntLabelFontSize)!,
                .paragraphStyle: paragraph
            ])
        self.birthDateTextField.attributedPlaceholder = birthDatePlaceholder
        self.birthDateTextField.inputView = datePickerView
        self.datePickerView.addTarget(self, action: Selector.datePickerValueChanged, for: .valueChanged)
        if let date = UserDataContainer.shared.userInfo?.birthDay {
            birthDateTextField.text = date
        }
        
        if let gender = UserDataContainer.shared.userInfo?.gender {
            self.genderType = gender
        }
        
        let maleButtonLabel = "gender_male".localized()
        themeManager.setDCBlueTheme(
            to: maleButton,
            ofType: .ButtonOptionStyle(label: maleButtonLabel, selected: self.genderType == .male ? true : false)
        )
        let femaleButtonLabel = "gender_female".localized()
        themeManager.setDCBlueTheme(
            to: femaleButton,
            ofType: .ButtonOptionStyle(label: femaleButtonLabel, selected: self.genderType == .female ? true : false)
        )
        if let image = UserDataContainer.shared.userAvatar {
            self.cancelIconImage.isHidden = false
            self.uploadAvatarButton.setPlaceholderImage(image)
        } else {
            self.cancelIconImage.isHidden = true
        }
        
    }
    
    fileprivate func showLoadingScreenState() {
        uiIsBlocked = true
        let loadingState = State(.loadingState, "txt_loading".localized())
        self.showState(loadingState)
    }
    
    fileprivate func clearState() {
        uiIsBlocked = false
        let noneState = State(.none)
        self.showState(noneState)
    }
    
    @objc fileprivate func datePickerValueChanged(_ sender: UIDatePicker) {
        birthDateTextField.text = DateFormatter.humanReadableFormat.string(from: sender.date)
    }
    
}

//MARK: - IBActions

extension EditUserProfileScreenViewController {
    
    @IBAction func maleButtonPressed(_ sender: UIButton) {
        if uiIsBlocked == true { return }
        genderOptionSelected = true
        genderType = GenderType.male
        let themeManager = ThemeManager.shared
        themeManager.setDCBlueTheme(to: maleButton, ofType: .ButtonOptionStyle(label: "gender_male".localized(), selected: true))
        themeManager.setDCBlueTheme(to: femaleButton, ofType: .ButtonOptionStyle(label: "gender_female".localized(), selected: false))
    }
    
    @IBAction func femaleButtonPressed(_ sender: UIButton) {
        if uiIsBlocked == true { return }
        genderOptionSelected = true
        genderType = GenderType.female
        let themeManager = ThemeManager.shared
        themeManager.setDCBlueTheme(to: maleButton, ofType: .ButtonOptionStyle(label: "gender_male".localized(), selected: false))
        themeManager.setDCBlueTheme(to: femaleButton, ofType: .ButtonOptionStyle(label: "gender_female".localized(), selected: true))
    }
    
    @IBAction func updateButtonPressed(_ sender: UIButton) {
        if uiIsBlocked == true { return }
        uiIsBlocked = true
        
        var updateUserRequestData = UpdateUserRequestData()
        
        var city: String?
        var countryCode: String?
        if let cityCountry = cityCountryTextField.text {
            if cityCountry != "" {
                let array = cityCountry.components(separatedBy: ", ")
                city = array[0]
                updateUserRequestData.city = city
                if array.count > 1 {
                    let countryName = array[1]
                    countryCode = NSLocale.localeForCountry(countryName)
                    updateUserRequestData.country = countryCode
                }
            }
        }
        
        var avatarData: String?
        if newAvatarUploaded == true, let avatar = newAvatar {
            avatarData = avatar.toBase64()
            updateUserRequestData.avatarBase64 = avatarData
        }
        
        var birthDateInputISO8601: String?
        if let birthDayString = birthDateTextField.text {
            if let birthDateUserInput = DateFormatter.humanReadableFormat.date(from: birthDayString) {
                birthDateInputISO8601 = birthDateUserInput.iso8601
                updateUserRequestData.birthDay = birthDateInputISO8601
            }
        }
        
        if let firstName = self.firstNameTextField.text, SystemMethods.User.validateFirstName(firstName) {
            updateUserRequestData.firstName = firstName
        }
        
        if let lastName = self.lastNameTextField.text, SystemMethods.User.validateLastName(lastName) {
            updateUserRequestData.lastName = lastName
        }
        
        if let zip = self.zipCodeTextField.text, SystemMethods.User.validateZipCode(zip) {
            updateUserRequestData.postalCode = zip
        }
        
        if let pass = passwordTextField.text, SystemMethods.User.validatePassword(pass) {
            updateUserRequestData.password = pass
        }
        
        if genderType != .unspecified {
            updateUserRequestData.gender = genderType
        }
        
        showLoadingScreenState()
        
        APIProvider.updateUser(updateUserRequestData) { [weak self] response, error in
            if let error = error {
                print("Update User Request: Error \(error)")
                
                UIAlertController.show(
                    controllerWithTitle: "error_popup_title".localized(),
                    message: error.toNSError().localizedDescription,
                    buttonTitle: "txt_ok".localized()
                )
                
                self?.clearState()
                return
            }
            if let userData = response {
                UserDataContainer.shared.userInfo = userData
                UserDataContainer.shared.userAvatar = self?.newAvatar
            }
            self?.clearState()
            self?.backButtonIsPressed()
        }
    }
    
    @IBAction func deleteUserProfileButtonPressed(_ sender: UIButton) {
        if uiIsBlocked == true { return }
        uiIsBlocked = true
        
        let popup = self.deleteProfilePopupScreen
        let frame = UIScreen.main.bounds
        popup.frame = frame
        self.view.addSubview(popup)
        popup.delegate = self
        
        UIView.animate(withDuration: 0.5, animations: {
            popup.alpha = 1
        })
        
    }
    
}

//MARK: - UploadImageButtonDelegate

extension EditUserProfileScreenViewController: UploadImageButtonDelegate {
    
    func showUploadOptions(_ optionsViewController: UIAlertController) {
        if uiIsBlocked == true { return }
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
        newAvatar = image
        newAvatarUploaded = true
        cancelIconImage.isHidden = false
    }
    
}

//MARK: - InsidePageHeaderViewDelegate

extension EditUserProfileScreenViewController: InsidePageHeaderViewDelegate {
    
    func backButtonIsPressed() {
        if uiIsBlocked == true { return }
        contentDelegate?.backButtonIsPressed()
    }
    
}

//MARK: - UITextFieldDelegate

extension EditUserProfileScreenViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == firstNameTextField {
            firstNameTextField.resignFirstResponder()
            lastNameTextField.becomeFirstResponder()
        } else if textField == lastNameTextField {
            lastNameTextField.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            passwordTextField.resignFirstResponder()
            zipCodeTextField.becomeFirstResponder()
        }else if textField == zipCodeTextField {
            zipCodeTextField.resignFirstResponder()
            cityCountryTextField.becomeFirstResponder()
        }else if textField == cityCountryTextField {
            cityCountryTextField.resignFirstResponder()
            birthDateTextField.becomeFirstResponder()
        } else {
            birthDateTextField.resignFirstResponder()
        }
        
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.textFieldFirstResponder = textField
        if  textField == cityCountryTextField {
            let autocompleteController = GMSAutocompleteViewController()
            autocompleteController.delegate = self
            present(autocompleteController, animated: true, completion: nil)
            textField.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        
        if textField == firstNameTextField {
            
            if let name = firstNameTextField.text, SystemMethods.User.validateFirstName(name) == true{
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
            
        } else if textField == passwordTextField {
            if let pass = passwordTextField.text, SystemMethods.User.validatePassword(pass) == true {
                passwordTextField.errorMessage = ""
            } else {
                passwordTextField.errorMessage = errorPasswordString
            }
            
        } else if textField == zipCodeTextField {
            
            if let zip = cityCountryTextField.text, SystemMethods.User.validatePassword(zip) == true {
                zipCodeTextField.errorMessage = ""
            } else {
                zipCodeTextField.errorMessage = errorZipString
            }
            
        } else if textField == cityCountryTextField {
            if let cityCountry = cityCountryTextField.text, SystemMethods.User.validatePassword(cityCountry) == true {
                cityCountryTextField.errorMessage = ""
            } else {
                cityCountryTextField.errorMessage = errorCityCountryString
            }
        }
        
        return true
        
    }
    
}

//МАРК: - GMSAutocompleteViewControllerDelegate

extension EditUserProfileScreenViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        self.cityCountryTextField.text = place.formattedAddress
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("UserEdit Screen : GMSAutocompleteViewControllerDelegate : Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        //self.cityCountryTextField.text = ""
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}

// MARK: - ConfirmDeleteProfileDelegate

extension EditUserProfileScreenViewController: ConfirmDeleteProfileDelegate {
    
    func deleteProfileConfirmed() {
        uiIsBlocked = false
        
        clearState()
        
        if let navController = self.navigationController {
            UserDataContainer.shared.logout()
            let controller: BeginScreenViewController! = UIStoryboard.main.instantiateViewController()
            navController.pushViewController(controller, animated: true)
        }
    }
    
    func deleteProfileCancaled() {
        uiIsBlocked = false
        clearState()
    }
    
}

//MARK: - selectors

fileprivate extension Selector {
    static let datePickerValueChanged = #selector(EditUserProfileScreenViewController.datePickerValueChanged(_:))
}

//MARK: - Date Helper Methods

extension NSLocale {
    class func localeForCountry(_ countryName : String) -> String? {
        return NSLocale.isoCountryCodes.first{self.countryNameFromLocaleCode(localeCode: $0) == countryName}
    }
    
    class func countryNameFromLocaleCode(localeCode : String) -> String {
        return NSLocale(localeIdentifier: "en_UK").displayName(forKey: NSLocale.Key.countryCode, value: localeCode) ?? ""
    }
}
