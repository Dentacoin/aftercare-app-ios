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
            title: "Start your journey",
            description: "Start your journey toward\na beautiful smile!",
            image: "onboarding_1"
        ),
        (
            title: "Journeys",
            description: "Complete 90 days of consecutive\nuse, or 180 routines altogether\nand collect your DCN reward!",
            image: "onboarding_2"
        ),
        (
            title: "Routines",
            description: "Complete your morning and\nevening routines and earn\nDCN daily!",
            image: "onboarding_3"
        ),
        (
            title: "Watch your earnings",
            description: "Here you'll see your current DCN Balance.\nWatch it grow each time you\ncomplete a routine!",
            image: "onboarding_4"
        ),
        (
            title: "Complete achievements!",
            description: "Try completing different\nachievements and earn even\nmore DCN!",
            image: "onboarding_5"
        ),
        (
            title: "Withdraw",
            description: "Collect your earnings!\nOnce you've completed your\n90 days cycle!",
            image: "onboarding_6"
        )
    ]
    
    static func getTutorialsModel() -> [Tutorial] {
        return tutorials
    }
    
    static let nextButtonLabel = NSLocalizedString("Next", comment: "")
    static let lastButtonLabel = NSLocalizedString("I Got it!", comment: "")
    
}
