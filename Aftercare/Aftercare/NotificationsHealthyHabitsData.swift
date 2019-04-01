//
//  NotificationsHealthyHabitsData.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 21.10.17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import Foundation
import UserNotifications

struct NotificationsHealthyHabitsData: NotificationDataProtocol {
    
    let notificationIdentifier = NotificationIdentifiers.healthyHabits
    
    typealias NotificationData = (title: String, message: String)
    
    //MARK: - fileprivates
    
    // TODO: - refactor this model data
    
    fileprivate lazy var notificationTitle01: String = {
        return NSString.localizedUserNotificationString(forKey: "notifications_hdl_healthy_habits_1".localized(), arguments: nil)
    }()
    
    fileprivate lazy var notificationMessage01: String = {
        return NSString.localizedUserNotificationString(forKey: "notifications_txt_healthy_habits_1".localized(), arguments: nil)
    }()
    
    fileprivate lazy var notificationTitle02: String = {
        return NSString.localizedUserNotificationString(forKey: "notifications_hdl_healthy_habits_2".localized(), arguments: nil)
    }()
    
    fileprivate lazy var notificationMessage02: String = {
        return NSString.localizedUserNotificationString(forKey: "notifications_txt_healthy_habits_2".localized(), arguments: nil)
    }()
    
    fileprivate lazy var notificationTitle03: String = {
        return NSString.localizedUserNotificationString(forKey: "notifications_hdl_healthy_habits_3".localized(), arguments: nil)
    }()
    
    fileprivate lazy var notificationMessage03: String = {
        return NSString.localizedUserNotificationString(forKey: "notifications_txt_healthy_habits_3".localized(), arguments: nil)
    }()
    
    fileprivate lazy var notificationTitle04: String = {
        return NSString.localizedUserNotificationString(forKey: "notifications_hdl_healthy_habits_4".localized(), arguments: nil)
    }()
    
    fileprivate lazy var notificationMessage04: String = {
        return NSString.localizedUserNotificationString(forKey: "notifications_txt_healthy_habits_4".localized(), arguments: nil)
    }()
    
    fileprivate lazy var notificationTitle05: String = {
        return NSString.localizedUserNotificationString(forKey: "notifications_hdl_healthy_habits_5".localized(), arguments: nil)
    }()
    
    fileprivate lazy var notificationMessage05: String = {
        return NSString.localizedUserNotificationString(forKey: "notifications_txt_healthy_habits_5".localized(), arguments: nil)
    }()
    
    fileprivate lazy var notificationTitle06: String = {
        return NSString.localizedUserNotificationString(forKey: "notifications_hdl_healthy_habits_6".localized(), arguments: nil)
    }()
    
    fileprivate lazy var notificationMessage06: String = {
        return NSString.localizedUserNotificationString(forKey: "notifications_txt_healthy_habits_6".localized(), arguments: nil)
    }()
    
    fileprivate lazy var notificationTitle07: String = {
        return NSString.localizedUserNotificationString(forKey: "notifications_hdl_healthy_habits_7".localized(), arguments: nil)
    }()
    
    fileprivate lazy var notificationMessage07: String = {
        return NSString.localizedUserNotificationString(forKey: "notifications_txt_healthy_habits_7".localized(), arguments: nil)
    }()
    
    fileprivate lazy var notificationTitle08: String = {
        return NSString.localizedUserNotificationString(forKey: "notifications_hdl_healthy_habits_8".localized(), arguments: nil)
    }()
    
    fileprivate lazy var notificationMessage08: String = {
        return NSString.localizedUserNotificationString(forKey: "notifications_txt_healthy_habits_8".localized(), arguments: nil)
    }()
    
    fileprivate lazy var notificationTitle09: String = {
        return NSString.localizedUserNotificationString(forKey: "notifications_hdl_healthy_habits_9".localized(), arguments: nil)
    }()
    
    fileprivate lazy var notificationMessage09: String = {
        return NSString.localizedUserNotificationString(forKey: "notifications_txt_healthy_habits_9".localized(), arguments: nil)
    }()
    
    fileprivate lazy var notificationTitle10: String = {
        return NSString.localizedUserNotificationString(forKey: "notifications_hdl_healthy_habits_10".localized(), arguments: nil)
    }()
    
    fileprivate lazy var notificationMessage10: String = {
        return NSString.localizedUserNotificationString(forKey: "notifications_txt_healthy_habits_10".localized(), arguments: nil)
    }()
    
    fileprivate var allNotifications: [NotificationData] = []
    
    //MARK: - Public
    
    init() {
        
        // TODO: - refactor this allNotifications array creation
        
        //all healthy habits messages
        allNotifications.insert((title: notificationTitle01, message: notificationMessage01), at: 0)
        allNotifications.insert((title: notificationTitle02, message: notificationMessage02), at: 0)
        allNotifications.insert((title: notificationTitle03, message: notificationMessage03), at: 0)
        allNotifications.insert((title: notificationTitle04, message: notificationMessage04), at: 0)
        allNotifications.insert((title: notificationTitle05, message: notificationMessage05), at: 0)
        allNotifications.insert((title: notificationTitle06, message: notificationMessage06), at: 0)
        allNotifications.insert((title: notificationTitle07, message: notificationMessage07), at: 0)
        allNotifications.insert((title: notificationTitle08, message: notificationMessage08), at: 0)
        allNotifications.insert((title: notificationTitle09, message: notificationMessage09), at: 0)
        allNotifications.insert((title: notificationTitle10, message: notificationMessage10), at: 0)
        
        guard let _: Bool = UserDefaultsManager.shared.getValue(forKey: notificationIdentifier.rawValue) else {
            UserDefaultsManager.shared.setValue(true, forKey: notificationIdentifier.rawValue)
            return
        }
    }
    
    func scheduleNotification() {
        
        //Remove all already scheduled notifiations of this kind
        cancelNotification()
        
        let now = Date()
        let calendar = Calendar.current
        let center = UNUserNotificationCenter.current()
        
        for i in 0..<20 {
            
            let tomorrow = calendar.date(byAdding: .day, value: i, to: now)!
            let tomorrowDayValue = calendar.component(.day, from: tomorrow)
            
            let data = getNotificationData()
            let content = UNMutableNotificationContent()
            content.title = data.title
            content.body = data.message
            content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: NotificationSound.dncNotification.rawValue))
            
            var components = DateComponents()
            components.day = tomorrowDayValue
            components.hour = 16
            components.minute = 0
            components.second = 0
            
            let date = Calendar.current.date(from: components)
            
            print("Local Notification ''Healthy Habits'' with scheduled for \(String(describing: date))")
            
            let triggerDate = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: date!)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
            
            let request = UNNotificationRequest(identifier: notificationIdentifier.rawValue + "_" + String(i), content: content, trigger: trigger)
            center.add(request, withCompletionHandler: nil)
        }
        
    }
    
    func cancelNotification() {
        let center = UNUserNotificationCenter.current()
        var dailyBrushIdentifiers: [String] = []
        for i in 0..<20 {
            dailyBrushIdentifiers.append(notificationIdentifier.rawValue + "_" + String(i))
        }
        center.removePendingNotificationRequests(withIdentifiers: dailyBrushIdentifiers)
    }
    
    //MARK: - Fileprivate methods
    
    fileprivate func getNotificationData() -> NotificationData {
        let count = allNotifications.count
        let randomIndex = arc4random_uniform(UInt32(count))
        let all = self.allNotifications
        return all[Int(randomIndex)]
    }
    
}
