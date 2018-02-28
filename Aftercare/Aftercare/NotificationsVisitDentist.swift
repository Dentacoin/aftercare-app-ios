//
//  NotificationsVisitDentist.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 21.10.17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import Foundation
import UserNotifications

struct NotificationsVisitDentist: NotificationDataProtocol {
    
    let notificationIdentifier = NotificationIdentifiers.visitDentist
    
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
        
        guard let dateOfRegistrationRaw = UserDataContainer.shared.userInfo?.createdDate else {
            print("NotificationsVisitDentist : Error : can't retreive user registration date")
            return
        }
        
        guard let dateOfRegistration = DateFormatter.iso8601.date(from: dateOfRegistrationRaw) else {
            print("NotificationsVisitDentist : Error : User Registration Date can't be retrieved")
            return
        }
        
        let data = NotificationData(
            title: "",
            message: NSString.localizedUserNotificationString(forKey: "When is the last time you visited your dentist? Maybe is time to make an appointment?", arguments: nil)
        )
        
        let content = UNMutableNotificationContent()
        content.title = data.title
        content.body = data.message
        content.sound = UNNotificationSound(named: "Notification.wav")
        
        let center = UNUserNotificationCenter.current()
        var triggerDate: Date = Date()
        
        if self.isWithinTheFirstTwoWeeks(afterDate: dateOfRegistration) {
            //If user registered within first two weeks, schedule notification on the end of the second week
            triggerDate = self.twoWeeksLater(afterDate: dateOfRegistration)
        } else {
            if let nextDate = nextDateToVisitDentist(afterRegistration: dateOfRegistration) {
                triggerDate = nextDate
            } else {
                print("NotificationsVisitDentist: Error while trying to calculate next date for visiting the dentist.")
                return
            }
        }
        
        var tDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour], from: triggerDate)
        tDateComponents.hour = 14
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
    
    fileprivate func isWithinTheFirstTwoWeeks(afterDate date: Date) -> Bool {
        let componentsSet = Set<Calendar.Component>([.day])
        let calendar = Calendar.current
        let result = calendar.dateComponents(componentsSet, from: date, to: Date())
        guard let day = result.day else {
            return false
        }
        if day <= 14 {
            return true
        }
        return false
    }
    
    fileprivate func twoWeeksLater(afterDate date: Date) -> Date {
        let calendar = Calendar.current
        let weekLater = calendar.date(byAdding: .day, value: 14, to: date)!
        return weekLater
    }
    
    fileprivate func nextDateToVisitDentist(afterRegistration date: Date) -> Date? {
        
        let calendar = Calendar.current
        let componentsSet = Set<Calendar.Component>([.month])
        let now = Date()
        let result = calendar.dateComponents(componentsSet, from: date, to: now)
        
        guard let months = result.month else {
            return nil
        }
        let monthsLeft = 4 - (months % 4)
        guard let nextDate = calendar.date(byAdding: .month, value: monthsLeft, to: now) else {
            return nil
        }
        return nextDate
    }
}
