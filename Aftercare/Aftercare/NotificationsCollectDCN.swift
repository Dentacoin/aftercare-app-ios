//
//  NotificationsCollectDCN.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 21.10.17.
//  Copyright © 2017 Dimitar Grudev. All rights reserved.
//

import Foundation
import UserNotifications

struct NotificationsCollectDCN: NotificationDataProtocol {
    
    let notificationIdentifier = NotificationIdentifiers.collectDentacoin
    
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
        
        let data = NotificationData(
            title: "",
            message: NSString.localizedUserNotificationString(forKey: "You have %d DCN in your account. You can collect them easily form the ''Dentacoin'' screen.", arguments: nil)
        )
        
        let content = UNMutableNotificationContent()
        content.title = data.title
        content.body = data.message
        content.sound = UNNotificationSound.default()
        
        let date = Date()
        let triggerDaily = Calendar.current.dateComponents([.hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDaily, repeats: true)
        
        let request = UNNotificationRequest(identifier: notificationIdentifier.rawValue, content: content, trigger: trigger)
    }
    
    func cancelNotification() {
        
    }
    
}
