//
//  AppDelegate.swift
//  Clicker
//
//  Created by Keivan Shahida on 9/20/17.
//  Copyright © 2017 CornellAppDev. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import StoreKit
import Siren

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        let navigationController = UINavigationController(rootViewController: HomeViewController())
        // let navigationController = UINavigationController(rootViewController: GroupHomeViewController())
        window?.rootViewController = navigationController
        
        let siren = Siren.shared
        siren.alertType = .option
        siren.alertMessaging = SirenAlertMessaging(updateTitle: "Update Available", updateMessage: "A new version of Pollo is available! Please update now.", updateButtonMessage: "Update", nextTimeButtonMessage: "Next Time", skipVersionButtonMessage: "Skip this version")
        siren.checkVersion(checkType: .immediately)

        #if DEBUG
            Crashlytics.start(withAPIKey: Keys.fabricAPIKey)
        #endif
        return true
    }
    
    func requestReview() {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        } else {
            print("In app rating not supported.")
        }
    }
}
