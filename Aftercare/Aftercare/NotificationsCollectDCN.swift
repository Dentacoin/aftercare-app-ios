//
//  NotificationsCollectDCN.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 21.10.17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import Foundation
import UserNotifications

struct NotificationsCollectDCN: NotificationDataProtocol {
    
    let notificationIdentifier = NotificationIdentifiers.collectDentacoin
    
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
        
        guard let totalDCN = UserDataContainer.shared.actionScreenData?.earnedDCN else {
            print("NotificationsCollectDCN: Error trying to retrieved total DPs for the User")
            return
        }
        
        guard let dateOfRegistrationRaw = UserDataContainer.shared.userInfo?.createdDate else {
            print("NotificationsCollectDCN: Error : can't retreive user registration date")
            return
        }
        
        guard let regDate = DateFormatter.iso8601.date(from: dateOfRegistrationRaw) else {
            print("NotificationsCollectDCN: Error : Wrong registration date format")
            return
        }
        
        if totalDCN <= 0 {
            print("NotificationsCollectDCN: User doesn't have enough DP to withdraw")
            return
        }
        
        let data = NotificationData(
            title: "",
            message: NSString.localizedUserNotificationString(
                forKey: "notifications_txt_collect_dentacoin_dp".localized(String(totalDCN)),
                arguments: nil
            )
        )
        
        let content = UNMutableNotificationContent()
        content.title = data.title
        content.body = data.message
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: NotificationSound.dncNotification.rawValue))
        
        let center = UNUserNotificationCenter.current()
        
        if let triggerDate = nextDateToRemindToCollect(afterRegistration: regDate) {
            var tDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour], from: triggerDate)
            tDateComponents.hour = 13
            let trigger = UNCalendarNotificationTrigger(dateMatching: tDateComponents, repeats: false)
            let request = UNNotificationRequest(
                identifier: notificationIdentifier.rawValue,
                content: content,
                trigger: trigger
            )
            center.add(request, withCompletionHandler: nil)
        } else {
            print("NotificationsCollectDCN: Error : Can't calculate next valid collect date")
        }
        
    }
    
    func cancelNotification() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [notificationIdentifier.rawValue])
    }
    
    //MARK: - Private Methods
    
    fileprivate func nextDateToRemindToCollect(afterRegistration date: Date) -> Date? {
        
        let calendar = Calendar.current
        let componentsSet = Set<Calendar.Component>([.month])
        let now = Date()
        let result = calendar.dateComponents(componentsSet, from: date, to: now)
        
        guard let months = result.month else {
            return nil
        }
        let monthsLeft = 3 - (months % 3)
        guard let nextDate = calendar.date(byAdding: .month, value: monthsLeft, to: now) else {
            return nil
        }
        return nextDate
    }
    
}
