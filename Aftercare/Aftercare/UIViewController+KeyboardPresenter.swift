//
//  UIViewController+KeyboardPresenter.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 27.10.17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import Foundation
import UIKit

private var textFieldFirstResponderKey: UInt8 = 0
private var textViewFirstResponderKey: UInt8 = 0

extension UIViewController {
    
    var textFieldFirstResponder: UIView? {
        get { return objc_getAssociatedObject(self, &textFieldFirstResponderKey) as? UIView }
        set { objc_setAssociatedObject(self, &textFieldFirstResponderKey, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }
    
    var textViewFirstResponder: UIView? {
        get { return objc_getAssociatedObject(self, &textViewFirstResponderKey) as? UIView }
        set { objc_setAssociatedObject(self, &textViewFirstResponderKey, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }
    
    func addListenersForKeyboard() {
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        
    }
    
    func removeListenersForKeyboard() {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Keyboard Over Content
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            var textContainerPosition: CGPoint?
            var textFrame: CGRect?
            
            if let textView = self.textViewFirstResponder {
                textContainerPosition = textView.convert(CGPoint(x: 0, y: 0), to: self.view)
                textFrame = textView.bounds
            }
            
            if let textField = self.textFieldFirstResponder {
                textContainerPosition = textField.convert(CGPoint(x: 0, y: 0), to: self.view)
                textFrame = textField.bounds
            }
            
            guard let position = textContainerPosition else { return }
            guard let frame = textFrame else { return }
            
            let gapBetweenTextAndKeyboard: CGFloat = 16
            let screenSize = UIScreen.main.bounds
            let keyboardPossition = CGPoint(x: 0, y: screenSize.size.height - keyboardSize.height)
            let textBottom = position.y + frame.size.height + gapBetweenTextAndKeyboard
            if textBottom > keyboardPossition.y {
                self.view.frame.origin.y = -(textBottom - keyboardPossition.y)
            }
            
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
        self.textFieldFirstResponder = nil
    }
}
