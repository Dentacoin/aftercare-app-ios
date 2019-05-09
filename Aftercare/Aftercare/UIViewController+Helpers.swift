//
//  UIViewController+Helpers.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 8/4/17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import UIKit

extension UIViewController {
    class var storyboardIdentifier: String {
        let result = String(describing: self)
        return result
    }
}
