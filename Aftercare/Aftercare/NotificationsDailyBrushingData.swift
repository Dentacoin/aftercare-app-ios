//
//  NotificationsDailyBrushingData.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 21.10.17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import Foundation
import UserNotifications

struct NotificationsDailyBrushingData: NotificationDataProtocol {
    
    let notificationIdentifier = NotificationIdentifiers.dailyBrushing
    
    typealias NotificationData = (title: String, message: String)
    
    //MARK: - Public
    
    init() {
        guard let _: Bool = UserDefaultsManager.shared.getValue(forKey: notificationIdentifier.rawValue) else {
            UserDefaultsManager.shared.setValue(true, forKey: notificationIdentifier.rawValue)
            return
        }
    }
    
    func scheduleNotification() {
        
        //Remove all already scheduled notifiations of this kind
        cancelNotification()
        
        let data = NotificationData(
            title: "",
            message: NSString.localizedUserNotificationString(forKey: "Hey there! Did you brush your teeth yet?", arguments: nil)
        )
        
        let content = UNMutableNotificationContent()
        content.title = data.title
        content.body = data.message
        content.sound = UNNotificationSound(named: NotificationSound.dncNotification.rawValue)
        
        let center = UNUserNotificationCenter.current()
        
        //Get current date and schedule brushing reminders at 11:00AM for the next 14 days
        let now = Date()
        let calendar = Calendar.current
        
        for i in 1...14 {
            
            let tomorrow = calendar.date(byAdding: .day, value: i, to: now)!
            let tomorrowDayValue = calendar.component(.day, from: tomorrow)
            
            var components = DateComponents()
            components.day = tomorrowDayValue
            components.hour = 11
            components.minute = 0
            components.second = 0
            
            let date = Calendar.current.date(from: components)
            let triggerDate = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: date!)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
            
            let request = UNNotificationRequest(
                identifier: notificationIdentifier.rawValue + "_" + String(i),
                content: content,
                trigger: trigger
            )
            
            center.add(request, withCompletionHandler: nil)
            
        }
    }
    
    func cancelNotification() {
        let center = UNUserNotificationCenter.current()
        var dailyBrushIdentifiers: [String] = []
        for i in 1...14 {
            dailyBrushIdentifiers.append(notificationIdentifier.rawValue + "_" + String(i))
        }
        center.removePendingNotificationRequests(withIdentifiers: dailyBrushIdentifiers)
    }
}
