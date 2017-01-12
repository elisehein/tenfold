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

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        initServices()
        setGlobalAppearance()

        window = UIWindow(frame: UIScreen.main.bounds)

        if let window = window {
            let firstLaunch = StorageService.toggleFirstLaunchFlag()
            let shouldShowUpdatesModal = StorageService.toggleFeatureAnnouncementFlag(.Undo) && !firstLaunch

            let play = Play(shouldShowUpdatesModal: shouldShowUpdatesModal,
                            firstLaunch: firstLaunch)
            let navigationController = UINavigationController(rootViewController: play)
            navigationController.isNavigationBarHidden = true

            // The following hacks the interactive pop gesture to work with a hidden nav bar
            navigationController.interactivePopGestureRecognizer?.delegate = nil

            window.rootViewController = navigationController
            window.backgroundColor = UIColor.clear
            window.makeKeyAndVisible()
        }

        return true
    }

    fileprivate func initServices() {
        SoundService.singleton = SoundService()
        CopyService.singleton = CopyService()
        StorageService.registerDefaults()
    }

    fileprivate func setGlobalAppearance() {
        let proxy = UINavigationBar.appearance()

        proxy.setBackgroundImage(UIImage(), for: .default)
        proxy.shadowImage = UIImage()
        proxy.barStyle = UIBarStyle.blackTranslucent
        proxy.tintColor = UIColor.themeColor(.offBlack)
    }
}
