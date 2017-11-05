//
//  NotificationsChangeBrushData.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 21.10.17.
//  Copyright © 2017 Dimitar Grudev. All rights reserved.
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
        
        guard let dateOfRegistrationRaw = UserDataContainer.shared.userInfo?.createdDate else {
            print("NotificationsChangeBrushData : Error : can't retreive user registration date")
            return
        }
        
        guard let dateOfRegistration = DateFormatter.humanReadableWithHourComponentsFormat.date(from: dateOfRegistrationRaw) else {
            print("NotificationsChangeBrushData : Error : User Registration Date can't be processed")
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
        let calendar = Calendar.current
        
        //If user registered within one week, schedule notification on the end of the first week
        let now = Date()
        let differenceInDays = Calendar.current.dateComponents([.day], from: dateOfRegistration, to: now).day ?? 0
        if differenceInDays <= 7 {
            
            guard let weekAfter = calendar.date(byAdding: .day, value: 7, to: dateOfRegistration) else {
                print("NotificationsChangeBrushData : Error : can't calculate the weekAfter date")
                return
            }
            
            let triggerDate = Calendar.current.dateComponents([.month, .day, .hour, .minute, .second], from: weekAfter)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
            
            let request = UNNotificationRequest(
                identifier: notificationIdentifier.rawValue,
                content: content,
                trigger: trigger
            )
            
            center.add(request, withCompletionHandler: nil)
            
        } else {
            //if user registered in more than 1 week schedule notification 3 months after the date of registration
            //and make it repeatable on every 3 months since then
            
            let date = Date()
            let triggerDate = Calendar.current.dateComponents([.hour, .minute, .second], from: date)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
            
            let request = UNNotificationRequest(
                identifier: notificationIdentifier.rawValue,
                content: content,
                trigger: trigger
            )
            center.add(request, withCompletionHandler: nil)
        }
        
    }
    
    func cancelNotification() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [notificationIdentifier.rawValue])
    }
    
}
