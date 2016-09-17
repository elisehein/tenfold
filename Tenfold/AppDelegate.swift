//
//  AppDelegate.swift
//  Tenfold
//
//  Created by Elise Hein on 09/02/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var rootViewController: UIViewController?

    func application(application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        initServices()
        setGlobalAppearance()

        window = UIWindow(frame: UIScreen.mainScreen().bounds)

        if let window = window {
            let firstLaunch = StorageService.toggleFirstLaunchFlag()
            let shouldShowUpdatesModal = StorageService.toggleFeatureAnnouncementsFlag() && !firstLaunch

            let play = Play(shouldShowUpdatesModal: shouldShowUpdatesModal,
                            shouldLaunchOnboarding: firstLaunch)
            let navigationController = UINavigationController(rootViewController: play)
            navigationController.navigationBarHidden = true

            // The following hacks the interactive pop gesture to work with a hidden nav bar
            navigationController.interactivePopGestureRecognizer?.delegate = nil

            window.rootViewController = navigationController
            window.backgroundColor = UIColor.clearColor()
            window.makeKeyAndVisible()
        }

        return true
    }

    private func initServices() {
        SoundService.singleton = SoundService()
        CopyService.singleton = CopyService()
        StorageService.registerDefaults()
    }

    private func setGlobalAppearance() {
        let proxy = UINavigationBar.appearance()

        proxy.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        proxy.shadowImage = UIImage()
        proxy.barStyle = UIBarStyle.BlackTranslucent
        proxy.tintColor = UIColor.themeColor(.OffBlack)
    }
}
