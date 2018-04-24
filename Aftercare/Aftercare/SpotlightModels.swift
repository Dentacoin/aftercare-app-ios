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
                    label: "tutorial_txt_total_dcn".localized(),
                    shape: .circle
                ),
                SpotlightModel(
                    id: .lastRecordTime,
                    label: "tutorial_txt_last_activity_time".localized(),
                    shape: .circle
                ),
                SpotlightModel(
                    id: .remainActivities,
                    label: "tutorial_txt_left_activities_count".localized(),
                    shape: .circle
                ),
                SpotlightModel(
                    id: .earnedDCN,
                    label: "tutorial_txt_earned_dcn".localized(),
                    shape: .circle
                ),
                SpotlightModel(
                    id: .openStatistics,
                    label: "tutorial_txt_dashboard_arrow_2".localized(),
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
                    label: "tutorial_txt_click_edit_profile".localized(),
                    shape: .circle
                ),
                SpotlightModel(
                    id: .sendDCN,
                    label: "tutorial_txt_collect_dcn".localized(),
                    shape: .circle
                ),
                SpotlightModel(
                    id: .achieveGoalsAndEarn,
                    label: "tutorial_txt_goals_menu".localized(),
                    shape: .circle
                ),
                SpotlightModel(
                    id: .sendEmergency,
                    label: "tutorial_txt_emergency_menu".localized(),
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
