//
//  AvatarData.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 2.10.17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import Foundation
import UIKit

struct AvatarData: Codable {
    
    fileprivate var userAvatarID: Int?
    fileprivate var userAvatarLowQualityURL: String?
    fileprivate var userAvatar1xURL: String?
    fileprivate var userAvatar2xURL: String?
    fileprivate var userAvatar3xURL: String?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: AvatarDataKeys.self)
        
        do {
            self.userAvatarID = try values.decode(Int?.self, forKey: .avatarID)
        } catch {
            print("Parsing Error: AvatarData :: userAvatarID property is missing!")
        }
        
        do {
            self.userAvatarLowQualityURL = try values.decode(String?.self, forKey: .avatarLoqQuality)
        } catch {
            print("Parsing Error: AvatarData :: userAvatarLowQualityURL property is missing!")
        }
        
        do {
            self.userAvatar1xURL = try values.decode(String?.self, forKey: .avatar1x)
        } catch {
            print("Parsing Error: AvatarData :: userAvatar1xURL property is missing!")
        }
        
        do {
            self.userAvatar2xURL = try values.decode(String?.self, forKey: .avatar2x)
        } catch {
            print("Parsing Error: AvatarData :: userAvatar2xURL property is missing!")
        }
        
        do {
            self.userAvatar3xURL = try values.decode(String?.self, forKey: .avatar3x)
        } catch {
            print("Parsing Error: AvatarData :: userAvatar3xURL property is missing!")
        }
    }
    
    var avatarID: Int? {
        get {
            return self.userAvatarID
        }
    }
    
    var prefferedAvatarURL: String? {
        get {
            //TODO - see if this is already fixed by the backend
//            let scale = UIScreen.main.scale
//
//            switch scale {
//            case 1:
//                return self.userAvatar1xURL
//            case 2:
//                return self.userAvatar2xURL
//            case 3:
//                return self.userAvatar3xURL
//            default:
//                return self.userAvatar3xURL
//            }
            return self.userAvatar3xURL
        }
    }
    
    fileprivate enum AvatarDataKeys: String, CodingKey {
        case avatarID = "avatar_id"
        case avatarLoqQuality = "ldpi_link"
        case avatar1x = "mdpi_link"
        case avatar2x = "hdpi_link"
        case avatar3x = "xhdpi_link"
    }
    
    /*
     "avatar": {
     "avatar_id": 3,
     "xhdpi_link": "http:\/\/staging.dentacoin.com\/uploads\/media\/user\/0001\/01\/b18a16b474bf06c7142ff562006c7b6a3844084c.png?rand=94945",
     "hdpi_link": "http:\/\/staging.dentacoin.com\/uploads\/media\/user\/0001\/01\/thumb_3_hdpi.png?rand=94945",
     "mdpi_link": "http:\/\/staging.dentacoin.com\/uploads\/media\/user\/0001\/01\/thumb_3_mdpi.png?rand=94945",
     "ldpi_link": "http:\/\/staging.dentacoin.com\/uploads\/media\/user\/0001\/01\/thumb_3_ldpi.png?rand=94945"
     }
 */
}
