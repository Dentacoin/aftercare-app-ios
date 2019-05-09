//
// Aftercare
// Created by Dimitar Grudev on 25.02.18.
// Copyright © 2018 Stichting Administratiekantoor Dentacoin.
//

import Foundation

struct DeleteUserRequest: Encodable {
    
    var captchaCode = ""
    var captchaId: Int
    
}
