//
// Aftercare
// Created by Dimitar Grudev on 22.03.18.
// Copyright © 2018 Stichting Administratiekantoor Dentacoin.
//

import Foundation

struct SpotlightModels {
    
    // MARK: - Spotlight models
    
    typealias SpotlightModel = (id: SpotlightID, label: String, shape: AwesomeSpotlightShape)
    
    static var actionScreen: [SpotlightModel] {
        get {
            let spotlights = [
                SpotlightModel(
                    id: .totalDCN,
                    label: NSLocalizedString("This is the total amount of DCN you've earned.", comment: ""),
                    shape: .circle
                ),
                SpotlightModel(
                    id: .lastRecordTime,
                    label: NSLocalizedString("Last recorded time", comment: ""),
                    shape: .circle
                ),
                SpotlightModel(
                    id: .remainActivities,
                    label: NSLocalizedString("Remaining activities for today", comment: ""),
                    shape: .circle
                ),
                SpotlightModel(
                    id: .earnedDCN,
                    label: NSLocalizedString("Earned DCN from this activity", comment: ""),
                    shape: .circle
                ),
                SpotlightModel(
                    id: .openStatistics,
                    label: NSLocalizedString("Tap to open statistics", comment: ""),
                    shape: .circle
                )
            ]
            return spotlights
        }
    }
    
    static var sideMenu: [SpotlightModel] {
        get {
            let spotlights = [
                SpotlightModel(
                    id: .editProfile,
                    label: NSLocalizedString("Click here to edit your profile!", comment: ""),
                    shape: .circle
                ),
                SpotlightModel(
                    id: .sendDCN,
                    label: NSLocalizedString("Send DCN to your wallet!", comment: ""),
                    shape: .circle
                ),
                SpotlightModel(
                    id: .achieveGoalsAndEarn,
                    label: NSLocalizedString("Achieve goals & earn DCN", comment: ""),
                    shape: .circle
                ),
                SpotlightModel(
                    id: .sendEmergency,
                    label: NSLocalizedString("Send us emergency request", comment: ""),
                    shape: .circle
                )
            ]
            return spotlights
        }
    }
    
}

enum SpotlightID: String, RawRepresentable {
    case totalDCN
    case lastRecordTime
    case remainActivities
    case earnedDCN
    case openStatistics
    case sendDCN
    case achieveGoalsAndEarn
    case sendEmergency
    case editProfile
}
