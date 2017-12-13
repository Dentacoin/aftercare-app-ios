//
//  NotificationsManager.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 21.10.17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import Foundation
import UserNotifications
import Firebase
import Messages

class NotificationsManager: NSObject {
    
    //MARK: - singleton
    
    static let shared = NotificationsManager()
    private override init() { }
    
    //MARK: - Fileprivate variables and constants
    
    fileprivate let center = UNUserNotificationCenter.current()
    fileprivate var notificationOptions: UNAuthorizationOptions = [.sound, .alert]
    fileprivate let defaults = UserDefaults.standard
    fileprivate var notifications: [NotificationDataProtocol] = []
    //MARK: - Public API
    
    open func initialize() {
        
        //Setup Push Notifications
        askAuthorizationAndSetupPushNotifications()
        
        //Setup Local Notifications
        askAuthorizationAndSetupLocalNotifications()
    }
    
    open func toggleLocalNotification(withID id: NotificationIdentifiers, _ toggle: Bool) {
        defaults.set(toggle, forKey: id.rawValue)
        let notification = notificationData(byID: id)
        if toggle {
            //schedule notification
            notification?.scheduleNotification()
        } else {
            //cancel pending notification with id
            notification?.cancelNotification()
        }
    }
    
    open func localNotificationIsEnabled(withID id: NotificationIdentifiers) -> Bool {
        return defaults.value(forKey: id.rawValue) as? Bool ?? true//all notifications are enabled by default
    }
    
    //MARK: - Private logic
    
    fileprivate func askAuthorizationAndSetupPushNotifications() {
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in }
        )
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    fileprivate func askAuthorizationAndSetupLocalNotifications() {
        self.center.getNotificationSettings { [weak self] settings in
            if settings.authorizationStatus != .authorized {
                self?.requestAuthorization()
            } else {
                self?.initNotifications()
                self?.scheduleLocalNotifications()
            }
        }
    }
    
    fileprivate func requestAuthorization() {
        self.center.requestAuthorization(options: notificationOptions) { [weak self] granted, error in
            if let error = error {
                print("NotificationManager : config : Error \(error)")
                return
            }
            if granted {
                print("NotificationManager : User granted permissions for notifications!")
                self?.initNotifications()
                self?.scheduleLocalNotifications()
            }
        }
    }
    
    fileprivate func initNotifications() {
        notifications.append(NotificationsDailyBrushingData())
        notifications.append(NotificationsChangeBrushData())
        notifications.append(NotificationsVisitDentist())
        notifications.append(NotificationsCollectDCN())
        notifications.append(NotificationsVisitTheApp())
        notifications.append(NotificationsHealthyHabitsData())
    }
    
    fileprivate func scheduleLocalNotifications() {
        for notification in notifications {
            let id = notification.notificationIdentifier.rawValue
            if let isEnabled = defaults.value(forKey: id) as? Bool {
                if isEnabled == true {
                    notification.scheduleNotification()
                }
            }
        }
    }
    
    fileprivate func notificationData(byID id: NotificationIdentifiers) -> NotificationDataProtocol? {
        for notification in notifications {
            if id == notification.notificationIdentifier {
                return notification
            }
        }
        return nil
    }
    
}

//MARK: - UNUserNotificationCenterDelegate

extension NotificationsManager: UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("did register for remote notifications with device token \(deviceToken)")
        // With swizzling disabled you must set the APNs token here.
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("did fail to register for remote notification: \(error.localizedDescription)")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("did receive with completion handler")
        
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo["gcm.message_id"] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        completionHandler()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        if let messageID = userInfo["gcm.message_id"] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        if let messageID = userInfo["gcm.message_id"] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
    }
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo["gcm.message_id"] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        // Change this to your preferred presentation option
        completionHandler([.alert, .badge, .sound])//this will handle the push notification received on foreground
        //completionHandler([])//if you don't want to present received push notification
    }
}

//MARK: - MessagingDelegate

extension NotificationsManager: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
    }
    
    // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
    // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
    }
    
    //    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
    //        UserDefaults.standard.set(fcmToken, forKey: "firebase-pushnotifications-token")
    //    }
}


//MARK: - Protocols and enums

protocol NotificationDataProtocol {
    var notificationIdentifier: NotificationIdentifiers { get }
    func scheduleNotification()
    func cancelNotification()
}

public enum NotificationIdentifiers: String {
    case dailyBrushing = "notification_daily_brushing"
    case changeBrush = "notification_change_brush"
    case visitDentist = "notification_visit_dentist"
    case collectDentacoin = "notificaiton_collect_dentacoin"
    case remindToVisitTheApp = "notification_reminder_to_visit"
    case healthyHabits = "notification_healthy_habits"
}
