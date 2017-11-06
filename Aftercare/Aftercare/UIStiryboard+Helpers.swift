//
//  UIStiryboard+Helpers.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 8/4/17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import Foundation
import UIKit

extension UIStoryboard {
    func instantiateViewController<T: UIViewController>() -> T? {
        return instantiateViewController(withIdentifier: T.storyboardIdentifier) as? T
    }
    func instantiateViewControllerWith(id viewControllerID: String) -> UIViewController? {
        return instantiateViewController(withIdentifier: viewControllerID)
    }
}

extension UIStoryboard {
    class var main: UIStoryboard {
        return UIStoryboard(name: "Main", bundle: nil)
    }
    
    class var login: UIStoryboard {
        return UIStoryboard(name: "Login", bundle: nil)
    }
}
