//
//  Theme.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 8/2/17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import Foundation
import UIKit
import EasyTipView

// Color palette

extension UIColor {
    
    @nonobjc class var dntTutorialDarkBlue: UIColor {
        return UIColor(red: 63.0 / 255.0, green: 139.0 / 255.0, blue: 229.0 / 255.0, alpha: 1.0)
    }
    
    @nonobjc class var dntTutorialLightBlue: UIColor {
        return UIColor(red: 104.0 / 255.0, green: 224.0 / 255.0, blue: 236.0 / 255.0, alpha: 1.0)
    }
    
    @nonobjc class var dntBrightSkyBlue: UIColor {
        return UIColor(red: 10.0 / 255.0, green: 201.0 / 255.0, blue: 252.0 / 255.0, alpha: 1.0)
    }
    
    @nonobjc class var dntCeruleanBlue: UIColor {
        return UIColor(red: 10.0 / 255.0, green: 93.0 / 255.0, blue: 241.0 / 255.0, alpha: 1.0)
    }
    
    @nonobjc class var dntIceBlue: UIColor {
        return UIColor(red: 251.0 / 255.0, green: 253.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
    }
    
    @nonobjc class var dntPaleSkyBlue: UIColor {
        return UIColor(red: 201.0 / 255.0, green: 235.0 / 255.0, blue: 252.0 / 255.0, alpha: 1.0)
    }
    
    @nonobjc class var dntCharcoalGrey: UIColor {
        return UIColor(red: 42.0 / 255.0, green: 42.0 / 255.0, blue: 50.0 / 255.0, alpha: 1.0)
    }
    
    @nonobjc class var dntDark: UIColor {
        return UIColor(red: 29.0 / 255.0, green: 29.0 / 255.0, blue: 38.0 / 255.0, alpha: 1.0)
    }
    
    @nonobjc class var dntWarmGrey: UIColor {
        return UIColor(white: 134.0 / 255.0, alpha: 1.0)
    }
    
    @nonobjc class var dntDarkSkyBlue: UIColor {
        return UIColor(red: 74.0 / 255.0, green: 144.0 / 255.0, blue: 226.0 / 255.0, alpha: 1.0)
    }
    
    @nonobjc class var dntLightRed: UIColor {
        return UIColor(red: 255.0 / 255.0, green: 64.0 / 255.0, blue: 129.0 / 255.0, alpha: 1.0)
    }
    
    @nonobjc class var dntDarkRed: UIColor {
        return UIColor(red: 237.0 / 255.0, green: 34.0 / 255.0, blue: 36.0 / 255.0, alpha: 1.0)
    }
    
    @nonobjc class var dntDarkGreen: UIColor {
        return UIColor(red: 87.0 / 255.0, green: 189.0 / 255.0, blue: 68.0 / 255.0, alpha: 1.0)
    }
}

//MARK - Image IDs

struct ImageIDs {
    static let uploadAvatarIcon = "uploadUserAvatar"
    static let facebookIcon = "fb"
    static let facebookHighlightedIcon = "fb-highlighted"
    static let twitterIcon = "twitter"
    static let twitterHighlightedIcon = "twitter-highlighted"
    static let googlePlusIcon = "googlePlus"
    static let googlePlusHighlightedIcon = "googlePlus-highlighted"
    static let achievedGoalIcon = "achievedGoalIcon"
    static let unachievedGoalIcon = "unachievedGoalIcon"
    static let achievedGoalsPopup = "achievedGoalsPopup"
    static let unachievedGoalsPopup = "unachievedGoalsPopup"
    static let goalBackground = "goals-background"
}

//MARK - UIFonts

extension UIFont {
    
    static let dntTitleFontSize: CGFloat = 32
    static let dntLargeTitleFontSize: CGFloat = 24
    static let dntHeaderTitleFontSize: CGFloat = 22
    static let dntButtonFontSize: CGFloat = 20
    static let dntLargeTextSize: CGFloat = 18
    static let dntNormalTextSize: CGFloat = 16
    static let dntLabelFontSize: CGFloat = 15
    static let dntMainMenuLabelFontSize: CGFloat = 14
    static let dntSmallLabelFontSize: CGFloat = 13
    static let dntNoteFontSize: CGFloat = 12
    static let dntTabBarItemFontSize: CGFloat = 11
    static let dntNanoLabelSize: CGFloat = 8
    
    class func dntLatoRegularFontWith(size: CGFloat) -> UIFont? {
        return UIFont(name: "Lato-Regular", size: size)
    }
    
    class func dntLatoLightFont(size: CGFloat) -> UIFont? {
        return UIFont(name: "Lato-Light", size: size)
    }
    
    class func dntLatoBlackFont(size: CGFloat) -> UIFont? {
        return UIFont(name: "Lato-Black", size: size)
    }
    
}

//MARK - Components themes defined

enum DCBlueThemeTypes {
    case ButtonDefault
    case ButtonDefaultWith(size: CGSize)
    case ButtonDefaultWhite
    case ButtonDefaultWhiteWith(size: CGSize)
    case ButtonDefaultBlueGradient
    case ButtonDefaultRedGradient
    case ButtonLink(fontSize: CGFloat)
    case ButtonLinkWithColor(fontSize: CGFloat, color: UIColor)
    case ButtonMainMenu
    case ButtonTabStyle(label: String)
    case ButtonTabSelectedStyle(label: String)
    case ButtonOptionStyle(label: String, selected: Bool)
    case ButtonActionStyle(label: String, selected: Bool)
    case ButtonSocialNetworkWith(logoNormal: UIImage, logoHighlighted: UIImage)
    case ButtonTooth(color: UIColor, selected: Bool)
    case TextFieldDefaut
    case TextFieldDarkBlue
    case TabBarDefault
}

//MARK: - Component Theme Definitions
class ThemeManager {
    
    //MARK: - Singleton
    
    static let shared = ThemeManager()
    private init() {
        setupEasyTipViewAppearance()
    }
    
    typealias Component = UIView
    
    fileprivate var component: Component?
    
    open lazy var tutorialBackgroundTexture: UIImage = {
        return createImageWithGradient(
            CGRect(x: 0, y: 0, width: 100, height: 100),
            (start: UIColor.dntTutorialLightBlue.cgColor, end: UIColor.dntTutorialDarkBlue.cgColor),
            (start: CGPoint(x: 0.0, y: 0.0), end: CGPoint(x: 0.0, y: 1.0))
        )
    }()
    
    open var tooltipPreferences: EasyTipView.Preferences {
        get {
            var preferences = EasyTipView.Preferences()
            preferences.drawing.font = UIFont.dntLatoLightFont(size: 13)!
            preferences.drawing.foregroundColor = .white
            preferences.drawing.backgroundColor = UIColor.dntLightRed
            preferences.drawing.arrowPosition = .top
            
            return preferences
        }
    }
    
    func setupEasyTipViewAppearance() {
        
        //Setup EasyTipView global appearance
        EasyTipView.globalPreferences = tooltipPreferences
    }
    
    func setDCBlueTheme(to component: UIView, ofType type: DCBlueThemeTypes) {
        
        //Determin the component type
        
        self.component = component
        
        switch component {
            case is UIButton:
                self.styleButton(component as! UIButton, type: type)
            case is SkyFloatingLabelTextField:
                self.styleSFLTextField(component as! SkyFloatingLabelTextField, type: type)
            case is UITabBar:
                self.styleTabBar(component as! UITabBar, type: type)
            default:
                print("Unsupported component by the Theme Manager")
        }
        
    }
    
    //MARK: - UIButton Style Methods
    
    fileprivate func styleButton(_ button: UIButton, type: DCBlueThemeTypes) {
        
        //Make sure that the button that we want to customize is from type Custom
        if button.buttonType != .custom {
            print("Error: Trying to apply custom style to \(button.buttonType) type of a Button")
            return
        }
        
        switch type {
        case .ButtonDefaultWith(let size):
            applyDefaultButtonStyle(button: button, width: size.width, height: size.height)
            return
        case .ButtonDefault:
            applyDefaultButtonStyle(button: button, width: 280, height: 50)
            return
        case .ButtonDefaultWhite:
            applyDefaultWhiteButtonStyle(button: button, width: 280, height: 50)
            return
        case .ButtonDefaultWhiteWith(let size):
            applyDefaultWhiteButtonStyle(button: button, width: size.width, height: size.height)
            return
        case .ButtonDefaultBlueGradient:
            applyDefaultBlueGradient(button: button, width: button.frame.size.width, height: button.frame.size.height)
            return
        case .ButtonDefaultRedGradient:
            applyDefaultRedGradient(button: button, width: button.frame.size.width, height: button.frame.size.height)
            return
        case .ButtonLink(let size):
            applyLinkButtonStyle(button: button, fontSize: size)
            return
        case .ButtonLinkWithColor(let size, let color):
            applyLinkButtonStyle(button: button, fontSize: size, color: color)
            return
        case .ButtonMainMenu:
            applyMainMenuButtonStyle(button: button)
            return
        case .ButtonTabStyle(let label):
            applyButtonTabStyle(button: button, label: label)
            return
        case .ButtonTabSelectedStyle(let label):
            applyButtonTabStyle(button: button, label: label, selectedState: true)
            return
        case .ButtonOptionStyle(let label, let selected):
            applyButtonOptionStyle(button: button, label, selected)
            return
        case .ButtonActionStyle(let label, let selected):
            applyButtonActionStyle(button: button, label, selected)
            return
        case .ButtonSocialNetworkWith(let logoNormal, let logoHighlighted):
            applySocialNetworkButton(button: button, logoNormal: logoNormal, logoHighlighted: logoHighlighted)
            return
        case .ButtonTooth(let color, let selected):
            applyToothButton(button: button, color: color, selected)
            return
        default:
            return
        }
    }
    
    fileprivate func applyDefaultButtonStyle(button: UIButton, width: CGFloat, height: CGFloat) {
        
        //common settings
        button.layer.cornerRadius = height / 2
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1 / UIScreen.main.scale
        button.layer.masksToBounds = true
        
        button.titleLabel?.font = UIFont.dntLatoRegularFontWith(size: UIFont.dntButtonFontSize)
        
        //normal state settings
        button.setTitleColor(.white, for: .normal)
        
        //highlighted state settings
        button.setTitleColor(.dntCeruleanBlue, for: .highlighted)
        
        //let normalImage = createImageWithColor(button.frame, UIColor.dntCeruleanBlue.cgColor)
        
        let focusedImage = createImageWithGradient(
            CGRect(x: 0, y: 0, width: width, height: height),
            (start: UIColor.dntIceBlue.cgColor, end: UIColor.dntPaleSkyBlue.cgColor),
            (start: CGPoint(x: 0.0, y: 0.5), end: CGPoint(x: 1.0, y: 0.5))
        )
        
        //button.setBackgroundImage(normalImage, for: .normal)
        button.setBackgroundImage(focusedImage, for: .highlighted)
    }
    
    fileprivate func applyDefaultWhiteButtonStyle(button: UIButton, width: CGFloat, height: CGFloat) {
        
        //common settings
        button.layer.cornerRadius = height / 2
        button.layer.borderColor = UIColor.dntCeruleanBlue.cgColor
        button.layer.borderWidth = 1 / UIScreen.main.scale
        button.layer.masksToBounds = true
        
        button.titleLabel?.font = UIFont.dntLatoRegularFontWith(size: UIFont.dntButtonFontSize)
        
        //normal state settings
        button.setTitleColor(.dntCeruleanBlue, for: .normal)
        
        //highlighted state settings
        button.setTitleColor(.white, for: .highlighted)
        //button.setBackgroundImage(focusedImage!, for: .highlighted)
        
        let focusedImage = createImageWithGradient(
            CGRect(x: 0, y: 0, width: width, height: height),
            (start: UIColor.dntCeruleanBlue.cgColor, end: UIColor.dntCeruleanBlue.cgColor),
            (start: CGPoint(x: 0.0, y: 0.5), end: CGPoint(x: 1.0, y: 0.5))
        )
        button.setBackgroundImage(focusedImage, for: .highlighted)
    }
    
    fileprivate func applyDefaultBlueGradient(button: UIButton, width: CGFloat, height: CGFloat) {
        
        //common settings
        button.layer.cornerRadius = height / 2
        button.layer.borderColor = UIColor.dntCeruleanBlue.cgColor
        button.layer.borderWidth = 1 / UIScreen.main.scale
        button.layer.masksToBounds = true
        
        button.titleLabel?.font = UIFont.dntLatoRegularFontWith(size: UIFont.dntButtonFontSize)
        
        //normal state settings
        button.setTitleColor(.white, for: .normal)
        
        //highlighted state settings
        button.setTitleColor(.dntCeruleanBlue, for: .highlighted)
        
        let normalImage = createImageWithGradient(
            CGRect(x: 0, y: 0, width: width, height: height),
            (start: UIColor.dntCeruleanBlue.cgColor, end: UIColor.dntBrightSkyBlue.cgColor),
            (start: CGPoint(x: 0.0, y: 0.5), end: CGPoint(x: 1.0, y: 0.5))
        )
        
        let focusedImage = createImageWithColor(
            button.frame,
            UIColor.black.withAlphaComponent(0.0).cgColor
        )
        
        button.setBackgroundImage(normalImage, for: .normal)
        button.setBackgroundImage(focusedImage, for: .highlighted)
        
    }
    
    //TODO: refactor this and use the applyGradientButton to create buttons with different gradient colors
    fileprivate func applyDefaultRedGradient(button: UIButton, width: CGFloat, height: CGFloat) {
        
        //common settings
        button.layer.borderColor = UIColor.clear.cgColor
        button.layer.cornerRadius = height / 2
        button.layer.masksToBounds = true
        
        button.titleLabel?.font = UIFont.dntLatoRegularFontWith(size: UIFont.dntButtonFontSize)
        
        //normal state settings
        button.setTitleColor(.white, for: .normal)
        
        //highlighted state settings
        button.setTitleColor(.white, for: .highlighted)
        
        let normalImage = createImageWithGradient(
            CGRect(x: 0, y: 0, width: width, height: height),
            (start: UIColor.dntLightRed.cgColor, end: UIColor.dntDarkRed.cgColor),
            (start: CGPoint(x: 0.0, y: 0.5), end: CGPoint(x: 1.0, y: 0.5))
        )
        
        var focusedImage = createImageWithGradient(
            CGRect(x: 0, y: 0, width: width, height: height),
            (start: UIColor.dntLightRed.cgColor, end: UIColor.dntDarkRed.cgColor),
            (start: CGPoint(x: 0.0, y: 0.5), end: CGPoint(x: 1.0, y: 0.5))
        )
        focusedImage = focusedImage.alpha(0.7)
        
        button.setBackgroundImage(normalImage, for: .normal)
        button.setBackgroundImage(focusedImage, for: .highlighted)
        
    }
    
    fileprivate func applyLinkButtonStyle(button: UIButton, fontSize size: CGFloat, color: UIColor = .white) {
        
        //normal state settings
        //self.titleLabel?.font = UIFont.dntLatoLightFont(size: UIFont.dntSmallLabelFontSize)
        button.setTitleColor(color, for: .normal)
        
        //highlighted state settings
        button.setTitleColor(UIColor.dntCeruleanBlue, for: .highlighted)
        
        //common settings
        button.titleLabel?.font = UIFont.dntLatoLightFont(size: size)
        
    }
    
    fileprivate func applyMainMenuButtonStyle(button: UIButton) {
        
        button.titleLabel?.text = ""
        button.setImage(createMainMenuIconImage(), for: .normal)
        button.setImage(createMainMenuIconImage(0.5), for: .highlighted)
        
    }
    
    fileprivate func applyButtonTabStyle(button: UIButton, label: String, selectedState: Bool = false) {
        
        let fontSize = UIFont.dntTabBarItemFontSize
        guard let titleFontNormal = UIFont.dntLatoRegularFontWith(size: fontSize) else {
            return
        }
        guard let titleFontSelected = UIFont.dntLatoBlackFont(size: fontSize) else {
            return
        }
        
        let titleAttributedStringNormal = NSAttributedString(
            string: label,
            attributes: [
                    NSAttributedStringKey.foregroundColor: UIColor.white,
                    NSAttributedStringKey.font: titleFontNormal
                ]
            )
        
        let titleAttributedStringSelected = NSAttributedString(
            string: label,
            attributes: [
                    NSAttributedStringKey.foregroundColor: UIColor.white,
                    NSAttributedStringKey.font: titleFontSelected
                ]
            )
        
        let buttonWidth = button.frame.width
        let buttonHeight = button.frame.height
        
        if buttonWidth <= 0 || buttonHeight <= 0 { return }
        
        if selectedState {
            button.setAttributedTitle(titleAttributedStringSelected, for: .normal)
        } else {
            button.setAttributedTitle(titleAttributedStringNormal, for: .normal)
        }
        button.setAttributedTitle(titleAttributedStringSelected, for: .highlighted)
        
        if selectedState {
            button.setBackgroundImage(createTabBarImage(
                CGSize(
                    width: buttonWidth,
                    height: buttonHeight
                ),
                true
            ), for: .normal)
        } else {
            button.setBackgroundImage(createTabBarImage(
                CGSize(
                    width: buttonWidth,
                    height: buttonHeight
                ),
                false
            ), for: .normal)
        }
        
        button.setBackgroundImage(createTabBarImage(
            CGSize(
                width: buttonWidth,
                height: buttonHeight
            ),
            true
        ), for: .highlighted)
        
    }
    
    fileprivate func applyButtonOptionStyle(button: UIButton, _ label: String, _ selected: Bool) {
        
        let fontSize = UIFont.dntSmallLabelFontSize
        
        guard let titleFont = UIFont.dntLatoRegularFontWith(size: fontSize) else {
            return
        }
        
        if selected {
            
            let titleAttributedStringNormal = NSAttributedString(
                string: label,
                attributes: [
                    NSAttributedStringKey.foregroundColor: UIColor.dntCeruleanBlue,
                    NSAttributedStringKey.font: titleFont
                ]
            )
            
            button.setAttributedTitle(titleAttributedStringNormal, for: .normal)
            button.setAttributedTitle(titleAttributedStringNormal, for: .highlighted)
            
            let stateImage = createImageWithGradient(
                button.frame,
                (start: UIColor.dntIceBlue.cgColor, end: UIColor.dntPaleSkyBlue.cgColor),
                (start: CGPoint(x: 0.0, y: 0.5), end: CGPoint(x: 1.0, y: 0.5))
            )
            
            button.setBackgroundImage(stateImage, for: .normal)
            button.setBackgroundImage(stateImage, for: .highlighted)
            
        } else {
            
            let titleAttributedStringNormal = NSAttributedString(
                string: label,
                attributes: [
                    NSAttributedStringKey.foregroundColor: UIColor.white,
                    NSAttributedStringKey.font: titleFont
                ]
            )
            
            button.setAttributedTitle(titleAttributedStringNormal, for: .normal)
            button.setAttributedTitle(titleAttributedStringNormal, for: .highlighted)
            
            let stateImage = createImageWithColor(
                button.frame,
                UIColor.white.withAlphaComponent(0.3).cgColor
            )
            
            button.setBackgroundImage(stateImage, for: .normal)
            button.setBackgroundImage(stateImage, for: .highlighted)
            
        }
        
    }
    
    fileprivate func applyButtonActionStyle(button: UIButton, _ label: String, _ selected: Bool) {
        
        let fontSize = UIFont.dntSmallLabelFontSize
        
        guard let titleFont = UIFont.dntLatoRegularFontWith(size: fontSize) else {
            return
        }
        let titleAttributedStringNormal = NSAttributedString(
            string: label,
            attributes: [
                NSAttributedStringKey.foregroundColor: selected ? UIColor.white : UIColor.dntCeruleanBlue,
                NSAttributedStringKey.font: titleFont
            ]
        )
        
        button.setAttributedTitle(titleAttributedStringNormal, for: .normal)
        button.setAttributedTitle(titleAttributedStringNormal, for: .highlighted)
        
        button.backgroundColor = selected ? UIColor.dntCeruleanBlue : UIColor.white
        
        
    }
    
    fileprivate func applySocialNetworkButton(button: UIButton, logoNormal: UIImage, logoHighlighted:UIImage) {
        
        //common settings
        button.layer.masksToBounds = true
        button.setTitle("", for: .normal)
        
        //normal state settings
        button.setImage(logoNormal, for: .normal)
        
        //highlited state settings
        button.setImage(logoHighlighted, for: .highlighted)
    }
    
    fileprivate func applyToothButton(button: UIButton, color: UIColor, _ selected: Bool) {
        
        let image = UIImage(named: "tooth-" + String(button.tag))
        var selectedImage = image
        
        selectedImage = selectedImage?.tint(color: color, blendMode: .destinationAtop).alpha(0.7)
        
        if selected {
            button.setBackgroundImage(selectedImage, for: .normal)
            button.setBackgroundImage(selectedImage, for: .highlighted)
        } else {
            button.setBackgroundImage(nil, for: .normal)
            button.setBackgroundImage(selectedImage, for: .highlighted)
        }
        
    }
    
    //MARK: - Style Sky Floating Label Text Field
    
    fileprivate func styleSFLTextField(_ textField: SkyFloatingLabelTextField, type: DCBlueThemeTypes) {
        
        switch type {
        case .TextFieldDefaut:
            applySFLTextFieldStyle(textField)
            return
        case .TextFieldDarkBlue:
            applySFLTextFieldDarkBlueStyle(textField)
        default:
            return
        }
    }
    
    fileprivate func applySFLTextFieldStyle(_ textField: SkyFloatingLabelTextField, _ color: UIColor = .white) {
        
        //common style settings
        textField.placeholderFont = UIFont.dntLatoLightFont(size: UIFont.dntLabelFontSize)!
        textField.placeholderColor = color
        textField.titleColor = color
        textField.selectedTitleColor = color
        textField.lineColor = color
        textField.lineHeight = 1 / UIScreen.main.scale
        textField.selectedLineColor = color
        textField.selectedLineHeight = 1 / UIScreen.main.scale
        textField.layoutSubviews()
        textField.updateColors()
        
        //override default titleFormatter to not return uppercased text
        textField.titleFormatter = { text in
            return text
        }
        
        //set color background and font
        textField.backgroundColor = .clear
        textField.font = UIFont.dntLatoLightFont(size: UIFont.dntLabelFontSize)
        textField.textColor = color
        textField.borderStyle = .none
        
        //draw botton line of the TextField
        //        let width = CGFloat(1.0 / UIScreen.main.scale)
        //        let border = CALayer()
        //        border.borderColor = UIColor.white.cgColor
        //        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: width)
        //        border.borderWidth = width
        //
        //        //add border as a child to the layer
        //        textField.layer.addSublayer(border)
    }
    
    fileprivate func applySFLTextFieldDarkBlueStyle(_ textField: SkyFloatingLabelTextField) {
        applySFLTextFieldStyle(textField, UIColor.dntCeruleanBlue)
    }
    
    fileprivate func styleTabBar(_ tabBar: UITabBar, type: DCBlueThemeTypes) {
        
        switch type {
        case .TabBarDefault:
            applyTabBarStyle(tabBar: tabBar)
            return
        default:
            return
        }
    }
    
    fileprivate func applyTabBarStyle(tabBar: UITabBar) {
        
        if let tabBarItems = tabBar.items {
            
            let itemsCount: CGFloat = CGFloat(tabBarItems.count)
            let tabBarWidth: CGFloat = tabBar.frame.width
            let tabBarHeight: CGFloat = tabBar.frame.height
            
            tabBar.tintColor = .clear
            tabBar.barTintColor = .clear
            tabBar.backgroundColor = .clear
            tabBar.backgroundImage = createTabBarImage(CGSize(width: 1, height: 1), false)
            tabBar.shadowImage = createTabBarImage(CGSize(width: 1, height: 1), false)
            
            tabBar.selectionIndicatorImage = createTabBarImage(
                CGSize(
                    width: tabBarWidth / itemsCount,
                    height: tabBarHeight
                ),
                true
            )
            
            tabBar.backgroundImage = createTabBarImage(
                CGSize(
                    width: tabBarWidth / itemsCount,
                    height: tabBarHeight
                ),
                false
            )
            
            let fontSize = UIFont.dntTabBarItemFontSize
            guard let titleFontNormal = UIFont.dntLatoRegularFontWith(size: fontSize) else {
                return
            }
            guard let titleFontSelected = UIFont.dntLatoBlackFont(size: fontSize) else {
                return
            }
            
            let titleAttributesNormal: [NSAttributedStringKey : Any] = [
                NSAttributedStringKey.foregroundColor : UIColor.white,
                NSAttributedStringKey.font : titleFontNormal
            ]
            
            let titleAttributesSelected: [NSAttributedStringKey : Any] = [
                NSAttributedStringKey.foregroundColor : UIColor.white,
                NSAttributedStringKey.font : titleFontSelected
            ]
            
            for item: UITabBarItem in tabBarItems {
                
                item.setTitleTextAttributes(titleAttributesNormal, for: .normal)
                item.setTitleTextAttributes(titleAttributesSelected, for: .highlighted)
                
                item.titlePositionAdjustment = UIOffsetMake(0, -((tabBarHeight - fontSize) / 2))
                
            }
        }
    }
    
    //MARK: - Utils
    
    fileprivate func createImageWithGradient(
        _ frame: CGRect,
        _ colors: (start: CGColor, end: CGColor),
        _ points: (start: CGPoint, end: CGPoint)
        ) -> UIImage {
        
        let layer = CAGradientLayer()
        layer.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: frame.height)
        layer.colors = [colors.start, colors.end]
        layer.startPoint = points.start
        layer.endPoint = points.end
        
        let image: UIImage?
        
        UIGraphicsBeginImageContext(layer.bounds.size)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    fileprivate func createImageWithColor(
        _ frame: CGRect,
        _ color: CGColor
        ) -> UIImage {
        
        let layer = CAGradientLayer()
        layer.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: frame.height)
        layer.backgroundColor = color
        
        let image: UIImage?
        
        UIGraphicsBeginImageContext(layer.bounds.size)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    fileprivate func createMainMenuIconImage(_ alpha: CGFloat = 1.0) -> UIImage {
        var image = UIImage()
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 25, height: 25), false, 0.0)
        
        UIColor.white.withAlphaComponent(alpha).setFill()
        UIBezierPath(rect: CGRect(x: 2, y: 1, width: 20, height: 1)).fill()
        UIBezierPath(rect: CGRect(x: 2, y: 9, width: 20, height: 1)).fill()
        UIBezierPath(rect: CGRect(x: 2, y: 17, width: 20, height: 1)).fill()
        
        image = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
        
        return image
    }
    
    fileprivate func createTabBarImage(_ size: CGSize, _ hasLine: Bool) -> UIImage {
        var image = UIImage()
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: size.width, height: size.height), false, 0.0)
        
        if hasLine {
            
            let lineThickness: CGFloat = 3
            
            UIColor.white.withAlphaComponent(0.5).setFill()
            UIBezierPath(rect: CGRect(x: 0, y: size.height - lineThickness, width: size.width, height: lineThickness)).fill()
        }
        image = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
        
        return image
    }
}
