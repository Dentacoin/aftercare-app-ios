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
    
    fileprivate let defaults = UserDefaults.standard
    
    fileprivate var avatar: UIImage?
    fileprivate var emergencyScreenshot: UIImage?
    fileprivate var userData: UserData?
    fileprivate var tutorialsSessionStates: [String : Bool] = [:]
    
    //MARK: - Local model persistent file names
    
    fileprivate let actionScreenLocalFile = "actionData.json"
    fileprivate let userDataLocalFile = "userData.json"
    fileprivate let goalsDataLocalFile = "goalsData.json"
    
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
    open let ActionDurationInSeconds: Double = 120
    
    //the minimum time in seconds that is needed in order action to be record
    //on the server (this is different from the lowest time that is considered for valid record witch is 2 min.)
    open let ActionMinimumRecordTimeInSeconds: Double = 15
    
    //how many times can be taken per day, week, month for every kind of action
    open let maximumFlossessPerDay: Double = 2//2 times per day
    open let maximumBrushesPerDay: Double = 2
    open let maximumRinsesPerDay: Double = 2
    open let maximumFlossessPerWeek: Double = 14//14 times per week
    open let maximumBrushesPerWeek: Double = 14
    open let maximumRinsesPerWeek: Double = 14
    open let maximumFlossessPerMonth: Double = 60//60 times per month - we use average month length = 30 days
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
    
    var isRoutineRequested = false
    
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
            if let data = self.userData, let uemail = data.email {
                return uemail
            } else {
                for provider in providers {
                    if let emailAddress = provider.email, emailAddress != "" {
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
                do {//try to load from local persistent storage
                    self.userData = try Disk.retrieve(userDataLocalFile, from: .caches, as: UserData.self)
                } catch {
                    print("Error: Disk faild to load UserData from local caches :: \(error)")
                }
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
                print("Error: Disk faild to save UserData from local caches :: \(error)")
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
            if let _ = defaults.value(forKey: "token") {
                //check for email session only
                let now = Date()
                if let tokenValidTo = defaults.value(forKey: "token_valid_to") as? String {
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
            if let token = defaults.value(forKey: "token") as? String {
                return token
            }
            return nil
        }
    }
    
    //MARK: - Tutorials help methods
    
    open func getTutorialSessionToggle(_ id: String) -> Bool {
        if let state = self.tutorialsSessionStates[id] {
            return state
        }
        return true
    }
    
    open func setTutorialSessionToggle(_ id: String, _ toggle: Bool) {
        self.tutorialsSessionStates.updateValue(toggle, forKey: id)
    }
    
    open func getTutorialToggle(_ id: String) -> Bool {
        if let state = UserDefaults.standard.value(forKey: id) as? Bool {
            return state
        }
        return true
    }
    
    open func setTutorialToggle(_ id: String, _ toggle: Bool) {
        UserDefaults.standard.set(toggle, forKey: id)
    }
    
    open func resetTutorialToggle(_ value: Bool) {
        let defaults = UserDefaults.standard
        for tutorialID in TutorialIDs.all {
            defaults.set(value, forKey: tutorialID.rawValue)
        }
        self.tutorialsSessionStates = [:]
    }
    
    //MARK: - Progress bars helper methods
    
    open func getActionsLeftBarProgress(_ value: Double, forType type: ActionRecordType) -> Double {
        let maxValue: Double?
        switch type {
            case .flossed:
                maxValue = self.maximumFlossessPerDay
                break
            case .brush:
                maxValue = self.maximumBrushesPerDay
                break
            case .rinsed:
                maxValue = self.maximumRinsesPerDay
                break
        }
        guard let max = maxValue else { return 0.0 }
        let one = 360 / max
        let progress = (one * value) - 360
        return progress
    }
    
    open func getActionsLastTimeBarProgress(_ value: Double) -> Double {
        let maxValue = self.ActionDurationInSeconds
        let one = 360 / maxValue
        return one * value
    }
    
    open func getStatisticsActionsTakenProgress(_ value: Double, forKind kind: ActionRecordType, ofType type: ScheduleOptionTypes) -> Double {
        
        var maxValue: Double?
        
        switch type {
            case .dailyData:
                
                if kind == .brush { maxValue = self.maximumBrushesPerDay }
                if kind == .flossed { maxValue = self.maximumFlossessPerDay }
                if kind == .rinsed { maxValue = self.maximumRinsesPerDay }
                
                break
            case .weeklyData:
                
                if kind == .brush { maxValue = self.maximumBrushesPerWeek }
                if kind == .flossed { maxValue = self.maximumFlossessPerWeek }
                if kind == .rinsed { maxValue = self.maximumRinsesPerWeek }
                
                break
            case .monthlyData:
                
                if kind == .brush { maxValue = self.maximumBrushesPerMonth }
                if kind == .flossed { maxValue = self.maximumFlossessPerMonth }
                if kind == .rinsed { maxValue = self.maximumRinsesPerMonth }
                
                break
        }
        
        guard let max = maxValue else { return 0 }
        let one = 360 / max
        return one * value
    }
    
    open func getStatisticsTimeLeftProgress(_ value: Double, forKind kind: ActionRecordType, ofType type: ScheduleOptionTypes) -> Double {
        
        var maxValue: Double?
        
        switch type {
        case .dailyData:
            
            if kind == .brush { maxValue = self.maximumBrushTimePerDay }
            if kind == .flossed { maxValue = self.maximumFlossTimePerDay }
            if kind == .rinsed { maxValue = self.maximumRinseTimePerDay }
            
            break
        case .weeklyData:
            
            if kind == .brush { maxValue = self.maximumBrushTimePerWeek }
            if kind == .flossed { maxValue = self.maximumFlossTimePerWeek }
            if kind == .rinsed { maxValue = self.maximumRinseTimePerWeek }
            
            break
        case .monthlyData:
            
            if kind == .brush { maxValue = self.maximumBrushTimePerMonth }
            if kind == .flossed { maxValue = self.maximumFlossTimePerMonth }
            if kind == .rinsed { maxValue = self.maximumRinseTimePerMonth }
            
            break
        }
        
        guard let max = maxValue else { return 0 }
        let one = 360 / max
        return one * value
    }
    
    open func getStatisticsAverageTimeProgress(_ value: Double) -> Double {
        let maxValue = self.ActionDurationInSeconds
        let one = 360 / maxValue
        return one * value
    }
    
    //MARK: - Public methods
    
    func logout() {
        
        //delete saved email session
        defaults.set(nil, forKey: "token")
        defaults.set(nil, forKey: "token_valid_to")
        
        for provider in providers {//delete all social network providers sessions if any
            provider.logout()
        }
        
        self.userAvatar = nil
        
        //remove whole user persistent domain
//        if let bundle = Bundle.main.bundleIdentifier {
//            defaults.removePersistentDomain(forName: bundle)
//            defaults.synchronize()
//        }
    }
    
    func syncWithServer() {
        self.requestActionScreenData()
        self.requestGoalsData()
        self.loadUserAvatar() { success in
            print("User Avatar success \(success)")
        }
    }
    
    func loadUserAvatar(_ onComplete: ((_ success: Bool) -> Void)? = nil) {
        if let path = self.userAvatarPath {
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
            onComplete?(self.userAvatar == nil)
        }
    }
    
    fileprivate func requestGoalsData() {
        APIProvider.retreiveUserGoals() { [weak self] response, error in
            if let response = response {
                self?.goalsData = response
                //try to save to local persistent storage
                do {
                    guard let data = self?.goalsData else { return }
                    let fileName = self?.goalsDataLocalFile ?? ""
                    try Disk.save(data, to: .caches, as: fileName)
                } catch {
                    print("Error: Disk faild to save UserData from local caches :: \(error)")
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
                    print("Error: Disk faild to load UserData from local caches :: \(error)")
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
                print("Error: Disk faild to load ActionScreenData from local caches :: \(error)")
            }
            
            let flossedDaily = ScheduleData(times: 0, left: 0, average: 0)
            let flossedWeekly = ScheduleData(times: 0, left: 0, average: 0)
            let flossedMonthly = ScheduleData(times: 0, left: 0, average: 0)
            
            let flossed = ActionDashboardData(
                left: 0,
                earned: 0,
                daily: flossedDaily,
                weekly: flossedWeekly,
                monthly: flossedMonthly
            )
            
            let brushDaily = ScheduleData(times: 0, left: 0, average: 0)
            let brushWeekly = ScheduleData(times: 0, left: 0, average: 0)
            let brushMonthly = ScheduleData(times: 0, left: 0, average: 0)
            
            let brush = ActionDashboardData(
                left: 0,
                earned: 0,
                daily: brushDaily,
                weekly: brushWeekly,
                monthly: brushMonthly
            )
            
            let rinsedDaily = ScheduleData(times: 0, left: 0, average: 0)
            let rinsedWeekly = ScheduleData(times: 0, left: 0, average: 0)
            let rinsedMonthly = ScheduleData(times: 0, left: 0, average: 0)
            
            let rinsed = ActionDashboardData(
                left: 0,
                earned: 0,
                daily: rinsedDaily,
                weekly: rinsedWeekly,
                monthly: rinsedMonthly
            )
            
            self.actionScreenData = ActionScreenData(totalDCN: 0, flossed: flossed, brush: brush, rinsed: rinsed)
            
        }
        
        APIProvider.requestActionData() { [weak self] response, error in
            
            if let response = response {
                self?.actionScreenData = response
                //save data locally
                do {
                    guard let fileName = self?.actionScreenLocalFile else { return }
                    try Disk.save(response, to: .caches, as: fileName)
                } catch {
                    print("Error: Disk faild to save ActionScreenData :: \(error)")
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
                    print("Error: Disk faild to load ActionScreenData from local caches :: \(error)")
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
