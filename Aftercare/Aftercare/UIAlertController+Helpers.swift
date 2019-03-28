//
//  UIAlertController+Helpers.swift
//  Throwing Fruit
//
//  Created by Dimitar Grudev on 1/26/17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import UIKit

typealias AlertDismissHandler = () -> ()

extension UIAlertController {
    
    static func show(message: String) {
        let controller = show(title: nil, message: message, buttonTitle: "txt_ok".localized(), handler: nil)
        controller.show()
    }
    
    static func show(controllerWithTitle title: String, message: String) {
        let controller = show(title: title, message: message, buttonTitle: "txt_ok".localized(), handler: nil)
        controller.show()
    }
    
    static func show(controllerWithTitle title: String, message: String, buttonTitle: String) {
        let controller = show(title: title, message: message, buttonTitle: buttonTitle, handler: nil)
        controller.show()
    }
    
    static func show(controllerWithTitle title: String, message: String, cancelTitle: String) {
        let controller = show(title: title, message: message, cancelTitle: cancelTitle, buttonTitle: "txt_ok".localized(), nil, nil)
        controller.show()
    }
    
    static func show(title: String, message: String, handler: @escaping AlertDismissHandler) {
        let controller = show(title: title, message: message, buttonTitle: "txt_ok".localized(), handler: handler)
        controller.show()
    }
    
    @discardableResult static func show(
        title: String?,
        message: String,
        buttonTitle: String,
        handler: AlertDismissHandler? = nil
        ) -> UIAlertController {
        
        let controller = UIAlertController(title: title,
                                           message: message,
                                           preferredStyle: .alert)
        
        let actionHandler: ((UIAlertAction) -> Void) = { (action) in
            handler?()
        }
        
        let action = UIAlertAction(title: buttonTitle,
                                   style: .default,
                                   handler: actionHandler)
        
        controller.addAction(action)
        
        return controller
    }
    
    @discardableResult static func show(
        title: String?,
        message: String,
        cancelTitle: String,
        buttonTitle: String,
        _ handler: AlertDismissHandler? = nil,
        _ cancelHandler: AlertDismissHandler? = nil) -> UIAlertController {
        
        let controller = UIAlertController(title: title,
                                           message: message,
                                           preferredStyle: .alert)
        
        let cancelHandler: ((UIAlertAction) -> Void) = { (action) in
            cancelHandler?()
        }
        
        let actionCancel = UIAlertAction(title: cancelTitle,
                                         style: .default,
                                         handler: cancelHandler)
        
        let actionHandler: ((UIAlertAction) -> Void) = { (action) in
            handler?()
        }
        
        let action = UIAlertAction(title: buttonTitle,
                                   style: .default,
                                   handler: actionHandler)
        
        controller.addAction(actionCancel)
        controller.addAction(action)
        
        return controller
    }
    
}

///

import ObjectiveC

private var alertWindowAssociationKey: UInt8 = 0

extension UIAlertController {
    
    var alertWindow: UIWindow? {
        get {
            return objc_getAssociatedObject(self, &alertWindowAssociationKey) as? UIWindow
        }
        set(newValue) {
            objc_setAssociatedObject(self, &alertWindowAssociationKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    @objc public func show() {
        show(true)
    }
    
    @objc public func show(_ animated: Bool) {
        show(animated, completion: nil)
    }
    
    @objc public func show(_ animated: Bool, completion: (() -> Void)? = nil) {
        self.alertWindow = UIWindow(frame: UIScreen.main.bounds)
        self.alertWindow?.rootViewController = UIViewController()
        self.alertWindow?.windowLevel = UIWindowLevelAlert + 1
        self.alertWindow?.makeKeyAndVisible()
        self.alertWindow?.rootViewController?.present(self,
                                                      animated: animated,
                                                      completion: completion)
    }
    
    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.alertWindow?.isHidden = true
        self.alertWindow = nil
    }
    
}
