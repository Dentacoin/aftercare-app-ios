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
                let paramStringPlaceholder = "%\(paramNumber)$@"//string type parameter
                if localizedString.contains(paramStringPlaceholder) {
                    localizedString = localizedString.replacingOccurrences(of: paramStringPlaceholder, with: item)
                }
                let paramIntPlaceholder = "%\(paramNumber)$d"// Int type  parameter
                if localizedString.contains(paramIntPlaceholder) {
                    localizedString = localizedString.replacingOccurrences(of: paramIntPlaceholder, with: item)
                }
            }
        }
        
        return localizedString
    }
    
}
