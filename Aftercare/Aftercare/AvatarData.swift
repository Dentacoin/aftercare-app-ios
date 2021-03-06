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
    
    fileprivate var userAvatarID: Int
    fileprivate var userAvatarLowQualityURL: String
    fileprivate var userAvatar1xURL: String
    fileprivate var userAvatar2xURL: String
    fileprivate var userAvatar3xURL: String
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: AvatarDataKeys.self)
        self.userAvatarID = try values.decode(Int.self, forKey: .avatarID)
        self.userAvatarLowQualityURL = try values.decode(String.self, forKey: .avatarLowQuality)
        self.userAvatar1xURL = try values.decode(String.self, forKey: .avatar1x)
        self.userAvatar2xURL = try values.decode(String.self, forKey: .avatar2x)
        self.userAvatar3xURL = try values.decode(String.self, forKey: .avatar3x)
    }
    
    var avatarID: Int? {
        get {
            return self.userAvatarID
        }
    }
    
    var prefferedAvatarURL: String? {
        get {
            let scale = UIScreen.main.scale
            switch scale {
                case 1:
                    return self.userAvatar1xURL
                case 2:
                    return self.userAvatar2xURL
                case 3:
                    return self.userAvatar3xURL
                default:
                    return self.userAvatar3xURL
            }
        }
    }
    
    fileprivate enum AvatarDataKeys: String, CodingKey {
        case avatarID = "avatar_id"
        case avatarLowQuality = "ldpi_link"
        case avatar1x = "mdpi_link"
        case avatar2x = "hdpi_link"
        case avatar3x = "xhdpi_link"
    }
    
}
