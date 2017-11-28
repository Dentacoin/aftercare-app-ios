//
//  NotificationsChangeBrushData.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 21.10.17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import Foundation
import UserNotifications

struct NotificationsChangeBrushData: NotificationDataProtocol {
    
    
    let notificationIdentifier = NotificationIdentifiers.changeBrush
    
    typealias NotificationData = (title: String, message: String)
    
    //MARK: - Public
    
    init() {
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
        
        guard let dateOfRegistrationRaw = UserDataContainer.shared.userInfo?.createdDate else {
            print("NotificationsChangeBrushData : Error : can't retreive user registration date")
            return
        }
        
        guard let dateOfRegistration = DateFormatter.humanReadableWithHourComponentsFormat.date(from: dateOfRegistrationRaw) else {
            print("NotificationsChangeBrushData : Error : User Registration Date can't be retrieved")
            return
        }
        
        let data = NotificationData(
            title: "",
            message: NSString.localizedUserNotificationString(forKey: "When is the last time you changed your toothbrush?", arguments: nil)
        )
        
        let content = UNMutableNotificationContent()
        content.title = data.title
        content.body = data.message
        content.sound = UNNotificationSound.default()
        
        let center = UNUserNotificationCenter.current()
        var triggerDate: Date = Date()
        
        if self.isWithinTheFirstWeek(afterDate: dateOfRegistration) {
            //If user registered within one week, schedule notification on the end of the first week
            triggerDate = self.weekLater(afterDate: dateOfRegistration)
        } else {
            if let nextDate = nextDateToChangeBrush(afterRegistration: dateOfRegistration) {
                triggerDate = nextDate
            } else {
                print("NotificationsChangeBrushData: Error while trying to calculate next date for changing the brush.")
                return
            }
        }
        
        var tDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour], from: triggerDate)
        tDateComponents.hour = 10
        let trigger = UNCalendarNotificationTrigger(dateMatching: tDateComponents, repeats: false)
        let request = UNNotificationRequest(
            identifier: notificationIdentifier.rawValue,
            content: content,
            trigger: trigger
        )
        center.add(request, withCompletionHandler: nil)
    }
    
    func cancelNotification() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [notificationIdentifier.rawValue])
    }
    
    //MARK: - Private Methods
    
    fileprivate func isWithinTheFirstWeek(afterDate date: Date) -> Bool {
        let componentsSet = Set<Calendar.Component>([.day])
        let calendar = Calendar.current
        let result = calendar.dateComponents(componentsSet, from: date, to: Date())
        guard let day = result.day else {
            return false
        }
        if day <= 7 {
            return true
        }
        return false
    }
    
    fileprivate func weekLater(afterDate date: Date) -> Date {
        let calendar = Calendar.current
        let weekLater = calendar.date(byAdding: .day, value: 7, to: date)!
        return weekLater
    }
    
    fileprivate func nextDateToChangeBrush(afterRegistration date: Date) -> Date? {
        
        let calendar = Calendar.current
        let componentsSet = Set<Calendar.Component>([.month])
        let result = calendar.dateComponents(componentsSet, from: date, to: Date())
        
        guard let months = result.month else {
            return nil
        }
        let monthsLeft = 3 - (months % 3)
        guard let nextDate = calendar.date(byAdding: .month, value: monthsLeft, to: date) else {
            return nil
        }
        return nextDate
    }
    
}
