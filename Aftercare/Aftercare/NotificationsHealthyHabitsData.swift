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
    
    fileprivate lazy var notificationTitle01: String = {
        return NSString.localizedUserNotificationString(forKey: "Don’t go to bed without brushing your teeth", arguments: nil)
    }()
    
    fileprivate lazy var notificationMessage01: String = {
        return NSString.localizedUserNotificationString(forKey: "Brushing before bed gets rid of the germs and plaque that accumulate throughout the day.", arguments: nil)
    }()
    
    fileprivate lazy var notificationTitle02: String = {
        return NSString.localizedUserNotificationString(forKey: "Brush properly.", arguments: nil)
    }()
    
    fileprivate lazy var notificationMessage02: String = {
        return NSString.localizedUserNotificationString(forKey: "The way you brush is equally important — in fact, doing a poor job of brushing your teeth is almost as bad as not brushing at all.", arguments: nil)
    }()
    
    fileprivate lazy var notificationTitle03: String = {
        return NSString.localizedUserNotificationString(forKey: "Don’t neglect your tongue.", arguments: nil)
    }()
    
    fileprivate lazy var notificationMessage03: String = {
        return NSString.localizedUserNotificationString(forKey:"Plaque can also build up on your tongue. Not only can this lead to bad mouth odor, but it can lead to other oral health problems.", arguments: nil)
    }()
    
    fileprivate lazy var notificationTitle04: String = {
        return NSString.localizedUserNotificationString(forKey: "Use a fluoride toothpaste.", arguments: nil)
    }()
    
    fileprivate lazy var notificationMessage04: String = {
        return NSString.localizedUserNotificationString(forKey: "When it comes to toothpaste, there are more important elements to look for than whitening power and flavors.", arguments: nil)
    }()
    
    fileprivate lazy var notificationTitle05: String = {
        return NSString.localizedUserNotificationString(forKey: "Flossing is as important as brushing.", arguments: nil)
    }()
    
    fileprivate lazy var notificationMessage05: String = {
        return NSString.localizedUserNotificationString(forKey: "Flossing once a day is usually enough to reap these benefits.", arguments: nil)
    }()
    
    fileprivate lazy var notificationTitle06: String = {
        return NSString.localizedUserNotificationString(forKey: "Consider mouthwash", arguments: nil)
    }()
    
    fileprivate lazy var notificationMessage06: String = {
        return NSString.localizedUserNotificationString(forKey: "Mouthwashes are useful as an adjunct tool to help bring things into balance", arguments: nil)
    }()
    
    fileprivate lazy var notificationTitle07: String = {
        return NSString.localizedUserNotificationString(forKey: "Drink more water", arguments: nil)
    }()
    
    fileprivate lazy var notificationMessage07: String = {
        return NSString.localizedUserNotificationString(forKey: "Drink water after every meal. This can help wash out some of the negative effects of sticky and acidic foods and beverages in between brushes.", arguments: nil)
    }()
    
    fileprivate lazy var notificationTitle08: String = {
        return NSString.localizedUserNotificationString(forKey: "Eat crunchy fruits and vegetables", arguments: nil)
    }()
    
    fileprivate lazy var notificationMessage08: String = {
        return NSString.localizedUserNotificationString(forKey: "Eating fresh, crunchy produce not only contains more healthy fiber, but it is also the best choice as far as your teeth are concerned", arguments: nil)
    }()
    
    fileprivate lazy var notificationTitle09: String = {
        return NSString.localizedUserNotificationString(forKey: "Limit sugary and acidic foods", arguments: nil)
    }()
    
    fileprivate lazy var notificationMessage09: String = {
        return NSString.localizedUserNotificationString(forKey: "Sugar converts into acid in the mouth, which can then erode the enamel of your teeth", arguments: nil)
    }()
    
    fileprivate lazy var notificationTitle10: String = {
        return NSString.localizedUserNotificationString(forKey: "See your dentist at least twice a year", arguments: nil)
    }()
    
    fileprivate lazy var notificationMessage10: String = {
        return NSString.localizedUserNotificationString(forKey: "At minimum, you should see your dentist for cleanings and checkups twice a year", arguments: nil)
    }()
    
    fileprivate var allNotifications: [NotificationData] = []
    
    //MARK: - Public
    
    init() {
        
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
        
        let defaults = UserDefaults.standard
        guard let _ = defaults.value(forKey: notificationIdentifier.rawValue) else {
            defaults.set(true, forKey: notificationIdentifier.rawValue)
            defaults.synchronize()
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
            content.sound = UNNotificationSound.default()
            
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
