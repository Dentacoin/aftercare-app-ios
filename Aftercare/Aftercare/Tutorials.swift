//
// Aftercare
// Created by Dimitar Grudev on 07.02.18.
// Copyright © 2018 Stichting Administratiekantoor Dentacoin.
//

import Foundation

struct Tutorials {
    
    typealias Tutorial = (title: String, description: String, image: String)
    
    fileprivate static var tutorials: [Tutorial] = [
        (
            title: "onboarding_txt_title_1".localized(),
            description: "onboarding_txt_message_1".localized(),
            image: "onboarding_1"
        ),
        (
            title: "onboarding_txt_title_2".localized(),
            description: "onboarding_txt_message_2_dp".localized(),
            image: "onboarding_2"
        ),
        (
            title: "onboarding_txt_title_3".localized(),
            description: "onboarding_txt_message_3_dp".localized(),
            image: "onboarding_3"
        ),
        (
            title: "onboarding_txt_title_4".localized(),
            description: "onboarding_txt_message_4_dp".localized(),
            image: "onboarding_4"
        ),
        (
            title: "onboarding_txt_title_5".localized(),
            description: "onboarding_txt_message_5_dp".localized(),
            image: "onboarding_5"
        ),
        (
            title: "onboarding_txt_title_6".localized(),
            description: "onboarding_txt_message_6".localized(),
            image: "onboarding_6"
        )
    ]
    
    static func getTutorialsModel() -> [Tutorial] {
        return tutorials
    }
    
    static let nextButtonLabel = "onboarding_txt_next".localized()
    static let lastButtonLabel = "onboarding_txt_got_it".localized()
    
}
