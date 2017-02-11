//
//  AppDelegate.swift
//  SDK Workshop
//

import UIKit
import KontaktSDK
//import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        // Set your API Key
        Kontakt.setAPIKey("PiyZzxEDbmhehgpIWQCoDfOeHSDHKGps")
        
        return true
    }
}

