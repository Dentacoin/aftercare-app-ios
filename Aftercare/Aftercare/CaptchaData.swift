//
// Aftercare
// Created by Dimitar Grudev on 16.02.18.
// Copyright © 2018 Stichting Administratiekantoor Dentacoin.
//

import Foundation
import UIKit

struct CaptchaData: Codable {
    
    var id: Int
    var imageBase64: String
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CaptchaDataEnum.self)
        self.id = try values.decode(Int.self, forKey: .id)
        self.imageBase64 = try values.decode(String.self, forKey: .imageBase64)
    }
    
    enum CaptchaDataEnum: String, CodingKey {
        case id = "captcha_id"
        case imageBase64 = "captcha_image"
    }
}
