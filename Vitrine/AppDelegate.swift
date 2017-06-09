//
//  AppDelegate.swift
//  Vitrine
//
//  Created by Bakbergen on 4/18/17.
//  Copyright © 2017 Bakbergen. All rights reserved.
//

import UIKit
import Alamofire

struct GlobalConstants {
    static var Person:User = User()
    static let url:String = "http://manager.vitrine.kz:3000"
    static let baseURL:URL = URL(string: "http://manager.vitrine.kz:3000/api")!
    
    static var category_id:String = "0"
    static var sub_category_id:String = "0"
    static var sub2_category_id:String = "0"
    static var sub3_category_id:String = "0"
}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffsetMake(0, -120), for: UIBarMetrics.default)
        // Override point for customization after application launch.
//        Parse.enableLocalDatastore()
        
        // Initialize Parse.
//        Parse.setApplicationId("VGMC48BU0YYtXTaNlXMm4rQAKR3uWeOnbSLd5f5q",
//                               clientKey: "vp3LWVhFHff7gJSenC367dyzqzZHqr8k1GSQACz3")
        
        // [Optional] Track statistics around application opens.
//        PFAnalytics.trackAppOpened(launchOptions: launchOptions)
        
        GMSServices.provideAPIKey("AIzaSyCx733GK-sIQlw5FZ9u-IPLUCtec3lJZng")//dal Bako
        //AIzaSyDo3G3SJ22PYq_-pPMiILHhcXy_yt4IL1c
        
//        GMSServices.provideAPIKey("AIzaSyDo3G3SJ22PYq_-pPMiILHhcXy_yt4IL1c")
        
        // Register for Push Notitications
        if application.applicationState != UIApplicationState.background {
            // Track an app open here if we launch with a push, unless
            // "content_available" was used to trigger a background push (introduced in iOS 7).
            // In that case, we skip tracking here to avoid double counting the app-open.
            
            let preBackgroundPush = !application.responds(to: "backgroundRefreshStatus")
            let oldPushHandlerOnly = !self.responds(to: #selector(UIApplicationDelegate.application(_:didReceiveRemoteNotification:fetchCompletionHandler:)))
            var pushPayload = false
            if let options = launchOptions {
                pushPayload = options[UIApplicationLaunchOptionsKey.remoteNotification] != nil
            }
            if (preBackgroundPush || oldPushHandlerOnly || pushPayload) {
//                PFAnalytics.trackAppOpened(launchOptions: launchOptions)
            }
        }
        /*
         if application.respondsToSelector("registerUserNotificationSettings:") {
         let userNotificationTypes = UIUserNotificationType.Alert
         let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
         application.registerUserNotificationSettings(settings)
         application.registerForRemoteNotifications()
         } else {
         let types = UIRemoteNotificationType.Badge
         application.registerForRemoteNotificationTypes(types)
         }
         */
        return true
    }
    
//    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
//        let installation = PFInstallation.currentInstallation()
//        installation.setDeviceTokenFromData(deviceToken)
//        installation.channels = ["News","Action"]
//        installation.saveInBackground()
//    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        if error.code == 3010 {
            print("Push notifications are not supported in the iOS Simulator.")
        } else {
            print("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
        }
    }
    
//    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
//        PFPush.handlePush(userInfo)
//        if application.applicationState == UIApplicationState.Inactive {
//            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
//        }
//    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func updateUserData() {
//        API.get("users/profile") { response in
        Alamofire.request("http://manager.vitrine.kz:3000/api/users/profile").responseJSON { response in
        switch (response.result) {
        case .success(let JSON):
            GlobalConstants.Person.updatePersonalData(JSON as AnyObject)
        default:
            return
            }
        }
    }
    
}

