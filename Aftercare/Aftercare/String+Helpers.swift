//
// Aftercare
// Created by Dimitar Grudev on 20.04.18.
// Copyright © 2018 Stichting Administratiekantoor Dentacoin.
//

import Foundation

extension String {
    
    func localized() -> String {
        return NSLocalizedString(self, comment: "")
    }
    
    func localized(_ params: String...) -> String {
        
        var localizedString = NSLocalizedString(self, comment: "")
        
        if params.count > 0 {
            var paramNumber = 0
            for item in params {
                paramNumber += 1
                let paramPlaceholder = "%\(paramNumber)$@"
                localizedString = localizedString.replacingOccurrences(of: paramPlaceholder, with: item)
            }
        }
        
        return localizedString
    }
    
}
