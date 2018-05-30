//
//  NotificationsVisitTheApp.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 21.10.17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import Foundation
import UserNotifications

struct NotificationsVisitTheApp: NotificationDataProtocol {
    
    let notificationIdentifier = NotificationIdentifiers.remindToVisitTheApp
    
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
            message: NSString.localizedUserNotificationString(forKey: "notifications_txt_reminder_to_visit".localized(), arguments: nil)
        )
        
        let content = UNMutableNotificationContent()
        content.title = data.title
        content.body = data.message
        content.sound = UNNotificationSound(named: "Notification.wav")
        
        let center = UNUserNotificationCenter.current()
        let triggerDate = weekLater(afterDate: Date())//week later from now
        
        var tDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour], from: triggerDate)
        tDateComponents.hour = 18
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
    
    fileprivate func weekLater(afterDate date: Date) -> Date {
        let calendar = Calendar.current
        let weekLater = calendar.date(byAdding: .day, value: 7, to: date)!
        return weekLater
    }
    
    
}
