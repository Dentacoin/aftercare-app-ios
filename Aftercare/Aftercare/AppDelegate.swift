//
//  AppDelegate.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 7/10/17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import TwitterKit
import Firebase
import GoogleSignIn
import GooglePlaces
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //Hide status bar inside the app!
        UIApplication.shared.statusBarStyle = .lightContent
        UIApplication.shared.isStatusBarHidden = true
        
        //Preload main view controller
        if let rootViewController = self.window?.rootViewController as? MasterViewController {
            rootViewController.preloadMainController = true
        }
        
        #if DEBUG
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                                    .userDomainMask,
                                                                    true)[0]
        print("Documents Path: \(documentsPath)")
        #endif //DEBUG
        
//        for name in UIFont.familyNames {
//            print("FONT NAME \(name)")
//            print(UIFont.fontNames(forFamilyName: name))
//        }
        
        // facebook initialization
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // twitter initialization
        if let twitterKey = SystemMethods.Environment.value(forKey: .TwitterKey) {
            let twitterSecret = SystemMethods.Environment.value(forKey: .TwitterSecretKey) ?? ""
            Twitter.sharedInstance().start(withConsumerKey: twitterKey, consumerSecret: twitterSecret)
        } else {
            print("WARNING: Missing Twitter Key and Secret Key!")
        }
        
        // firebase and Google Sign In configure and initialization
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        FirebaseApp.configure()
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        
        //Init Google Places SDK
        if let googlePlacesApiKey = SystemMethods.Environment.value(forKey: .GooglePlacesAPIKey) {
            GMSPlacesClient.provideAPIKey(googlePlacesApiKey)
        } else {
            print("WARNING: Missing Google Places API Key!")
        }
        
        //Fabric initialization
        Fabric.with([Crashlytics.self])
        
        //#if DEBUG
        //UserDataContainer.shared.logout()
        //#endif
        
        if UserDataContainer.shared.hasValidSession {
            APIProvider.retreiveUserInfo() { [weak self] userData, error in
                if let data = userData {
                    
                    UserDataContainer.shared.userInfo = data
                    UserDataContainer.shared.syncWithServer()
                    
                    self?.show(child: .main)
                    
                } else if let error = error?.toNSError() {
                    
                    //something went wrong
                    UIAlertController.show(
                        controllerWithTitle: NSLocalizedString("Error", comment: ""),
                        message: error.localizedDescription,
                        buttonTitle: NSLocalizedString("Ok", comment: "")
                    )
                    
                    UserDataContainer.shared.logout()
                    self?.show(child: .splash)
                    
                }
            }
        } else {
            show(child: .splash)
        }
        
        return true
    }
    
    fileprivate func show(child: ChildViewController) {
        if let rootViewController = self.window?.rootViewController as? MasterViewController {
            rootViewController.currentChildViewController = child
        }
    }
    
    // facebook initialization
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        //Twitter scheme
        if Twitter.sharedInstance().application(app, open: url, options: options) {
            return true
        }
        
        //Google scheme
        if GIDSignIn.sharedInstance().handle(
            url,
            sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
            annotation: [:]
        ) {
            return true
        }
        
        //Facebook scheme
        return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
    }
    
}
