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
    @IBOutlet weak var firstNameTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var lastNameTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var passwordTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var zipCodeTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var cityCountryTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var birthDateTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var maleButton: UIButton!
    @IBOutlet weak var femaleButton: UIButton!
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomContentPadding: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    
    //MARK: - Delegates
    
    var contentDelegate: ContentDelegate?
    
    //MARK: - Public
    
    var header: InsidePageHeaderView! {
        return headerView as! InsidePageHeaderView
    }
    
    //MARK: - error message lazy init strings
    
    fileprivate lazy var errorFirstNameString: String = {
        return NSLocalizedString("Wrong first name, should be 2 symbols min.", comment: "Wrong first name message")
    }()
    
    fileprivate lazy var errorLastNameString: String = {
        return NSLocalizedString("Wrong last name, should be 2 symbols min.", comment: "Wrong last name message")
    }()
    
    fileprivate lazy var errorPasswordString: String = {
        return NSLocalizedString("Password is too short.", comment: "Password is too short")
    }()
    
    fileprivate lazy var errorCityCountryString: String = {
        return NSLocalizedString("Wrong City, Country.", comment: "")
    }()
    
    fileprivate lazy var errorZipString: String = {
        return NSLocalizedString("Wrong Zip Code.", comment: "")
    }()
    
    fileprivate var genderOptionSelected = true
    fileprivate var uiIsBlocked = false
    fileprivate var newAvatarUploaded = false
    fileprivate var calculatedConstraints = false
    fileprivate var genderType: GenderType = GenderType.unspecified
    
    fileprivate let datePickerView: UIDatePicker = {
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.date
        
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
        
        return datePickerView
    }()
    
    //MARK: - lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        header.delegate = self
        uploadAvatarButton.delegate = self
        
        self.addListenersForKeyboard()
        
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        passwordTextField.delegate = self
        cityCountryTextField.delegate = self
        zipCodeTextField.delegate = self
        birthDateTextField.delegate = self
        
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
        
        header.updateTitle(NSLocalizedString("My Profile", comment: ""))
        
        let themeManager = ThemeManager.shared
        themeManager.setDCBlueTheme(to: updateButton, ofType: .ButtonDefault)
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .left
        
        themeManager.setDCBlueTheme(to: self.firstNameTextField, ofType: .TextFieldDefaut)
        let firstNamePlaceholder = NSAttributedString.init(
            string: NSLocalizedString("First Name", comment: ""),
            attributes: [
                NSAttributedStringKey.foregroundColor: UIColor.white,
                NSAttributedStringKey.font: UIFont.dntLatoLightFont(size: UIFont.dntLabelFontSize)!,
                NSAttributedStringKey.paragraphStyle: paragraph
            ])
        self.firstNameTextField.attributedPlaceholder = firstNamePlaceholder
        if let firstName = UserDataContainer.shared.userInfo?.firstName {
            self.firstNameTextField.text = firstName
        }
        
        themeManager.setDCBlueTheme(to: self.lastNameTextField, ofType: .TextFieldDefaut)
        let lastNamePlaceholder = NSAttributedString.init(
            string: NSLocalizedString("Last Name", comment: ""),
            attributes: [
                NSAttributedStringKey.foregroundColor: UIColor.white,
                NSAttributedStringKey.font: UIFont.dntLatoLightFont(size: UIFont.dntLabelFontSize)!,
                NSAttributedStringKey.paragraphStyle: paragraph
            ])
        self.lastNameTextField.attributedPlaceholder = lastNamePlaceholder
        if let lastName = UserDataContainer.shared.userInfo?.lastName {
            self.lastNameTextField.text = lastName
        }
        
        themeManager.setDCBlueTheme(to: self.passwordTextField, ofType: .TextFieldDefaut)
        let passwordPlaceholder = NSAttributedString.init(
            string: NSLocalizedString("Password", comment: ""),
            attributes: [
                NSAttributedStringKey.foregroundColor: UIColor.white,
                NSAttributedStringKey.font: UIFont.dntLatoLightFont(size: UIFont.dntLabelFontSize)!,
                NSAttributedStringKey.paragraphStyle: paragraph
            ])
        self.passwordTextField.attributedPlaceholder = passwordPlaceholder
        self.passwordTextField.isSecureTextEntry = true
        
        themeManager.setDCBlueTheme(to: self.zipCodeTextField, ofType: .TextFieldDefaut)
        let zipPlaceholder = NSAttributedString.init(
            string: NSLocalizedString("Zip Code", comment: ""),
            attributes: [
                NSAttributedStringKey.foregroundColor: UIColor.white,
                NSAttributedStringKey.font: UIFont.dntLatoLightFont(size: UIFont.dntLabelFontSize)!,
                NSAttributedStringKey.paragraphStyle: paragraph
            ])
        self.zipCodeTextField.attributedPlaceholder = zipPlaceholder
        if let zip = UserDataContainer.shared.userInfo?.postalCode {
            self.zipCodeTextField.text = zip
        }
        
        themeManager.setDCBlueTheme(to: self.cityCountryTextField, ofType: .TextFieldDefaut)
        let cityCountryPlaceholder = NSAttributedString.init(
            string: NSLocalizedString("City / Country", comment: ""),
            attributes: [
                NSAttributedStringKey.foregroundColor: UIColor.white,
                NSAttributedStringKey.font: UIFont.dntLatoLightFont(size: UIFont.dntLabelFontSize)!,
                NSAttributedStringKey.paragraphStyle: paragraph
            ])
        self.cityCountryTextField.attributedPlaceholder = cityCountryPlaceholder
        if let city = UserDataContainer.shared.userInfo?.city, let country = UserDataContainer.shared.userInfo?.country {
            self.cityCountryTextField.text = city + ", " +  NSLocale.countryNameFromLocaleCode(localeCode: country)
        }
        
        themeManager.setDCBlueTheme(to: self.birthDateTextField, ofType: .TextFieldDefaut)
        let birthDatePlaceholder = NSAttributedString.init(
            string: NSLocalizedString("Birth Date", comment: ""),
            attributes: [
                NSAttributedStringKey.foregroundColor: UIColor.white,
                NSAttributedStringKey.font: UIFont.dntLatoLightFont(size: UIFont.dntLabelFontSize)!,
                NSAttributedStringKey.paragraphStyle: paragraph
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
        
        let maleButtonLabel = NSLocalizedString("Male", comment: "")
        themeManager.setDCBlueTheme(
            to: maleButton,
            ofType: .ButtonOptionStyle(label: maleButtonLabel, selected: self.genderType == .male ? true : false)
        )
        let femaleButtonLabel = NSLocalizedString("Female", comment: "")
        themeManager.setDCBlueTheme(
            to: femaleButton,
            ofType: .ButtonOptionStyle(label: femaleButtonLabel, selected: self.genderType == .female ? true : false)
        )
        if let image = UserDataContainer.shared.userAvatar {
            self.uploadAvatarButton.setPlaceholderImage(image)
        }
        
    }
    
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
    
    @objc fileprivate func datePickerValueChanged(_ sender: UIDatePicker) {
        birthDateTextField.text = DateFormatter.humanReadableFormat.string(from: datePickerView.date)
    }
    
}

//MARK: - IBActions

extension EditUserProfileScreenViewController {
    
    @IBAction func maleButtonPressed(_ sender: UIButton) {
        if uiIsBlocked == true { return }
        genderOptionSelected = true
        genderType = GenderType.male
        let themeManager = ThemeManager.shared
        themeManager.setDCBlueTheme(to: maleButton, ofType: .ButtonOptionStyle(label: "Male", selected: true))
        themeManager.setDCBlueTheme(to: femaleButton, ofType: .ButtonOptionStyle(label: "Female", selected: false))
    }
    
    @IBAction func femaleButtonPressed(_ sender: UIButton) {
        if uiIsBlocked == true { return }
        genderOptionSelected = true
        genderType = GenderType.female
        let themeManager = ThemeManager.shared
        themeManager.setDCBlueTheme(to: maleButton, ofType: .ButtonOptionStyle(label: "Male", selected: false))
        themeManager.setDCBlueTheme(to: femaleButton, ofType: .ButtonOptionStyle(label: "Female", selected: true))
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
        if newAvatarUploaded == true, let avatar = UserDataContainer.shared.userAvatar {
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
            }
            if let userData = response {
                UserDataContainer.shared.userInfo = userData
            }
            self?.clearState()
            self?.backButtonIsPressed()
        }
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
        UserDataContainer.shared.userAvatar = image
        newAvatarUploaded = true
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
            //self.validateAndSignUp()
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
