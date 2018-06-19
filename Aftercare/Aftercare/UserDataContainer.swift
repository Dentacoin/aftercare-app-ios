//
//  UserDataContainer.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 8/30/17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import UIKit
import Disk

class UserDataContainer {
    
    //MARK: - fileprivate properties
    
    fileprivate var avatar: UIImage?
    fileprivate var emergencyScreenshot: UIImage?
    fileprivate var userData: UserData?
    
    //MARK: - Local model persistent file names
    
    fileprivate let actionScreenLocalFile = "actionData.json"
    fileprivate let userDataLocalFile = "userData.json"
    fileprivate let goalsDataLocalFile = "goalsData.json"
    fileprivate let journeyDataLocalFile = "journeyData.json"
    
    //MARK: - providers list
    
    fileprivate var providers: [UserDataProviderProtocol] = [
        EmailProvider.shared,
        FacebookProvider.shared,
        TwitterProvider.shared,
        GooglePlusProvider.shared
    ]
    
    //MARK: - Delegates
    
    weak var delegate: DataSourceDelegate?
    
    //MARK: - model properties that notify all delegates
    
    open var actionScreenData: ActionScreenData? {
        didSet {
            if let data = self.actionScreenData {
                self.delegate?.actionScreenDataUpdated(data)
            }
        }
    }
    
    open var goalsData: [GoalData]? {
        didSet {
            if let data = self.goalsData {
                self.delegate?.goalsDataUpdated(data)
            }
        }
    }
    
    //how much time in seconds one action floss/brush/rinse takes on the timer
    open let FlossActionDurationInSeconds: Double = 120
    open let BrushActionDurationInSeconds: Double = 120
    open let RinseActionDurationInSeconds: Double = 30
    
    //the minimum time in seconds that is needed in order action to be record
    //on the server (this is different from the lowest time that is considered for valid record witch is 2 min.)
    open let ActionMinimumRecordTimeInSeconds: Double = 15
    
    //how many times can be taken per day, week, month for every kind of action
    open let maximumFlossesPerDay: Double = 1//1 time per day
    open let maximumBrushesPerDay: Double = 2
    open let maximumRinsesPerDay: Double = 2
    open let maximumFlossesPerWeek: Double = 14//14 times per week
    open let maximumBrushesPerWeek: Double = 14
    open let maximumRinsesPerWeek: Double = 14
    open let maximumFlossesPerMonth: Double = 60//60 times per month - we use average month length = 30 days
    open let maximumBrushesPerMonth: Double = 60
    open let maximumRinsesPerMonth: Double = 60
    
    //maximum time in seconds that every kind of action can be rewarded per day, week, month
    open let maximumFlossTimePerDay: Double = 240//240 seconds = 2 times * 2 min.
    open let maximumBrushTimePerDay: Double = 240
    open let maximumRinseTimePerDay: Double = 240
    open let maximumFlossTimePerWeek: Double = 1680//7 days * 2 times a day * 2 min.
    open let maximumBrushTimePerWeek: Double = 1680
    open let maximumRinseTimePerWeek: Double = 1680
    open let maximumFlossTimePerMonth: Double = 7200//30 days per month * 2 times a day * 2 min.
    open let maximumBrushTimePerMonth: Double = 7200
    open let maximumRinseTimePerMonth: Double = 7200
    
    //MARK: - singleton
    
    static let shared = UserDataContainer()
    private init() { }
    
    //MARK: - Public properties
    
    var lastRoutineRecord: RoutineData?
    var routine: Routine?
    var journey: JourneyData? {
        didSet {
            if let journey = self.journey {
                delegate?.journeyDataUpdated(journey)
            }
        }
    }
    
    var lastTimeRoutinePopupPresented: Date?
    
    var emergencyScreenImage: UIImage? {
        get {
            return self.emergencyScreenshot
        }
        set {
            self.emergencyScreenshot = newValue
        }
    }
    
    var userAvatarPath: String? {
        get {
            if let user = self.userData, let data = user.avatar {
                if let url = data.prefferedAvatarURL {
                    return url
                }
            } else {
                for provider in providers {
                    if let url = provider.avatarURL, url != "" {
                        return url
                    }
                }
            }
            return nil
        }
    }
    
    var email: String? {
        get {
            if let data = self.userData {
                return data.email
            } else {
                for provider in providers {
                    if let emailAddress = provider.email, !emailAddress.isEmpty {
                        return emailAddress
                    }
                }
                return nil
            }
        }
    }
    
    var userInfo: UserData? {
        get {
            
            if self.userData == nil {
                tryToLoadLastLocalUserInfo()
            }
            
            return self.userData
        }
        set {
            self.userData = newValue
            //try to save to local persistent storage
            do {
                guard let data = self.userData else { return }
                try Disk.save(data, to: .caches, as: self.userDataLocalFile)
            } catch {
                print("Error: Disk failed to save UserData to local caches :: \(error)")
            }
            
            if let data = userData {
                if UserDefaultsManager.shared.userKey != data.email {
                    UserDefaultsManager.shared.userKey = data.email
                }
                UserDataContainer.shared.setUserEmailConfirmed(data.confirmed)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "userEmailConfirmationUpdated"), object: nil)
            } else {
                UserDefaultsManager.shared.userKey = "unknown"
            }
            
        }
    }
    
    var userAvatar: UIImage? {
        get {
            return avatar
        }
        set {
            avatar = newValue
        }
    }
    
    var loginStatus: Bool {
        get {
            for provider in providers {
                if provider.isLoggedIn == true {
                    return true
                }
            }
            return false
        }
    }
    
    var hasValidSession: Bool {
        get {
            if let _: String = UserDefaultsManager.shared.getGlobalValue(forKey: "token") {
                //check for email session only
                let now = Date()
                if let tokenValidTo: String = UserDefaultsManager.shared.getGlobalValue(forKey: "token_valid_to") {
                    if let validToDate = SystemMethods.Utils.dateFrom(string: tokenValidTo) {
                        if now < validToDate {
                            //we still have valid session
                            return true
                        }
                    }
                }
            }
            return false
        }
    }
    
    var sessionToken: String? {
        get {
            if let token: String = UserDefaultsManager.shared.getGlobalValue(forKey: "token") {
                return token
            }
            return nil
        }
    }
    
    // MARK: - Open methods
    
    open func setUserEmailConfirmed(_ state: Bool) {
        UserDefaultsManager.shared.setValue(state, forKey: "UserEmailConfirmed")
    }
    
    open func getUserEmailConfirmed() -> Bool {
        if let state: Bool = UserDefaultsManager.shared.getValue(forKey: "UserEmailConfirmed") {
            return state
        }
        return false
    }
    
    func tryToLoadLastLocalUserInfo() {
        do {//try to load from local persistent storage
            self.userInfo = try Disk.retrieve(userDataLocalFile, from: .caches, as: UserData.self)
        } catch {
            print("Error: Disk failed to load UserData from local caches :: \(error)")
        }
    }
    
    //MARK: - Tooltip & Tutorials help methods
    
    // TODO: - remove all setters/getters that use user defaults from here, and make UserDefaultsManager to accept default value for convenience
    
    open func getTutorialsToggle() -> Bool {
        if let state: Bool = UserDefaultsManager.shared.getValue(forKey: "tutorialsToggle") {
            return state
        }
        return true
    }
    
    open func setTutorialsToggle(_ toggle: Bool) {
        UserDefaultsManager.shared.setValue(toggle, forKey: "tutorialsToggle")
    }
    
    open var toggleSpotlightsForActionScreen: Bool {
        get {
            if let state: Bool = UserDefaultsManager.shared.getValue(forKey: "actionScreenSpotlightsToggle") {
                return state
            }
            return true
        }
        set {
            UserDefaultsManager.shared.setValue(newValue, forKey: "actionScreenSpotlightsToggle")
        }
    }
    
    open var toggleSpotlightsForSideMenu: Bool {
        get {
            if let state: Bool = UserDefaultsManager.shared.getValue(forKey: "sideMenuSpotlightsToggle") {
                return state
            }
            return true
        }
        set {
            UserDefaultsManager.shared.setValue(newValue, forKey: "sideMenuSpotlightsToggle")
        }
    }
    
    //MARK: - Progress bars helper methods
    
    open func getActionsLeftBarProgress(_ value: Double, forType type: ActionRecordType) -> Double {
        let maxValue: Double?
        switch type {
            case .flossed:
                maxValue = self.maximumFlossesPerDay
            case .brush:
                maxValue = self.maximumBrushesPerDay
            case .rinsed:
                maxValue = self.maximumRinsesPerDay
        }
        guard let max = maxValue else { return 0.0 }
        let one = 360 / max
        return validateForBoundsResult(one * value) - 360
    }
    
    open func getActionsLastTimeBarProgress(_ value: Double, _ type: ActionRecordType) -> Double {
        var maxValue: Double = 0
        switch type {
            case .brush:
                maxValue = self.BrushActionDurationInSeconds
            case .flossed:
                maxValue = self.FlossActionDurationInSeconds
            case .rinsed:
                maxValue = self.RinseActionDurationInSeconds
        }
        let one = 360 / maxValue
        return validateForBoundsResult(one * value)
    }
    
    open func getStatisticsActionsTakenProgress(_ value: Double, forKind kind: ActionRecordType, ofType type: ScheduleOptionTypes) -> Double {
        var maxValue: Double?
        switch type {
            case .dailyData:
                if kind == .brush { maxValue = self.maximumBrushesPerDay }
                if kind == .flossed { maxValue = self.maximumFlossesPerDay }
                if kind == .rinsed { maxValue = self.maximumRinsesPerDay }
            case .weeklyData:
                if kind == .brush { maxValue = self.maximumBrushesPerWeek }
                if kind == .flossed { maxValue = self.maximumFlossesPerWeek }
                if kind == .rinsed { maxValue = self.maximumRinsesPerWeek }
            case .monthlyData:
                if kind == .brush { maxValue = self.maximumBrushesPerMonth }
                if kind == .flossed { maxValue = self.maximumFlossesPerMonth }
                if kind == .rinsed { maxValue = self.maximumRinsesPerMonth }
        }
        guard let max = maxValue else { return 0 }
        let one = 360 / max
        return validateForBoundsResult(one * value)
    }
    
    open func getStatisticsTimeLeftProgress(_ value: Double, forKind kind: ActionRecordType, ofType type: ScheduleOptionTypes) -> Double {
        var maxValue: Double?
        switch type {
            case .dailyData:
                if kind == .brush { maxValue = self.maximumBrushTimePerDay }
                if kind == .flossed { maxValue = self.maximumFlossTimePerDay }
                if kind == .rinsed { maxValue = self.maximumRinseTimePerDay }
            case .weeklyData:
                if kind == .brush { maxValue = self.maximumBrushTimePerWeek }
                if kind == .flossed { maxValue = self.maximumFlossTimePerWeek }
                if kind == .rinsed { maxValue = self.maximumRinseTimePerWeek }
            case .monthlyData:
                if kind == .brush { maxValue = self.maximumBrushTimePerMonth }
                if kind == .flossed { maxValue = self.maximumFlossTimePerMonth }
                if kind == .rinsed { maxValue = self.maximumRinseTimePerMonth }
        }
        guard let max = maxValue else { return 0 }
        let one = 360 / max
        return validateForBoundsResult(one * value)
    }
    
    open func getStatisticsAverageTimeProgress(_ value: Double, _ type: ActionRecordType) -> Double {
        var maxValue: Double = 0
        switch type {
            case .brush:
                maxValue = self.BrushActionDurationInSeconds
            case .flossed:
                maxValue = self.FlossActionDurationInSeconds
            case .rinsed:
                maxValue = self.RinseActionDurationInSeconds
        }
        let one = 360 / maxValue
        return validateForBoundsResult(one * value)
    }
    
    fileprivate func validateForBoundsResult(_ result: Double) -> Double {
        if result < 0 {
            return 0
        }
        if result > 360 {
            return 360
        }
        return result
    }
    
    //MARK: - Public methods
    
    open func logout() {
        
        //delete saved email session
        UserDefaultsManager.shared.clearGlobalValue(forKey: "token")
        UserDefaultsManager.shared.clearGlobalValue(forKey: "token_valid_to")
        
        for provider in providers {//delete all social network providers sessions if any
            provider.logout()
        }
        
        self.userAvatar = nil
    }
    
    // TODO: - move all network communications in Worker classes and use queues for multiple sequential requests
    
    open func syncWithServer() {
        requestActionScreenData()
        requestGoalsData()
        
        // We need this journey request to sync the app properly on the first launch.
        // Second request for journey is made within the Action Screen because
        // and according to the proggress made by the user we decide what to show there
        requestJourneyData()
        
        loadUserAvatar() { success in
            print("User Avatar success \(success)")
        }
    }
    
    open func loadUserAvatar(_ onComplete: ((_ success: Bool) -> Void)? = nil) {
        if let path = userAvatarPath {
            APIProvider.loadUserAvatar(path) { [weak self] image, error in
                if let error = error {
                    print("loadUserAvatar : Error \(error)")
                    onComplete?(false)
                    return
                }
                self?.userAvatar = image
                onComplete?(true)
            }
        } else {
            onComplete?(userAvatar == nil)
        }
    }
    
    // MARK: - Fileprivate methods
    
    fileprivate func requestJourneyData() {
        APIProvider.retreiveCurrentJourney() { [weak self] journey, error in

            if let _ = error {
                do {//try to load from local persistent storage
                    let fileName = self?.journeyDataLocalFile ?? ""
                    self?.journey = try Disk.retrieve(fileName, from: .caches, as: JourneyData.self)
                } catch {
                    print("Error: Disk failed to load JourneyData from local caches :: \(error)")
                }
                return
            }

            if let journey = journey {
                //try to save to local persistent storage
                do {
                    let fileName = self?.journeyDataLocalFile ?? ""
                    try Disk.save(journey, to: .caches, as: fileName)
                } catch {
                    print("Error: Disk failed to save JourneyData to local caches :: \(error)")
                }
                self?.journey = journey
            }

        }
    }
    
    fileprivate func requestGoalsData() {
        APIProvider.retreiveUserGoals() { [weak self] response, error in
            if let response = response {
                self?.goalsData = response
                //try to save to local persistent storage
                do {
                    let fileName = self?.goalsDataLocalFile ?? ""
                    try Disk.save(response, to: .caches, as: fileName)
                } catch {
                    print("Error: Disk failed to save UserData to local caches :: \(error)")
                }
                return
            }
            if let error = error {
                let nsError = error.toNSError()
                print("Error: \(nsError.localizedDescription)")
            }
            
            if self?.goalsData == nil {
                do {//try to load from local persistent storage
                    let fileName = self?.goalsDataLocalFile ?? ""
                    self?.goalsData = try Disk.retrieve(fileName, from: .caches, as: [GoalData].self)
                } catch {
                    print("Error: Disk failed to load UserData from local caches :: \(error)")
                }
            }
        }
    }
    
    fileprivate func requestActionScreenData() {
        
        if self.actionScreenData == nil {
            //try to load from local persistent storage
            do {
                self.actionScreenData = try Disk.retrieve(self.actionScreenLocalFile, from: .caches, as: ActionScreenData.self)
            } catch {
                print("Error: Disk failed to load ActionScreenData from local caches :: \(error)")
            }
            
            let daily = ScheduleData(times: 0, left: 0, average: 0)
            let weekly = ScheduleData(times: 0, left: 0, average: 0)
            let monthly = ScheduleData(times: 0, left: 0, average: 0)
            
            let flossed = ActionDashboardData(left: 0, earned: 0, daily: daily, weekly: weekly, monthly: monthly)
            let brush = ActionDashboardData(left: 0, earned: 0, daily: daily, weekly: weekly, monthly: monthly)
            let rinsed = ActionDashboardData(left: 0, earned: 0, daily: daily, weekly: weekly, monthly: monthly)
            let tongue = ActionDashboardData(left: 0, earned: 0, daily: daily, weekly: weekly, monthly: monthly)
            
            self.actionScreenData = ActionScreenData(
                earnedDCN: 0,
                pendingDCN: 0,
                flossed: flossed,
                brush: brush,
                rinsed: rinsed,
                tongue: tongue
            )
        }
        
        //TODO: - rename this method to requestActionScreenData
        APIProvider.requestActionData() { [weak self] response, error in
            
            if let response = response {
                self?.actionScreenData = response
                //save data locally
                do {
                    guard let fileName = self?.actionScreenLocalFile else { return }
                    try Disk.save(response, to: .caches, as: fileName)
                } catch {
                    print("Error: Disk failed to save ActionScreenData :: \(error)")
                }
                return
            }
            
            if let error = error {
                let nsError = error.toNSError()
                print("Error: \(nsError.localizedDescription)")
                //try to load from local persistent storage
                do {
                    guard let fileName = self?.actionScreenLocalFile else { return }
                    self?.actionScreenData = try Disk.retrieve(fileName, from: .caches, as: ActionScreenData.self)
                } catch {
                    print("Error: Disk failed to load ActionScreenData from local caches :: \(error)")
                }
            }
        }
    }
}

//MARK: - Tutorial tooltips IDs

public enum TutorialIDs: String {
    
    case totalDcn = "TOTAL_DCN"
    case lastActivityTime = "LAST_ACTIVITY_TIME"
    case dcnEarned = "DCN_EARNED"
    case editProfile = "EDIT_PROFILE"
    case collectDcn = "COLLECT_DCN"
    case goals = "GOALS"
    case dashboardStatistics = "DASHBOARD_STATISTICS"
    case emergencyMenu = "EMERGENCY_MENU"
    case qrCode = "QR_CODE"
    case leftActivitiesCount = "LEFT_ACTIVITIES_COUNT"
    
    static let all = [
        totalDcn,
        lastActivityTime,
        dcnEarned,
        editProfile,
        collectDcn,
        goals,
        dashboardStatistics,
        emergencyMenu,
        qrCode,
        leftActivitiesCount
    ]
}
